{
  programs = {
    # bat.enable = true;
    fd.enable = true;

    nixvim = {
      plugins = {
        web-devicons.enable = true;

        fzf-lua = {
          enable = true;
          settings.winopts.preview.default = "builtin"; # bat highlights not visible...
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>sf";
          action = "<cmd>FzfLua git_files --untracked=true<cr>";
          options.desc = "Find Git Files (root dir)";
        }
        {
          mode = "n";
          key = "<leader>sF";
          action = "<cmd>FzfLua files<cr>";
          options.desc = "Find Files (any dir)";
        }
        {
          mode = "n";
          key = "<leader><space>";
          action = "<cmd>FzfLua buffers<cr>";
          options.desc = "Find Buffers";
        }
        {
          mode = "n";
          key = "<leader>sg";
          action = "<cmd>FzfLua live_grep<cr>";
          options.desc = "Search Project";
        }
        {
          mode = "n";
          key = "<leader>ss";
          action = "<cmd>FzfLua lsp_document_symbols<cr>";
          options.desc = "Search Document Symbols";
        }
        {
          mode = "n";
          key = "<leader>sS";
          action = "<cmd>FzfLua lsp_live_workspace_symbols<cr>";
          options.desc = "Search Workspace Symbols";
        }
        {
          mode = "n";
          key = "<leader>sw";
          action = "<cmd>FzfLua grep_cword<cr>";
          options.desc = "Search Project for Current Word";
        }
        {
          mode = "n";
          key = "<leader>sW";
          action = "<cmd>FzfLua grep_cWORD<cr>";
          options.desc = "Search Project for Current WORD";
        }
        {
          mode = "n";
          key = "<leader>sh";
          action = "<cmd>FzfLua helptags<cr>";
          options.desc = "Search In Help";
        }
        {
          mode = "n";
          key = "<leader>sr";
          action = "<cmd>FzfLua resume<cr>";
          options.desc = "Resume Last Fzf Search";
        }
      ];
    };
  };
}
