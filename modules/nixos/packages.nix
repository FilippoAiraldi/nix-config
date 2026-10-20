{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.localBinInPath = true;

      # NOTE: these packages are available for all users on the system
      environment.systemPackages = with pkgs; [
        curl
        dig
        dnsutils
        fd
        gnumake
        htop
        jq
        just
        nixfmt
        ripgrep
        wget
        wl-clipboard
        xclip
        zellij
      ];

      # make neovim the Man's pager (nixvim is installed for all users; see modules/base.nix)
      environment.sessionVariables.MANPAGER = "nvim --clean +Man!";

      programs.git = {
        enable = true;
        config.alias.lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };
    };
}
