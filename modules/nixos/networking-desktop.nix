{
  flake.modules.nixos.networking =
    { config, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${config.primaryUser}.extraGroups = [ "networkmanager" ];
    };
}
