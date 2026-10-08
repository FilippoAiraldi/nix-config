{
  flake.modules.nixos.monitoring =
    { config, lib, ... }:
    let
      domain = "${config.hostName}.home";
      every = "5m";

      # localhost check of a service
      local = name: port: {
        name = "${name} (local)";
        group = "services";
        url = "http://127.0.0.1:${toString port}/";
        interval = every;
        conditions = [ "[STATUS] < 400" ];
      };

      # end-to-end check through Caddy (DNS + TLS + proxy)
      viaCaddy = name: {
        name = "${name} (Caddy)";
        group = "caddy";
        url = "https://${name}.${domain}/";
        interval = every;
        client.insecure = true; # Caddy's internal CA is not trusted by the Gatus process
        conditions = [ "[STATUS] < 400" ];
      };
    in
    {
      options = {
        gatusPort = lib.mkOption {
          type = lib.types.int;
          description = "Gatus port";
          default = 3001;
        };
        prometheusPort = lib.mkOption {
          type = lib.types.int;
          description = "Prometheus port";
          default = 9090;
        };
        prometheusNodeExporterPort = lib.mkOption {
          type = lib.types.int;
          description = "Prometheus node exporter port";
          default = 9100;
        };
        grafanaPort = lib.mkOption {
          type = lib.types.int;
          description = "Grafana port";
          default = 3000;
        };
      };

      config = {
        services = {
          # health monitoring of endpoints and DNS resolvers
          gatus = {
            enable = true;
            settings = {
              web = {
                address = "127.0.0.1";
                port = config.gatusPort;
              };
              metrics = true;

              endpoints =
                # Caddy checks on itself
                map (port: {
                  name = "Caddy port ${toString port}";
                  group = "caddy";
                  url = "tcp://127.0.0.1:${toString port}";
                  interval = every;
                  conditions = [ "[CONNECTED] == true" ];
                }) config.caddyPorts
                ++ [
                  # DNS checks
                  {
                    name = "DNS via Pi-hole";
                    group = "dns";
                    url = "127.0.0.1";
                    interval = every;
                    dns = {
                      query-name = "nixos.org";
                      query-type = "A";
                    };
                    conditions = [ "[DNS_RCODE] == NOERROR" ];
                  }
                  {
                    name = "DNS via Unbound";
                    group = "dns";
                    url = "127.0.0.1:${toString config.unboundPort}";
                    interval = every;
                    dns = {
                      query-name = "nixos.org";
                      query-type = "A";
                    };
                    conditions = [ "[DNS_RCODE] == NOERROR" ];
                  }
                  {
                    name = "Pi-hole blocking";
                    group = "dns";
                    url = "127.0.0.1";
                    interval = every;
                    dns = {
                      query-name = "doubleclick.net";
                      query-type = "A";
                    };
                    conditions = [ "[BODY] == 0.0.0.0" ];
                  }
                  {
                    name = "Wildcard DNS for Caddy";
                    group = "dns";
                    url = "127.0.0.1";
                    interval = every;
                    dns = {
                      query-name = "gatus.${domain}";
                      query-type = "A";
                    };
                    conditions = [
                      "[DNS_RCODE] == NOERROR"
                      "[BODY] == ${config.localIPAddr}"
                    ];
                  }

                  # direct localhost checks
                  (local "AI Chat" config.ai-chatPort)
                  (local "Grafana" config.grafanaPort)
                  (local "Pi-Hole Web" config.piholeWebPort)
                  (local "SearXNG" config.searxPort)
                  (local "Syncthing" config.syncthingPort)

                  # end-to-end through Caddy
                  (viaCaddy "ai-chat")
                  (viaCaddy "grafana")
                  (viaCaddy "pihole")
                  (viaCaddy "searxng")
                  (viaCaddy "syncthing")
                  (viaCaddy "gatus")
                ];
            };
          };

          # resource usage monitor
          prometheus = {
            enable = true;
            listenAddress = "127.0.0.1";
            port = config.prometheusPort;
            retentionTime = "90d";
            globalConfig.scrape_interval = "30s";

            exporters.node = {
              enable = true;
              listenAddress = "127.0.0.1";
              port = config.prometheusNodeExporterPort;
              enabledCollectors = [
                "logind"
                "systemd"
              ];
            };

            scrapeConfigs = [
              {
                job_name = "node";
                static_configs = [
                  { targets = [ "127.0.0.1:${toString config.prometheusNodeExporterPort}" ]; }
                ];
              }
              {
                job_name = "gatus";
                static_configs = [
                  { targets = [ "127.0.0.1:${toString config.gatusPort}" ]; }
                ];
              }
            ];
          };

          # dashboard for Prometheus. These are the dashboards I use:
          # - Prometheus: dashboard ID 1860
          # - Gatus: import from https://github.com/TwiN/gatus/blob/master/.examples/docker-compose-grafana-prometheus/grafana/provisioning/dashboards/gatus.json
          grafana = {
            enable = true;
            settings = {
              server = {
                http_addr = "127.0.0.1";
                http_port = config.grafanaPort;
              };
              security.secret_key = "$__file{/run/credentials/grafana.service/secret_key}";
            };
            provision = {
              enable = true;
              datasources.settings.datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  uid = "prometheus";
                  url = "http://127.0.0.1:${toString config.prometheusPort}";
                  isDefault = true;
                  editable = false;
                }
              ];
            };
          };
        };

        # copy Grafana's secret key
        systemd.services.grafana.serviceConfig.LoadCredential = [
          "secret_key:/var/lib/secrets/grafana_secret_key"
        ];
      };
    };
}
