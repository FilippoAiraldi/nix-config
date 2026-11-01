{ config, ... }:
let
  inherit (config.flake.modules) generic nixos homeManager;
  commonImports = [
    generic.homeManagerIntegration
    generic.hostName
    generic.nixSettings
    generic.primaryUser
    generic.primaryUserHome
    generic.profile
    nixos.bash
    nixos.locale
    nixos.nixvim
    nixos.packages
    nixos.users
  ];
in
{
  flake.modules.generic.homeManagerIntegration = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ homeManager.base ];
    };
  };

  flake.modules.nixos.server = {
    imports = commonImports ++ [
      generic.localIPAddr
      nixos.ai-chat
      nixos.ai-chat-webui
      nixos.ai-decisions
      nixos.boot-server
      nixos.dns
      nixos.metasearch
      nixos.monitoring
      nixos.network-filesystem
      nixos.networking-server
      nixos.proxy
      nixos.power-cycle
      nixos.secrets-server
      nixos.services
    ];
  };

  flake.modules.nixos.private = {
    imports = commonImports;
  };

  flake.modules.nixos.private-desktop = {
    imports = commonImports ++ [
      nixos.boot-desktop
      nixos.networking-desktop
    ];
    home-manager.sharedModules = [ homeManager.pi-coding-agent ];
  };

  flake.modules.homeManager.base = {
    imports = [
      generic.profile
      homeManager.bash
      homeManager.eza
      homeManager.fzf
      homeManager.git
      homeManager.nixvim
      homeManager.packages
      homeManager.zellij
    ];
  };
}
