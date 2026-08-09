{ inputs, ... }:
{
  flake.modules.generic.nixSettings = {
    nixpkgs.config.allowUnfree = false;

    nix = {
      channel.enable = false;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      optimise.automatic = true;
    };
  };
}
