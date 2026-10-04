{
  flake.modules.generic.localIPAddr =
    { lib, ... }:
    {
      options.localIPAddr = lib.mkOption {
        type = lib.types.str;
        description = "Local IP address of this system";
        example = "192.168.68.100";
      };
    };
}
