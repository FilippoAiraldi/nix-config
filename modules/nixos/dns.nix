# Private home network: unbound (DNS forwarder + blocklist)
# https://wiki.nixos.org/wiki/Unbound
# https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
{
  flake.modules.nixos.dns = {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "192.168.68.100"
          ];
          access-control = [
            "127.0.0.0/8 allow"
            "192.168.68.0/24 allow"
          ];
        };
        server.module-config = "'respip validator iterator'";
        rpz = [
          {
            name = "hageziPro";
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/rpz/pro.txt";
          }
        ];
        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = true;
            forward-addr = [
              "9.9.9.9@853#dns.quad9.net"
              "149.112.112.112@853#dns.quad9.net"
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
          }
        ];
      };
    };

    networking = {
      nameservers = [
        "127.0.0.1"
        "9.9.9.9"
      ];
      firewall.allowedUDPPorts = [ 53 ];
      firewall.allowedTCPPorts = [ 53 ];
    };
  };
}
