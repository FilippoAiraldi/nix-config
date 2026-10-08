{
  flake.modules.nixos.proxy =
    { config, lib, ... }:
    let
      domain = "${config.hostName}.home";
      mkVirtualHost = name: port: {
        name = "${name}.${domain}"; # e.g., gatus.crappy-server.home
        value.extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:${toString port}
        '';
      };
    in
    {
      options.caddyPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        description = "Caddy ports";
        default = [
          80
          443
        ];
      };

      config = {
        services.caddy = {
          enable = true;
          virtualHosts =
            # entries here have all the same setup
            lib.mapAttrs' mkVirtualHost {
              ai-decisions = config.ai-decisionsPort;
              gatus = config.gatusPort;
              grafana = config.grafanaPort;
              searxng = config.searxPort;
              syncthing = config.syncthingPort;
            }
            //
            # entries below require special attention
            {
              "pihole.${domain}".extraConfig = ''
                tls internal
                reverse_proxy https://127.0.0.1:${toString config.piholeWebPort} {
                  transport http {
                    tls_insecure_skip_verify
                  }
                }
              '';

              "ai-chat.${domain}".extraConfig =
                let
                  host = "127.0.0.1:${toString config.ai-chatPort}";
                in
                ''
                  tls internal
                  reverse_proxy ${host} {
                    header_up Host ${host}
                  }
                '';
            };
        };

        networking.firewall.interfaces = lib.genAttrs config.networkInterfaces (_: {
          allowedTCPPorts = config.caddyPorts;
        });
      };
    };
}
