{
  flake.modules.nixos.networking-desktop =
    { config, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${config.primaryUser}.extraGroups = [ "networkmanager" ];
    };
}
