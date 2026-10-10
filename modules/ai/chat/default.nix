{
  flake.modules.nixos.ai-chat =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      idleTimeout = "30m";
      ollamaPkg = pkgs.ollama-vulkan;
      defaultModel = "smollm2:135m";
    in
    {
      options."ai-chatPort" = lib.mkOption {
        type = lib.types.int;
        description = "AI-chat (Ollama) port";
        default = 3006;
      };

      config = {
        services.ollama = {
          enable = true;
          package = ollamaPkg;
          port = config.ai-chatPort;
          environmentVariables = {
            OLLAMA_KEEP_ALIVE = idleTimeout;
            OLLAMA_VULKAN = "1";
            OLLAMA_DEBUG = "2";
            VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
          };
        };
        nixpkgs.config.allowUnfreePackages = [ "nvidia-kernel-modules" ];

        # convenience command to start chatting in a REPL
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "ai-chat" ''
            export OLLAMA_HOST=127.0.0.1:${toString config.ai-chatPort}
            MODEL="''${AI_CHAT_MODEL:-${defaultModel}}"
            echo "Running $MODEL on $OLLAMA_HOST. Use AI_CHAT_MODEL to change the model."

            ${ollamaPkg}/bin/ollama pull "$MODEL" # no-op if already stored
            exec ${ollamaPkg}/bin/ollama run "$MODEL" "$@"  # $@ passes through additional args
          '')
        ];
      };
    };
}
