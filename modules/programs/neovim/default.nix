{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        sideloadInitLua = true;
        vimAlias = true;

        extraPackages = with pkgs; [
          bash-language-server
          eslint
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
    };
}
