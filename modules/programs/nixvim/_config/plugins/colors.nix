{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "lytmode-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "github-main-user";
          repo = "lytmode.nvim";
          rev = "9ceaa04525edcc9dadfa7ff5cb835e7f49cfc71d";
          hash = "sha256-rC3WJY0+9c8YBHej3KsXOyLFCPVOaU61F8VfhzJzf4o=";
        };
      })
    ];

    colorscheme = "lytmode";
  };
}
