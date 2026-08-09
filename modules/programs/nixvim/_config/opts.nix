{
  programs.nixvim.opts = {
    number = true;
    relativenumber = true;

    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    smartindent = true;

    wrap = false;

    cursorline = true;
    colorcolumn = "79,88,100";

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
}
