{
  flake.modules.nixos.dns = {
    # Unbound (local DNS resolver)
    # https://wiki.nixos.org/wiki/Unbound
    # https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
    # https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
    services.unbound = {
      enable = true;
      settings.server = {
        interface = [ "127.0.0.1" ]; # wait for Pi-Hole requests
        port = 5335;
        access-control = [ "127.0.0.1/32 allow" ]; # only allow localhost

        # suggested options
        qname-minimisation = true;
        prefetch = true;
        so-rcvbuf = "1m";
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
          "192.0.2.0/24"
          "198.51.100.0/24"
          "203.0.113.0/24"
          "255.255.255.255/32"
          "2001:db8::/32"
        ];
      };
    };

    # Pi Hole (DNS forwarder + blocklist)
    # https://wiki.nixos.org/wiki/Pi-Hole
    # https://docs.pi-hole.net/ftldns/configfile
    services = {
      pihole-ftl = {
        enable = true;
        settings = {
          dns = {
            upstreams = [ "127.0.0.1#5335" ]; # points to Unbound
            hosts = [
              "192.168.1.1 modem.home"
              "192.168.68.100 crappy-server.home"
            ];
          };
        };
        lists = [
          {
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/ultimate.txt";
            type = "block";
            enabled = true;
            description = "hagezi ultimate blocklist";
          }
          {
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/popupads.txt";
            type = "block";
            enabled = true;
            description = "hagezi popupads blocklist";
          }
          {
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt";
            type = "block";
            enabled = true;
            description = "hagezi tif blocklist";
          }
          {
            url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/fake.txt";
            type = "block";
            enabled = true;
            description = "hagezi fake blocklist";
          }
        ];
      };
      pihole-web = {
        enable = true;
        ports = [ "443s" ];
      };
    };

    # necessary adjustments to networking
    # 1) tell this server to use itself as server
    # 2) open ports for clients to reach Pi-Hole and its website
    networking = {
      nameservers = [
        "127.0.0.1"
        "9.9.9.9" # fallback in case localhost fails
      ];
      firewall.allowedUDPPorts = [ 53 ];
      firewall.allowedTCPPorts = [
        53
        443
      ];
    };
  };
}

