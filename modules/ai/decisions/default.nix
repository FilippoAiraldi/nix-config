{
  flake.modules.nixos.decisions =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stateDir = "/var/lib/decisions";

      # Only what the service needs; uv.lock is optional (see README).
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./.python-version
          ./pyproject.toml
          ./decisions
          (lib.fileset.maybeMissing ./uv.lock)
        ];
      };

      # torch.jit.script is needed, so stay on Python 3.13 or older
      python = pkgs.python313;

      # Libraries needed by the manylinux wheels (torch, numpy, ...) that uv installs.
      ldLibraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
      ];
    in
    {
      options.decisionsPort = lib.mkOption {
        type = lib.types.int;
        description = "Decisions (GLiNER2.5-Decide) endpoint port";
        default = 3004;
      };

      # Decisions endpoint: GLiDE-style POST /v1/systemone served by FastAPI. The model is
      # loaded once at startup and kept in memory. Python comes from nixpkgs (uv never downloads
      # one); the dependencies are installed by uv, so they are not managed by Nix, and nix-ld
      # lets their binaries run.
      config = {
        programs.nix-ld = {
          enable = true;
          libraries = ldLibraries;
        };

        systemd.services.decisions = {
          description = "Decisions endpoint (GLiNER2.5-Decide)";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          path = [
            pkgs.coreutils
            pkgs.uv
            python
          ];

          environment = {
            HOME = stateDir;
            HF_HOME = "${stateDir}/huggingface";
            UV_CACHE_DIR = "/var/cache/decisions";
            UV_PROJECT_ENVIRONMENT = "${stateDir}/venv";
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON_PREFERENCE = "only-system";
            UV_NO_DEV = "1";
            # services do not get the login-shell variables that programs.nix-ld sets
            NIX_LD = pkgs.stdenv.cc.bintools.dynamicLinker;
            NIX_LD_LIBRARY_PATH = lib.makeLibraryPath ldLibraries;
          };

          # The project is copied to the state dir because uv writes uv.lock (if missing)
          # and needs a writable project; the store copy is read-only.
          preStart = ''
            rm -rf ${stateDir}/project
            mkdir -p ${stateDir}/project
            cp -r --no-preserve=mode ${src}/. ${stateDir}/project
            cd ${stateDir}/project
            # the venv links to the store Python; rebuild it when that interpreter changes
            if [ "$(cat ${stateDir}/venv.python 2>/dev/null)" != "${python}" ]; then
              rm -rf ${stateDir}/venv
              echo "${python}" > ${stateDir}/venv.python
            fi
            uv sync
          '';

          script = ''
            cd ${stateDir}/project
            exec ${stateDir}/venv/bin/uvicorn decisions.api:app \
              --host 127.0.0.1 --port ${toString config.decisionsPort}
          '';

          serviceConfig = {
            DynamicUser = true;
            StateDirectory = "decisions";
            CacheDirectory = "decisions";
            Restart = "on-failure";
            RestartSec = "10s";
            # first start downloads torch and the model
            TimeoutStartSec = "30min";
            NoNewPrivileges = true;
            ProtectHome = true;
          };
        };
      };
    };
}
