{
  flake.modules.nixos."ai-chat" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ollama = pkgs.ollama-cpu; # CPU-only build, no GPU available
      model = "smollm2:135m"; # tiny model, easier debugging
      stateDir = "/var/lib/ai/chat";
      idleTimeout = "15min";
      startTimeout = "600"; # in seconds
      host = "127.0.0.1:${toString config."ai-chatPort"}";
    in
    {
      options = {
        "ai-chatPort" = lib.mkOption {
          type = lib.types.int;
          description = "AI-chat (Ollama) public port; proxies to the backend, which starts on demand";
          default = 3006;
        };

        "ai-chatBackendPort" = lib.mkOption {
          type = lib.types.int;
          description = "AI-chat (Ollama) internal (backend) port";
          default = 3007;
        };
      };

      config = {
        # `ai-chat` opens a terminal chat; triggers the on-demand service via the socket
        environment.systemPackages = [
          ollama
          (pkgs.writeShellScriptBin "ai-chat" ''
            export OLLAMA_HOST=${host}
            exec ${ollama}/bin/ollama run ${model} "$@"
          '')
        ];

        systemd = {
          sockets.ai-chat-proxy = {
            description = "AI-chat listening socket";
            wantedBy = [ "sockets.target" ];
            listenStreams = [ host ];
          };

          # exits when idle for too long, stopping the backend in turn
          services.ai-chat-proxy = {
            description = "AI-chat idle-timeout proxy";
            requires = [ "ai-chat.service" ];
            after = [ "ai-chat.service" ];
            serviceConfig = {
              ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${idleTimeout} 127.0.0.1:${
                toString config."ai-chatBackendPort"
              }";
              DynamicUser = true;
              PrivateTmp = true;
            };
          };

          services.ai-chat = {
            description = "AI-chat Ollama server";
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            environment = {
              HOME = stateDir;
              OLLAMA_HOST = "127.0.0.1:${toString config."ai-chatBackendPort"}";
              OLLAMA_MODELS = "${stateDir}/models";
            };
            unitConfig.StopWhenUnneeded = true; # stops once the proxy exits
            serviceConfig = {
              DynamicUser = true;
              StateDirectory = "ai/chat"; # matches stateDir
              ExecStart = "${ollama}/bin/ollama serve";
              Restart = "on-failure";
              RestartSec = "10s";
              TimeoutStartSec = "${startTimeout}s";
              NoNewPrivileges = true;
              ProtectHome = true;
            };

            # keep unit in "activating" until the server is up and the model is available
            postStart = ''
              for _ in $(seq 1 ${startTimeout}); do
                if ${ollama}/bin/ollama list >/dev/null 2>&1; then
                  ${ollama}/bin/ollama pull ${model}
                  exit 0
                fi
                sleep 1
              done
              echo "ollama did not start in time" >&2
              exit 1
            '';
          };
        };
      };
    };
}
