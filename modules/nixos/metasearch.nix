{
  flake.modules.nixos.metasearch =
    { config, lib, ... }:
    {
      options.searxPort = lib.mkOption {
        type = lib.types.int;
        description = "searXNG port";
        default = 3003;
      };

      # searXNG (metasearch engine)
      # https://wiki.nixos.org/wiki/SearXNG
      # https://docs.searxng.org/admin/settings/index.html
      config.services.searx = {
        enable = true;
        environmentFile = "/var/lib/secrets/searxng.env";
        settings.search.formats = [
          "html"
          "json" # needed by LibreChat web search (see ai/chat/webui.nix)
        ];
        settings.server = {
          bind_address = "127.0.0.1";
          port = config.searxPort;
          limiter = false;
          public_instance = false;
        };
      };
      # config.services.websurfx = {
      #   enable = true;
      #   settings = {
      #     binding_ip = "127.0.0.1";
      #     port = config.searxPort;
      #     http_cache_expiry_time = 60;
      #   };
      # };
    };
}
