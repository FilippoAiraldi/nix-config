{
  flake.modules.nixos.boot = {
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
