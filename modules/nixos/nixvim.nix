{ inputs, ... }:
{
  flake.modules.nixos.nixvim = {
    imports = [
      inputs.nixvim.nixosModules.nixvim
      ../programs/nixvim/_config/autocmds.nix
      ../programs/nixvim/_config/keymaps.nix
      ../programs/nixvim/_config/opts.nix
      ../programs/nixvim/_config/plugins/lsp.nix
    ];

    programs.nixvim = {
      enable = true;
      enableMan = true;
      defaultEditor = true;
    };
  };
}
