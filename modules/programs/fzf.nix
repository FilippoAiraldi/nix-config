{
  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;

      historyWidget.command = "";

      defaultOptions = [
        "--bind '?:toggle-preview'"
        "--bind 'ctrl-e:execute(nvim -- {+})'"
        "--bind 'ctrl-y:execute-silent(printf \"%s\\n\" {+} | wl-copy)'"
        "--height=40%"
        "--info=inline"
        "--layout=reverse"
        "--marker='✓'"
        "--pointer='▶'"
        "--prompt='~ '"
      ];
    };
  };
}
