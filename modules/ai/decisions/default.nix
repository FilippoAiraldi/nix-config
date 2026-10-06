{
  flake.modules.nixos."ai-decisions" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stateDir = "/var/lib/ai/decisions";

      python = pkgs.python313;

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
    {
      options."ai-decisionsPort" = lib.mkOption {
        type = lib.types.int;
        description = "AI-decisions endpoint port";
        default = 3004;
      };

      config.systemd.services.ai-decisions = {
        description = "AI-decisions endpoint";
        wantedBy = [ "multi-user.target" ];
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
          HF_HUB_OFFLINE = "0"; # disable http calls to HF
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
        serviceConfig = {
          DynamicUser = true;
          StateDirectory = "ai/decisions"; # matches stateDir
          CacheDirectory = "ai/decisions"; # matches uv cache dir
          Restart = "on-failure";
          RestartSec = "10s";
          TimeoutStartSec = "30min"; # enough time to download/install torch and model
          NoNewPrivileges = true; # disable sudo in service and its child
          ProtectHome = true; # remove service's access to home directories
        };

        preStart = ''
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
          cd ${stateDir}/project
          exec ${stateDir}/venv/bin/uvicorn app.api:app \
            --host 127.0.0.1 --port ${toString config."ai-decisionsPort"}
        '';

      };
    };
}
