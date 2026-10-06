{
  flake.modules.nixos.proxy =
    { config, lib, ... }:
    let
      services = {
        decisions = config.ai.decisionsPort;
        gatus = config.gatusPort;
        grafana = config.grafanaPort;
        searxng = config.searxPort;
        syncthing = config.syncthingPort;
      };

      domain = "${config.hostName}.home";

      mkVirtualHost = name: port: {
        name = "${name}.${domain}";  # e.g., gatus.crappy-server.home
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
          virtualHosts = lib.mapAttrs' mkVirtualHost services // {
            # Pi-hole web needs special attention
            "pihole.${domain}".extraConfig = ''
              tls internal
              reverse_proxy https://127.0.0.1:${toString config.piholeWebPort} {
                transport http {
                  tls_insecure_skip_verify
                }
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
