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
  };
}
