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
          networks."Our Little Home v2".pskRaw =
            "2db8f93ad41eee0811d4047b8c0a9201145b0d1932e0df714136a0f68fd71f4b";
        };
        useDHCP = false;

        interfaces = lib.genAttrs config.networkInterfaces (_: {
          useDHCP = true;
        });
      };
    };
}
