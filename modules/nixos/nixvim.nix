{ inputs, ... }:
{
  flake.modules.nixos.nixvim =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.nixvim.nixosModules.nixvim ];

      programs.nixvim = {
        enable = true;
        enableMan = true;
        defaultEditor = true;

        opts = {
          number = true;
          relativenumber = true;

          tabstop = 4;
          softtabstop = 4;
          shiftwidth = 4;
          expandtab = true;
          smartindent = true;

          wrap = false;

          cursorline = true;
          colorcolumn = "88,100";

          swapfile = false;
          undofile = true;

          hlsearch = true;
          incsearch = true;

          wildmode = "list:longest";
          completeopt = "menu,menuone,noselect";

          termguicolors = true;

          scrolloff = 8;
          signcolumn = "yes";
        };

        globals.mapleader = " ";

        keymaps = [
          {
            mode = "n";
            key = "<leader>pv";
            action.__raw = "vim.cmd.Ex";
            options.desc = "Open explorer";
          }
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
          {
            mode = "n";
            key = "<leader>f";
            action.__raw = "vim.lsp.buf.format";
            options.desc = "Format file";
          }
          {
            mode = "n";
            key = "<leader>s";
            action = '':%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>'';
            options.desc = "Search and replace word under cursor";
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
        ];

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

        plugins.lsp = {
          enable = true;
          inlayHints = true;
          keymaps = {
            diagnostic = {
              "<leader>vd" = {
                action = "open_float";
                desc = "Line Diagnostics";
              };
              "[d" = {
                action = "goto_next";
                desc = "Next Diagnostic";
              };
              "]d" = {
                action = "goto_prev";
                desc = "Previous Diagnostic";
              };
            };
            lspBuf = {
              K = {
                action = "hover";
                desc = "Hover";
              };
              "<C-h>" = {
                mode = "i";
                action = "signature_help";
                desc = "Signature Help";
              };
              gd = {
                action = "definition";
                desc = "Goto Definition";
              };
              gD = {
                action = "declaration";
                desc = "Goto Declaration";
              };
              gI = {
                action = "implementation";
                desc = "Goto Implementation";
              };
              gT = {
                action = "type_definition";
                desc = "Type Definition";
              };
              gR = {
                action = "references";
                desc = "Goto References";
              };
              "<leader>ws" = {
                action = "workspace_symbol";
                desc = "Workspace Symbol";
              };
              "<leader>rn" = {
                action = "rename";
                desc = "Rename";
              };
            };
          };
          servers.nixd = {
            enable = true;
            settings.formatting.command = "${lib.getExe pkgs.nixfmt}";
          };
        };
      };
    };
}
