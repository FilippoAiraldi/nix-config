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
      nixos.bash
      nixos.boot-server
      nixos.dns
      nixos.locale
      nixos.metasearch
      nixos.monitoring
      nixos.network-filesystem
      nixos.networking-server
      nixos.nixvim
      nixos.packages
      nixos.proxy
      nixos.power-cycle
      nixos.services
      nixos.users
    ];
  };

  flake.modules.nixos.private = {
    imports = commonImports ++ [
      nixos.bash
      nixos.boot-desktop
      nixos.locale
      nixos.networking-desktop
      nixos.nixvim
      nixos.packages
      nixos.users
    ];
  };

  flake.modules.nixos.wsl = {
    imports = commonImports ++ [
      nixos.bash
      nixos.locale
      nixos.nixvim
      nixos.packages
      nixos.users
    ];
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
