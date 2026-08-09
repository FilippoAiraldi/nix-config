{
  flake.modules.generic.nixSettings = {
    nixpkgs.config.allowUnfree = false;

    nix = {
      channel.enable = false;

      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      optimise.automatic = true;
    };
  };
}
