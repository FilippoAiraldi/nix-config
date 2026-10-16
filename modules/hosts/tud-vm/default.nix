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
      nixos.display-manager
      nixos.mango
      nixos.private
    ];

    inherit hostName;
    primaryUser = "fairaldi";
    system.stateVersion = "26.05";

    # just for enabling guest tools in the VM
    virtualisation.vmware.guest.enable = true;
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  };
}
