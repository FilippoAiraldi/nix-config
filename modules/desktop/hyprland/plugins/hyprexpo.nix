{ inputs, ... }:
{
  flake.modules.homeManager.hyprexpo =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hyprexpo = pkgs.callPackage "${inputs.hyprexpo}/default.nix" {
        hyprland = config.wayland.windowManager.hyprland.package;
      };
    in
    {
      wayland.windowManager.hyprland = {
        plugins = [ hyprexpo ];

        configType = "lua";
        settings =
          let
            launchFn = "function() hl.plugin.hyprexpo.expo('toggle') end";
          in
          {
            bind = [
              {
                _args = [
                  "SUPER + G"
                  (lib.generators.mkLuaInline launchFn)
                ];
              }
            ];
            gesture = [
              (lib.generators.mkLuaInline ''
                {
                  fingers = 4,
                  direction = "up",
                  action = ${launchFn}
                }
              '')
            ];
          };
      };
    };
}
