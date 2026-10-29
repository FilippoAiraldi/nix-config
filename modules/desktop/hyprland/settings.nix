# HyprMod
# https://github.com/BlueManCZ/hyprmod
{ inputs, ... }:
{
  flake.modules.homeManager.settings =
    { isVM, pkgs, ... }:
    let
      hyprmod = inputs.hyprmod.packages.${pkgs.stdenv.hostPlatform.system}.default;
      hyprmod-wrapped = pkgs.symlinkJoin {
        name = "hyprmod-wrapped";
        paths = [ hyprmod ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hyprmod --set LIBGL_ALWAYS_SOFTWARE 1
        '';
      };
    in
    {
      home.packages = [ (if isVM then hyprmod-wrapped else hyprmod) ];
    };
}
