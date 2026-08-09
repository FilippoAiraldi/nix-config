{ config, ... }:
{
  configurations.wsl.tud-wsl.module =
    let
      primaryUser = "fairaldi";
    in
    {

      imports = [
        config.flake.modules.nixos.wsl
      ];
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.11";

      # https://nix-community.github.io/NixOS-WSL/how-to/change-username.html
      primaryUser = primaryUser;
      wsl.defaultUser = primaryUser;
      users.users.${primaryUser}.uid = 1001; # solves a bug; found via `id -u fairaldi`
    };
}
