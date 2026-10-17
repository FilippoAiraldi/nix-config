{
  flake.modules.nixos.boot-desktop =
    { pkgs, ... }:
    {
      boot = {
        loader = {
          timeout = 3;
          efi.canTouchEfiVariables = false; # `true` conflicts with limine being attempted to be re-registered as a EFI entry

          limine = {
            enable = true;
            extraConfig = ''
              terse: yes
              quiet: yes
            '';
            style.interface.branding = "NixOS";
          };
        };

        # https://wiki.nixos.org/wiki/Plymouth
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet" # suppress most text before plymouth starts
          "splash" # use a splash instead of blank screen (for plymouth)
          "rd.udev.log_level=3" # drop user-space messages (excluding errors)
          "rd.systemd.show_status=auto"
        ];

        plymouth = {
          enable = true;
          theme = "spinner_alt";
          themePackages = with pkgs; [
            (adi1090x-plymouth-themes.override { selected_themes = [ "spinner_alt" ]; })
          ];
        };
      };
    };

  flake.modules.nixos.boot-server = {
    boot = {
      consoleLogLevel = 4;
      kernelParams = [ "pcie_aspm=off" ]; # ensure system doesn't try to autosuspend Ethernet controller
      loader = {
        limine.enable = true;
        efi.canTouchEfiVariables = false; # `true` conflicts with limine being attempted to be re-registered as a EFI entry
        timeout = 5;
      };
    };
  };
}
