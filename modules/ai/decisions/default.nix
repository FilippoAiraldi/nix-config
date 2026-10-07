{
  flake.modules.nixos."ai-decisions" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      python = pkgs.python313;
      stateDir = "/var/lib/ai/decisions";
      idleTimeout = "1h";
      startTimeout = "1800"; # in seconds (30min)
    in
    {
      options = {
        "ai-decisionsPort" = lib.mkOption {
          type = lib.types.int;
          description = "AI-decisions endpoint port";
          default = 3004;
        };

        "ai-decisionsBackendPort" = lib.mkOption {
          type = lib.types.int;
          description = "AI-decisions internal (backend) port; the public port proxies to it";
          default = 3005;
        };
      };

      config.systemd = {
        # socket to start the proxy (and thus the backend) on first request
        sockets.ai-decisions-proxy = {
          description = "AI-decisions listening socket";
          wantedBy = [ "sockets.target" ];
          listenStreams = [ "127.0.0.1:${toString config."ai-decisionsPort"}" ];
        };

        # proxy to the backend; exits when idle for too long, stopping the backend in turn
        services.ai-decisions-proxy = {
          description = "AI-decisions idle-timeout proxy";
          requires = [ "ai-decisions.service" ];
          after = [ "ai-decisions.service" ];
          serviceConfig = {
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${idleTimeout} 127.0.0.1:${
              toString config."ai-decisionsBackendPort"
            }";
            DynamicUser = true;
            PrivateTmp = true;
          };
        };

        # main service
        services.ai-decisions = {
          description = "AI-decisions endpoint";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          path = [
            pkgs.coreutils
            pkgs.uv
            python
          ];
          environment = {
            HOME = stateDir; # home for the dynamic user
            HF_HOME = "${stateDir}/hf"; # HF local storage
            HF_HUB_OFFLINE = "1"; # disable http calls to HF
            UV_CACHE_DIR = "/var/cache/ai/decisions";
            UV_PROJECT_ENVIRONMENT = "${stateDir}/venv"; # directory to use as venv
            UV_PYTHON_DOWNLOADS = "never"; # disable downloading Python binary
            UV_PYTHON_PREFERENCE = "only-system"; # use system's Python binary
            UV_NO_DEV = "1"; # don't install development dependencies
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
            ]; # ld libs needed by torch, numpy, etc
          };
          unitConfig.StopWhenUnneeded = true; # stops once the proxy exits
          serviceConfig = {
            DynamicUser = true;
            StateDirectory = "ai/decisions"; # matches stateDir
            CacheDirectory = "ai/decisions"; # matches uv cache dir
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStartSec = "${startTimeout}s"; # enough time to download/install torch model
            NoNewPrivileges = true; # disable sudo in service and its child
            ProtectHome = true; # remove service's access to home directories
            ExecPaths = [ "/var/lib/private/ai/decisions" ]; # path from which programs can be exec
          };

          preStart =
            let
              src = lib.fileset.toSource {
                root = ./.;
                fileset = lib.fileset.unions [
                  ./.python-version
                  ./pyproject.toml
                  ./app
                  ./uv.lock
                ];
              };
            in
            ''
              # copy Python project anew
              rm -rf ${stateDir}/project
              mkdir -p ${stateDir}/project
              cp -r --no-preserve=mode ${src}/. ${stateDir}/project
              cd ${stateDir}/project

              # compare the last interpreter's store path (if any, due to 2>dev/null) with the current
              # and rebuilt if different
              if [ "$(cat "$UV_PROJECT_ENVIRONMENT.python" 2>/dev/null)" != "${python}" ]; then
                rm -rf "$UV_PROJECT_ENVIRONMENT"
                echo "${python}" > "$UV_PROJECT_ENVIRONMENT.python"
              fi
              uv sync --locked
            '';

          script = ''
            # launch the server
            cd ${stateDir}/project
            exec ${stateDir}/venv/bin/python -m uvicorn app.api:app \
              --host 127.0.0.1 --port ${toString config."ai-decisionsBackendPort"}
          '';

          postStart = ''
            # keep unit in "activating" until uvicorn accepts connections
            for _ in $(seq 1 ${startTimeout}); do
              if (exec 3<>/dev/tcp/127.0.0.1/${toString config."ai-decisionsBackendPort"}) 2>/dev/null; then
                exit 0
              fi
              sleep 1
            done
            echo "backend did not open its port in time" >&2
            exit 1
          '';
        };
      };
    };
}
