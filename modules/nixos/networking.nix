# Interface names found via `ip link`.
# Wifi interface was soft-blocked, had to manually unblock it once via `sudo rfkill unblock wifi`.
{
  flake.modules.nixos.networking = {
    networking = {
      wireless = {
        enable = true;
        secretsFile = "/var/lib/secrets/wireless.conf";
        networks."Our Little Home v2".pskRaw = "ext:psk_home";
      };
      useDHCP = false;

      interfaces.eno1.useDHCP = true;
      interfaces.wlo1.useDHCP = true;
    };
  };
}
