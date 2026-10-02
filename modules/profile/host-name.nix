{
  flake.modules.generic.hostName =
    { config, lib, ... }:
    {
      options.hostName = lib.mkOption {
        type = lib.types.str;
        description = "Host name of this system";
      };

      config.networking.hostName = config.hostName;
    };
}
