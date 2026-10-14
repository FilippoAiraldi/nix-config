{ inputs, ... }:
{
  flake.modules.nixos.mango = {
    imports = [ inputs.mango.nixosModules.mango ];

    # registers a "mango" session in the display manager (e.g. lightdm),
    # selectable at login next to xfce
    programs.mango.enable = true;
  };
}
