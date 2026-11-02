{
  flake.modules.nixos.networking-desktop =
    { config, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${config.primaryUser}.extraGroups = [ "networkmanager" ];
    };

  flake.modules.nixos.networking-server =
    { config, lib, ... }:
    {
      options.networkInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Network interfaces the firewall opens ports on (see `ip link`)";
        example = [
          "eno1"
          "wlo1"
        ];
      };

      config.networking = {
        wireless = {
          enable = true;
          secretsFile = config.sops.secrets.wireless.path;
          networks."Our Little Home v2".pskRaw = "ext:psk_home";
        };

        useDHCP = false;
        interfaces = lib.genAttrs config.networkInterfaces (_: {
          useDHCP = true;
        });
      };
    };
}
