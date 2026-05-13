{ config, ... }:
let
  inherit (config.flake.modules) generic nixos homeManager;
  commonImports = [
    generic.homeManagerIntegration
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

  flake.modules.nixos.base = {
    imports = commonImports ++ [
      nixos.boot
      nixos.locale
      nixos.networking
      nixos.podman
      nixos.users
      nixos.zsh
    ];
  };

  flake.modules.homeManager.base = {
    imports = [
      generic.profile
      homeManager.atuin
      homeManager.aws
      homeManager.bat
      homeManager.brave
      homeManager.btop
      homeManager.eza
      homeManager.fastfetch
      homeManager.fzf
      homeManager.git
      homeManager.go
      homeManager.gpg
      homeManager.k8s
      homeManager.mos
      homeManager.neovim
      homeManager.opencode
      homeManager.opentofu
      homeManager.packages
      homeManager.podman
      homeManager.starship
      homeManager.tmux
      homeManager.xdg
      homeManager.zsh
    ];
  };
}
