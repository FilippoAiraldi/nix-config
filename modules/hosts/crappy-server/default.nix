{ inputs, config, ... }:
let
  hostName = "crappy-server";
in
{
  configurations.nixos.${hostName}.module = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      ./_hardware.nix
      config.flake.modules.nixos.server
      config.flake.modules.generic.localIPaddr
    ];

    inherit hostName;
    localIPaddr = "192.168.68.100";
    primaryUser = "fairaldi";

    # Interface names found via `ip link`.
    # Wifi interface was soft-blocked; had to manually unblock it once via `sudo rfkill unblock wifi`.
    networkInterfaces = [
      "eno1"
      "wlo1"
    ];

    system.stateVersion = "26.05";

    # # support for nvidia gpu. since it's old, also the kernel must be quite old (https://nixos.wiki/wiki/Nvidia)
    # boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
    # hardware.graphics.enable = true;
    # services.xserver.videoDrivers = [ "nvidia" ];
    # hardware.nvidia = {
    #   modesetting.enable = true;
    #   open = false;
    #   nvidiaSettings = true;
    #   package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    # };
    # nixpkgs.config = {
    #   allowUnfree = true;
    #   nvidia.acceptLicense = true;
    # };
  };
}
