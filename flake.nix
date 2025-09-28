{
  description = "NixOS config for my machines";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      catppuccin,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Define user configurations
      users = {
        fairaldi = {
          avatar = ./files/avatar/face;
          email = "filippoairaldi@gmail.com";
          fullName = "Filippo Airaldi";
          gitKey = "C5810093";
          name = "fairaldi";
        };
      };

      # Function for NixOS system configuration
      mkNixosConfiguration =
        hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            nixosModules = "${self}/modules/nixos";
          };
          modules = [ ./hosts/${hostname} ];
        };

      # Function for Home Manager configuration
      mkHomeConfiguration =
        system: username: hostname:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {
            inherit inputs outputs;
            userConfig = users.${username};
            nhModules = "${self}/modules/home-manager";
          };
          modules = [
            ./home/${username}/${hostname}
            catppuccin.homeModules.catppuccin
          ];
        };
    in
    {
      nixosConfigurations = {
        "crappy-server" = mkNixosConfiguration "crappy-server" "fairaldi";
      };

      homeConfigurations = {
        "fairaldi@crappy-server" = mkHomeConfiguration "x86_64-linux" "fairaldi" "crappy-server";
      };

      overlays = import ./overlays { inherit inputs; };
    };
}
