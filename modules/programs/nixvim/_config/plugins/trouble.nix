{
  programs.nixvim = {
    plugins.trouble.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Toggle Trouble";
      }
      {
        mode = "n";
        key = "[t";
        action = "<cmd>Trouble diagnostics next<cr>";
        options.desc = "Next Trouble item";
      }
      {
        mode = "n";
        key = "]t";
        action = "<cmd>Trouble diagnostics prev<cr>";
        options.desc = "Previous Trouble item";
      }
    ];
  };
}
