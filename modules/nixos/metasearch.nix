{
  flake.modules.nixos.metasearch =
    { config, lib, ... }:
    {
      options.searxPort = lib.mkOption {
        type = lib.types.int;
        description = "searXNG port";
        default = 3003;
      };

      config = {
        # searXNG (metasearch engine)
        # https://wiki.nixos.org/wiki/SearXNG
        # https://docs.searxng.org/admin/settings/index.html
        services.searx = {
          enable = true;
          environmentFile = "/var/lib/secrets/searxng.env";
          settings.server = {
            bind_address = "0.0.0.0";
            port = config.searxPort;
            limiter = false;
            public_instance = false;
          };
        };
        # services.websurfx = {
        #   enable = true;
        #   settings = {
        #     binding_ip = "0.0.0.0";
        #     port = config.searxPort;
        #     http_cache_expiry_time = 60;
        #   };
        # };

        networking.firewall.interfaces = lib.genAttrs config.networkInterfaces (_: {
          allowedTCPPorts = [ config.searxPort ];
        });
      };
    };
}
