{
  flake.modules.nixos.zsh =
    { config, ... }:
    {
      programs.zsh = {
        enable = true;
        enableGlobalCompInit = false;
      };
      users.users.${config.primaryUser}.shell = config.programs.zsh.package;
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
