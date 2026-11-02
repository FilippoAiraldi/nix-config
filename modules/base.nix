{ config, ... }:
let
  inherit (config.flake.modules) generic nixos homeManager;
in
{
  flake.modules.nixos.common.imports = [
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

  flake.modules.nixos.private = {
    imports = [
      nixos.common
      nixos.ssh
    ];
    home-manager.sharedModules = [
      homeManager.pi-coding-agent
      homeManager.secrets
      homeManager.ssh
    ];
  };

  flake.modules.nixos.private-desktop.imports = [
    nixos.private
    nixos.boot-desktop
    nixos.networking-desktop
  ];

  flake.modules.nixos.server.imports = [
    nixos.common
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
    nixos.secrets
    nixos.services
  ];

  flake.modules.generic.homeManagerIntegration.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ homeManager.base ];
  };

  flake.modules.homeManager.base.imports = [
    generic.profile
    homeManager.bash
    homeManager.eza
    homeManager.fzf
    homeManager.git
    homeManager.nixvim
    homeManager.packages
    homeManager.zellij
  ];
}
