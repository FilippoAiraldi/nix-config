{ config, pkgs, ... }:
{
  programs.nixvim = {
    # treesitter
    plugins.treesitter = {
      enable = true;

      folding.enable = true;
      highlight.enable = true;
      indent.enable = true;

      grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
        bash
        bibtex
        c
        cmake
        comment
        cpp
        csv
        diff
        html
        json
        just
        latex
        lua
        markdown
        matlab
        nix
        python
        regex
        toml
        vimdoc
        xml
        yaml
      ];
    };
    opts = {
      foldlevel = 99;
      foldlevelstart = 99;
    };

    # treesitter-context
    plugins.treesitter-context = {
      enable = true;

      luaConfig.post = ''
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
        vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })
      '';
    };

    # wildfire.nvim
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "wildfire-nvim";
        version = "2026-05-27";
        src = pkgs.fetchFromGitHub {
          owner = "sustech-data";
          repo = "wildfire.nvim";
          rev = "918a1873c2b8010baa034f373cf28c53ce4f038f";
          hash = "sha256-HGNBUuUFtZU9ozFsM0X5QadfnK+cEiosQfnnrI6bdtI=";
        };
      })
    ];
    extraConfigLua = ''
      require("wildfire").setup()
    '';
  };
}
