{
  programs.nixvim = {
    plugins = {
      web-devicons.enable = true;

      bufferline.enable = true;

      lualine = {
        enable = true;

        settings = {
          options = {
            refresh.refresh_time = 64;
            theme = "wombat";
          };

          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" ];
            lualine_c = [
              "filename"
              "diff"
            ];
            lualine_x = [
              "diagnostics"
              {
                __unkeyed-1 = {
                  __raw = ''
                    function()
                        local msg = ""
                        local buf_ft = vim.bo[0].filetype
                        local clients = vim.lsp.get_clients({ bufnr = 0 })
                        if next(clients) == nil then
                            return msg
                        end
                        for _, client in ipairs(clients) do
                            local filetypes = client.config.filetypes
                            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                                return client.name
                            end
                        end
                        return msg
                    end
                  '';
                };
                color = {
                  fg = "#ffffff";
                };
                icon = "";
              }
              "encoding"
              "fileformat"
              "filetype"
            ];
            lualine_z = [ "location" ];
          };
        };
      };
    };

    # keymaps for bufferline's cmds
    keymaps = [
      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Move to next buffer";
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Move to previous buffer";
      }
      {
        mode = "n";
        key = "<leader><";
        action = "<cmd>BufferLineMovePrev<cr>";
        options.desc = "Move buffer left";
      }
      {
        mode = "n";
        key = "<leader>>";
        action = "<cmd>BufferLineMoveNext<cr>";
        options.desc = "Move buffer right";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Close current buffer";
      }
    ];
  };
}
