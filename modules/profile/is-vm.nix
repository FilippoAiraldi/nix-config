{
  flake.modules.generic.isVM =
    { lib, ... }:
    {
      options.isVM = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this system runs inside a virtual machine";
      };
    };
}
