{
  flake.modules.generic.localIPaddr =
    { lib, ... }:
    {
      options.localIPaddr = lib.mkOption {
        type = lib.types.str;
        description = "Local IP address of this system";
      };
    };
}
