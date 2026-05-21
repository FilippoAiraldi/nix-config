{
  programs.nixvim = {
    autoGroups.custom_autogroup.clear = true;

    autoCmd = [
      {
        event = "BufWritePre";
        group = "custom_autogroup";
        pattern = "*";
        callback.__raw = ''
          function()
            local view = vim.fn.winsaveview()
            vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])
            vim.fn.winrestview(view)
          end
        '';
        desc = "Remove trailing whitespaces";
      }
      {
        event = "TextYankPost";
        group = "custom_autogroup";
        pattern = "*";
        callback.__raw = ''
          function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 40 })
          end
        '';
        desc = "Highlight yanked text";
      }
    ];
  };
}
