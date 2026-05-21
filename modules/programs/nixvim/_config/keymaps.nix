{
  programs.nixvim = {
    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<leader>pv";
        action.__raw = "vim.cmd.Ex";
        options.desc = "Open explorer";
      }
      ##########################################################################
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selected lines down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selected lines up";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
        options.desc = "Jump down while keeping cursor centered";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
        options.desc = "Jump up while keeping cursor centered";
      }
      {
        mode = "n";
        key = "<PageDown>";
        action = "<PageDown>zz";
        options.desc = "Jump down while keeping cursor centered";
      }
      {
        mode = "n";
        key = "<PageUp>";
        action = "<PageUp>zz";
        options.desc = "Jump up while keeping cursor centered";
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
        options.desc = "Search while keeping cursor centered";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
        options.desc = "Search while keeping cursor centered";
      }
      {
        mode = "n";
        key = "<leader>a";
        action.__raw = ''
          function()
            vim.fn.setpos("'''", vim.fn.getpos('.'))
            vim.cmd('keepjumps normal! ggVG')
          end
        '';
        options.desc = "Select all";
      }
      ########################################################################
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Yank to system register";
      }
      {
        mode = "n";
        key = "<leader>Y";
        action = "\"+Y";
        options.desc = "Yank line to system register";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>d";
        action = "\"_d";
        options.desc = "Deleting to void register";
      }
      ##########################################################################
      {
        mode = "n";
        key = "<leader>s";
        action = '':%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>'';
        options.desc = "Search and replace word under cursor";
      }
      {
        mode = "n";
        key = "<leader>f";
        action.__raw = "vim.lsp.buf.format";
        options.desc = "Format file";
      }
      ##########################################################################
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>cprev<CR>zz";
        options.desc = "Quickfix: go to previous entry";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>cnext<CR>zz";
        options.desc = "Quickfix: go to next entry";
      }
      {
        mode = "n";
        key = "<leader>k";
        action = "<cmd>lprev<CR>zz";
        options.desc = "Location list: go to previous entry";
      }
      {
        mode = "n";
        key = "<leader>j";
        action = "<cmd>lnext<CR>zz";
        options.desc = "Location list: go to next entry";
      }
    ];
  };
}
