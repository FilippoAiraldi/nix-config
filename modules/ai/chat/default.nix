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
      model = "smollm2:135m"; # tiny model (default of AI_CHAT_MODEL), easier debugging
      host = "127.0.0.1:${toString config."ai-chatPort"}";
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
          package = ollama;
          host = "127.0.0.1";
          port = config."ai-chatPort";
          loadModels = [ model ]; # pulled at startup
          environmentVariables = {
            OLLAMA_LLM_LIBRARY = "cpu_avx2";
            OLLAMA_KEEP_ALIVE = "5m"; # unload idle models from RAM
          };
        };

        # `ai-chat` opens a terminal chat with the model given by AI_CHAT_MODEL
        environment.systemPackages = [
          ollama
          (pkgs.writeShellScriptBin "ai-chat" ''
            export OLLAMA_HOST=${host}
            MODEL="''${AI_CHAT_MODEL:-${model}}"
            ${ollama}/bin/ollama pull "$MODEL" # no-op if already stored
            exec ${ollama}/bin/ollama run "$MODEL" "$@"
          '')
        ];
      };
    };
}
