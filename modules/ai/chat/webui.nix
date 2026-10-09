{
  flake.modules.nixos.ai-chat-webui =
    { config, lib, ... }:
    {
      options.ai-chat-webuiPort = lib.mkOption {
        type = lib.types.int;
        description = "AI-chat Open-WebUI port";
        default = 3008;
      };

      # Open-WebUI server
      # https://docs.openwebui.com/reference/env-configuration
      # https://docs.openwebui.com/features/chat-conversations/web-search/providers/searxng
      config = {
        services.open-webui = {
          enable = true;
          port = config.ai-chat-webuiPort;
          environment = {
            OLLAMA_BASE_URL = "http://127.0.0.1:${toString config.ai-chatPort}";
            ENABLE_OPENAI_API = "False"; # only local models
            ENABLE_WEB_SEARCH = "True";
            WEB_SEARCH_ENGINE = "searxng";
            WEB_SEARCH_CONCURRENT_REQUESTS = "10";
            SEARXNG_QUERY_URL = "http://127.0.0.1:${toString config.searxPort}/search?q=<query>";
            ANONYMIZED_TELEMETRY = "False";
            DO_NOT_TRACK = "True";
            SCARF_NO_ANALYTICS = "True";
          };
        };

        nixpkgs.config.allowUnfreePackages = [ "open-webui" ];
      };
    };
}
