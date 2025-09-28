{ inputs, hostname, nixosModules, config, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    "${nixosModules}/common"
  ];

  networking.hostName = hostname;

  # To support old GPU, the kernel must also be quite old
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  # Enable NVIDIA GPU (https://nixos.wiki/wiki/Nvidia)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
}
