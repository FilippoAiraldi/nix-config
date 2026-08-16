{
  flake.modules.homeManager.fzf = {
    programs = {
      fzf = {
        enable = true;
        enableBashIntegration = true;

        defaultCommand = "fd --type f --hidden --follow --exclude .git";
        defaultOptions = [
          "--bind '?:toggle-preview'"
          "--bind 'ctrl-o:execute(nvim -- {+})'"
          "--height=40%"
          "--info=inline"
          "--multi"
          "--preview '( [[ -f {} ]] && (bat --line-range :200 --color=always --style=numbers,changes {} || head -200 {}) || [[ -d {} ]] && (eza -la --color=always --icons=always --group-directories-first {}) || ls -la --color=always {} || echo {} ) 2> /dev/null | head -200'"
        ];
      };

      bat.enable = true;
      eza.enable = true;
      fd.enable = true;
    };
  };
}
