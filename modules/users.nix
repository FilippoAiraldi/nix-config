{
  flake.modules.nixos.users =
    { config, ... }:
    {
      users.users.${config.primaryUser} = {
        description = config.profile.fullName;
        extraGroups = [ "wheel" ];
        isNormalUser = true;
      };
    };
}
