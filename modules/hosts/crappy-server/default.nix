{ inputs, config, ... }:
{
  configurations.nixos.crappy-server.module = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      ./_hardware.nix
      config.flake.modules.nixos.base
    ];

    primaryUser = "fairaldi";

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
