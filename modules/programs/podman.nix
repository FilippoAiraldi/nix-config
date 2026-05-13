{
  flake.modules.nixos.podman = {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  flake.modules.homeManager.podman =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        podman-compose
        podman-tui
      ];

      programs.zsh.shellAliases.pt = "podman-tui";
    };
}
