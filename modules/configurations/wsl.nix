{
  inputs,
  lib,
  config,
  ...
}:
{
  options.configurations.wsl = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
          default = { };
          description = "NixOS-WSL module for this configuration";
        };
      }
    );
    default = { };
    description = "NixOS WSL configurations";
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (
      name: cfg:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            networking.hostName = lib.mkDefault name;
            wsl.enable = lib.mkDefault true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }
          cfg.module
        ];
      }
    ) config.configurations.wsl;

    checks = lib.concatMapAttrs (
      name: cfg:
      let
        wslSys = config.flake.nixosConfigurations.${name};
        inherit (wslSys.config.nixpkgs.hostPlatform) system;
      in
      {
        ${system} = {
          "wsl-${name}" = wslSys.config.system.build.toplevel;
        };
      }
    ) config.configurations.wsl;
  };
}
