{
  flake.modules.nixos.bash =
    { config, pkgs, ... }:
    {
      programs.bash.enable = true;
      users.users.${config.primaryUser}.shell = pkgs.bash;
    };

  flake.modules.homeManager.bash = {
    programs = {
      bash = {
        enable = true;
        shellAliases = {
          ls = "eza"; # default view
          ll = "eza -bhl"; # long list
          la = "eza -abhl"; # all list
          lt = "eza --tree --level=2"; # tree
        };
      };
    };
  };
}
