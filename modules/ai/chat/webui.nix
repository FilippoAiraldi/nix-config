{
  flake.modules.nixos.ai-chat-webui =
    { config, lib, ... }:
    {
      options.ai-chat-webuiPort = lib.mkOption {
        type = lib.types.int;
        description = "AI-chat LibreChat port";
        default = 3008;
      };

      # LibreChat server
      # https://www.librechat.ai/docs/configuration/dotenv
      # https://www.librechat.ai/docs/configuration/librechat_yaml
      # https://www.librechat.ai/docs/features/web_search
      config = {
        services.librechat = {
          enable = true;
          enableLocalDB = true;
          credentialsFile = "/var/lib/secrets/librechat.env";
          env = {
            PORT = config.ai-chat-webuiPort;
            SEARXNG_INSTANCE_URL = "http://127.0.0.1:${toString config.searxPort}";
          };
          settings = {
            endpoints.custom = [
              {
                name = "Ollama";
                apiKey = "ollama";
                baseURL = "http://127.0.0.1:${toString config.ai-chatPort}/v1";
                models = {
                  default = [ "smollm2:135m" ];
                  fetch = true;
                };
                titleConvo = true;
                titleModule = "smollm2:135m";
                modelDisplayLabel = "Ollama";
              }
            ];
            interface.webSearch = true;
            webSearch = {
              searchProvider = "searxng";
              searxngInstanceUrl = "\${SEARXNG_INSTANCE_URL}";
              allowedAddresses = [ "127.0.0.1:${toString config.searxPort}" ];
              scraperProvider = "keenable";
              rerankerType = "none";
            };
          };
        };

        nixpkgs.config.allowUnfreePackages = [ "mongodb" ];
      };
    };
}
