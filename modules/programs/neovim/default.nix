{
  flake.modules.homeManager.neovim =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        sideloadInitLua = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = false;

        extraPackages = with pkgs; [
          bash-language-server
          golangci-lint
          gopls
          gotools
          hadolint
          lua-language-server
          markdownlint-cli
          nixd
          nixfmt
          prettier
          pyright
          ruff
          shellcheck
          shfmt
          stylua
          tflint
          tofu-ls
          tree-sitter
          typescript-language-server
          vscode-langservers-extracted
          yaml-language-server
        ];
      };

      xdg.configFile = {
        "nvim" = {
          source = ./lazyvim;
          recursive = true;
        };
      };
    };
}
