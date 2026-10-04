{
  flake.modules.nixos.monitoring =
    { config, lib, ... }:
    {
      # module options
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
                address = "0.0.0.0";
                port = config.gatusPort;
              };
              metrics = true;

              endpoints = [
                {
                  name = "Pi-hole web";
                  url = "https://localhost:${toString config.piholeWebPort}/";
                  interval = "10m";
                  client.insecure = true;
                  conditions = [
                    "[STATUS] == 200"
                    "[BODY] == pat(*Pi-hole*)"
                  ];
                }
                {
                  name = "Pi-hole web (LAN address)";
                  url = "https://${config.localIPaddr}:${toString config.piholeWebPort}/";
                  interval = "10m";
                  client.insecure = true;
                  conditions = [
                    "[STATUS] == 200"
                    "[BODY] == pat(*Pi-hole*)"
                  ];
                }
                {
                  name = "DNS via Pi-hole";
                  url = "127.0.0.1";
                  interval = "10m";
                  dns = {
                    query-name = "nixos.org";
                    query-type = "A";
                  };
                  conditions = [ "[DNS_RCODE] == NOERROR" ];
                }
                {
                  name = "DNS via Unbound";
                  url = "127.0.0.1:${toString config.unboundPort}";
                  interval = "10m";
                  dns = {
                    query-name = "nixos.org";
                    query-type = "A";
                  };
                  conditions = [ "[DNS_RCODE] == NOERROR" ];
                }
                {
                  name = "Pi-hole blocking";
                  url = "127.0.0.1";
                  interval = "10m";
                  dns = {
                    query-name = "doubleclick.net";
                    query-type = "A";
                  };
                  conditions = [ "[BODY] == 0.0.0.0" ];
                }
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
                http_addr = "0.0.0.0";
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

        # open port for Gatus and Grafana
        networking.firewall.interfaces = lib.genAttrs config.networkInterfaces (_: {
          allowedTCPPorts = [
            config.gatusPort
            config.grafanaPort
          ];
        });

        # copy Grafana's secret key
        systemd.services.grafana.serviceConfig.LoadCredential = [
          "secret_key:/var/lib/secrets/grafana_secret_key"
        ];
      };
    };
}
