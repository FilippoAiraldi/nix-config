{
  flake.modules.nixos.zsh =
    { config, pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        enableGlobalCompInit = false;
      };
      users.users.${config.primaryUser}.shell = pkgs.zsh;
    };

  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
      initContent = ''
        open() {
          xdg-open "$@" </dev/null >/dev/null 2>&1 &!
        }
      '';
    };
  };
}
