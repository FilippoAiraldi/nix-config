{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  configurations.nixos.tud-vm.module = {
    imports = [
      ./_hardware.nix
      nixos.desktop
    ];

    hostName = "tud-vm";
    primaryUser = "fairaldi";
    system.stateVersion = "26.05";

    # just for enabling guest tools in the VM
    virtualisation.vmware.guest.enable = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
