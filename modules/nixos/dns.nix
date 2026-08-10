# Private home network: Pi Hole (DNS resolver + blocklist)
# https://wiki.nixos.org/wiki/Pi-Hole
# https://docs.pi-hole.net/ftldns/configfile
{
  flake.modules.nixos.dns = {
    services.pihole-ftl = {
      enable = true;
      settings = {
        dns = {
          upstreams = [
            "9.9.9.9"
            "149.112.112.112"
            "1.1.1.1"
            "1.0.0.1"
          ];
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

    services.pihole-web = {
      enable = true;
      ports = [ "443s" ];
    };

    networking = {
      nameservers = [
        "127.0.0.1"
        "9.9.9.9"
      ];
      firewall.allowedUDPPorts = [ 53 ];
      firewall.allowedTCPPorts = [
        53
        443
      ];
    };
  };
}

