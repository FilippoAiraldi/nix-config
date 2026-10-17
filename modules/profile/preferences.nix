{
  flake.modules.generic.profile =
    { lib, pkgs, ... }:
    {
      options.profile = lib.mkOption {
        readOnly = true;
        type = lib.types.raw;
        description = "Personal settings shared across all hosts and both module classes.";
      };

      config.profile = {
        email = "filippoairaldi@gmail.com";
        fullName = "Filippo Airaldi";
        locale = {
          timezone = "Europe/Amsterdam";
          default = "en_US.UTF-8";
          extra = {
            LC_ADDRESS = "en_IE.UTF-8";
            LC_IDENTIFICATION = "en_IE.UTF-8";
            LC_MEASUREMENT = "en_IE.UTF-8";
            LC_MONETARY = "en_IE.UTF-8";
            LC_NAME = "en_IE.UTF-8";
            LC_NUMERIC = "en_IE.UTF-8";
            LC_PAPER = "en_IE.UTF-8";
            LC_TELEPHONE = "en_IE.UTF-8";
            LC_TIME = "en_IE.UTF-8";
          };
        };
        appearance = {
          border = {
            radius = 3;
            width = 3;
          };
          fonts = {
            monospace = {
              name = "JetBrainsMono Nerd Font";
              package = pkgs.nerd-fonts.jetbrains-mono;
            };
            sansSerif = {
              name = "Inter";
              package = pkgs.inter;
            };
            sizes = {
              applications = 12;
              desktop = 12;
            };
          };
        };
      };
    };
}
