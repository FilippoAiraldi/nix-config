{ inputs, ... }:
{
  flake.modules.homeManager.nixvim =
    {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ./_config/autocmds.nix
        ./_config/keymaps.nix
        ./_config/opts.nix
        ./_config/plugins/brackets.nix
        ./_config/plugins/colors.nix
        ./_config/plugins/comments.nix
        ./_config/plugins/fzf-lua.nix
        ./_config/plugins/lines.nix
        ./_config/plugins/lsp.nix
        ./_config/plugins/treesitter.nix
        ./_config/plugins/trouble.nix
        # ./_config/plugins/wildmenu.nix
      ];

      programs.nixvim = {
        enable = true;
        enableMan = true;
        defaultEditor = true;
      };
    };
}
