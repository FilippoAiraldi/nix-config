{
  programs.nixvim.plugins = {
    comment = {
      enable = true;

      settings = {
        ignore = "^$";
        padding = true;
        sticky = true;

        opleader = {
          line = "<leader>/";
        };
        toggler = {
          line = "<leader>/";
        };

        pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";

        # https://github.com/numToStr/Comment.nvim/discussions/299
        post_hook = ''
          function(ctx)
            local U = require("Comment.utils")
            if ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
              vim.cmd("norm! gv")
            end
          end
        '';
      };
    };

    ts-context-commentstring = {
      enable = true;
      settings.enable_autocmd = false;
    };
  };
}
