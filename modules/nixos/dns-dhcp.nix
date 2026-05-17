# Private home network: unbound (DNS resolver + blocklist) + dnsmasq (DHCP server)
# https://wiki.nixos.org/wiki/Unbound
# https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
#
# Unbound provides private DNS resolutions with integrated ads/malware blocking. Since Ziggo
# SmartWifi modem cannot be forced to use a private internal IP address as DNS resolver, we
# must also run on the host our own DHCP server (dnsmasq), and tell the modem not to act as
# DHCP server.
#
# For IPv6, since the Ziggo modem's DHCPv6 server cannot be disable (unlike v4), we let our
# host broadcast itself as an IPv6 DNS server, on top of the modem's server. It is up to each
# connected client to use one or the other, and ads may still slip through if Ziggo is used.
# All of this is achieved via `radvd`, while allowing IPv6 forwarding in the boot.
#
# In case of connection issues, to restore the DHCP server on the modem, we can reach it from
# another machine by disabling DHCP on that machine, and assigning IPs manually:
#   - force an IP address for the machine, e.g., `192.168.178.18`
#   - subnet mask `255.255.255.0`
#   - default gateway `192.168.178.1` (a.k.a., modem)
#   - preferred DNS `192.168.178.1` (a.k.a., modem)
#   - alternate DNS `9.9.9.9`
{
  flake.modules.nixos."dns-dhcp" =
    let
      modemIP = "192.168.178.1";
      hostIP = "192.168.178.17";
      homeSubnet = "192.168.178.0/24";
      networkInterface = "eno1";
    in
    {
      services.unbound = {
        enable = true;
        settings = {
          server = {
            interface = [
              "127.0.0.1"
              hostIP
              "fd00::17"
            ];
            access-control = [
              "127.0.0.0/8 allow"
              "${homeSubnet} allow"
              "fd00::/64 allow"
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
        defaultGateway = modemIP;
        nameservers = [
          "127.0.0.1"
          "9.9.9.9"
        ];
        interfaces.${networkInterface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = hostIP;
              prefixLength = 24;
            }
          ];
          ipv6.addresses = [
            {
              address = "fd00::17";
              prefixLength = 64;
            }
          ];
        };
        firewall.allowedUDPPorts = [
          53
          67
        ];
        firewall.allowedTCPPorts = [ 53 ];
      };

      services = {
        dnsmasq = {
          enable = true;
          settings = {
            port = 0; # leave port 53 for Unbound
            interface = networkInterface;
            dhcp-range = [ "192.168.178.20,192.168.178.200,255.255.255.0,24h" ];
            dhcp-option = [
              "option:router,${modemIP}"
              "option:dns-server,${hostIP}"
            ];
            dhcp-authoritative = true;
          };
        };

        radvd = {
          enable = true;
          config = ''
            interface ${networkInterface} {
              AdvSendAdvert on;
              AdvDefaultLifetime 0;
              RDNSS fd00::17 { };
            };
          '';
        };
      };
    };
}
