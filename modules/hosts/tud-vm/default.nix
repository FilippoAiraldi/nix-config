{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos;
  hostName = "tud-vm";
in
{
  configurations.nixos.${hostName}.module = {
    imports = [
      ./_hardware.nix
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      nixos.desktop
      nixos.display-manager
      nixos.hyprland
      nixos.mango
      nixos.private
    ];

    inherit hostName;
    isVM = true;
    primaryUser = "fairaldi";
    system.stateVersion = "26.05";

    # settings required by the VM to work
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    hardware.graphics.enable = true;
    virtualisation.vmware.guest.enable = true;
  };
}
