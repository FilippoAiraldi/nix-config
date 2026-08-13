# Interface names found via `ip link`.
# Wifi interface was soft-blocked, had to manually unblock it once via `sudo rfkill unblock wifi`.
{
  flake.modules.nixos.networking = {
    networking = {
      wireless = {
        enable = true;
        networks."Our Little Home v2".pskRaw = "2db8f93ad41eee0811d4047b8c0a9201145b0d1932e0df714136a0f68fd71f4b";
      };
      useDHCP = false;

      interfaces.eno1.useDHCP = true;
      interfaces.wlo1.useDHCP = true;
    };
  };
}

