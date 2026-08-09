{
  inputs,
  lib,
  config,
  ...
}:
let
  mkConfigurationsOption =
    kind:
    lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options.module = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "${kind} module for this configuration";
          };
        }
      );
      default = { };
      description = "${kind} system configurations";
    };

  mkSystems =
    { builder, extraModules }:
    lib.mapAttrs (
      name: cfg:
      builder {
        modules = extraModules ++ [
          { networking.hostName = lib.mkDefault name; }
          cfg.module
        ];
      }
    );

  mkChecks =
    prefix:
    lib.mapAttrsToList (
      name: built: {
        ${built.config.nixpkgs.hostPlatform.system}."${prefix}-${name}" =
          built.config.system.build.toplevel;
      }
    );

  nixosConfigurations = mkSystems {
    builder = inputs.nixpkgs.lib.nixosSystem;
    extraModules = [ inputs.home-manager.nixosModules.home-manager ];
  } config.configurations.nixos;

  wslConfigurations = mkSystems {
    builder = inputs.nixpkgs.lib.nixosSystem;
    extraModules = [
      inputs.nixos-wsl.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      { wsl.enable = lib.mkDefault true; }
    ];
  } config.configurations.wsl;
in
{
  options.configurations = {
    nixos = mkConfigurationsOption "NixOS";
    wsl = mkConfigurationsOption "NixOS-WSL";
  };

  config.flake = {
    nixosConfigurations = lib.attrsets.unionOfDisjoint nixosConfigurations wslConfigurations;
    checks = lib.mkMerge (mkChecks "nixos" nixosConfigurations ++ mkChecks "wsl" wslConfigurations);
  };
}
