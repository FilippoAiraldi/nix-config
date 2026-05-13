{
  flake.modules.nixos.networking = {
    networking = {
      wireless.enable = false;
      useDHCP = false;
      interfaces.eno1.useDHCP = true; # interface name found via `ip link`
    };
  };
}

