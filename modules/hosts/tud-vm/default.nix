{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos;
  hostName = "tud-vm";
in
{
  configurations.nixos.${hostName}.module = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      ./_hardware.nix
      nixos.private
      nixos.xfce
    ];

    inherit hostName;
    primaryUser = "fairaldi";
    system.stateVersion = "26.05";

    # just for enabling guest tools in the VM
    virtualisation.vmware.guest.enable = true;
  };
}
