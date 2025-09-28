{ inputs, hostname, nixosModules, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    "${nixosModules}/common"
  ];

  networking.hostName = hostname;
}
