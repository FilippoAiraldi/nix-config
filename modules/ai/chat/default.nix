{
  flake.modules.nixos."ai-chat" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      idleTimeout = "30m";
      ollamaPkg = pkgs.ollama-cpu;
      defaultModel = "smollm2:135m"; # tiny model (default of AI_CHAT_MODEL), easier debugging
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
          host = "127.0.0.1";
          port = config."ai-chatPort";
          environmentVariables = {
            OLLAMA_LLM_LIBRARY = "cpu_avx2";
            OLLAMA_KEEP_ALIVE = idleTimeout;
          };
        };

        # convenience command to start chatting in a REPL
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "ai-chat" ''
            export OLLAMA_HOST=127.0.0.1:${toString config."ai-chatPort"}
            MODEL="''${AI_CHAT_MODEL:-${defaultModel}}"
            ${ollamaPkg}/bin/ollama pull "$MODEL" # no-op if already stored
            exec ${ollamaPkg}/bin/ollama run "$MODEL" "$@"  # $@ passes through additional args
          '')
        ];
      };
    };
}
