{
  flake.modules.nixos.networking =
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
          secretsFile = "/var/lib/secrets/wireless.conf";
          networks."Our Little Home v2".pskRaw = "ext:psk_home";
        };

        useDHCP = false;
        interfaces = lib.genAttrs config.networkInterfaces (_: {
          useDHCP = true;
        });
      };
    };
}
