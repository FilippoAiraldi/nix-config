{ lib, pkgs, ... }:
{
  programs.nixvim.plugins.lsp = {
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
}
