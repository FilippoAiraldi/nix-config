{ inputs, config, ... }:
let
  hmModules = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.mango =
    { config, pkgs, ... }:
    let
      sessions = config.services.displayManager.sessionData.desktops;
    in
    {
      imports = [ inputs.mango.nixosModules.mango ];

      # registers a "mango" session, selectable at login next to xfce
      programs.mango.enable = true;

      home-manager.sharedModules = [ hmModules.mango ];

      # greetd replaces lightdm as display manager
      services = {
        xserver.displayManager.lightdm.enable = false;
        greetd = {
          enable = true;
          settings.default_session = {
            command = builtins.concatStringsSep " " [
              "${pkgs.tuigreet}/bin/tuigreet"
              "--time"
              "--remember"
              "--remember-session"
              "--sessions ${sessions}/share/wayland-sessions"
              "--xsessions ${sessions}/share/xsessions"
              "--xsession-wrapper '${pkgs.xorg.xinit}/bin/startx /usr/bin/env'"
            ];
            user = "greeter";
          };
        };
      };
    };

  flake.modules.homeManager.mango =
    { pkgs, ... }:
    {
      imports = [ inputs.mango.hmModules.mango ];

      home.packages = with pkgs; [
        foot
        fuzzel
      ];

      # writes ~/.config/mango/config.conf, so /etc/mango is not needed
      wayland.windowManager.mango = {
        enable = true;
        settings = {
          bind = [
            "ALT,Return,spawn,foot"
            "ALT,space,spawn,fuzzel"
            "ALT,q,killclient,"
            "SUPER,m,quit"
            "SUPER,f,togglefullscreen,"
            "SUPER,r,reload_config"
            "ALT,Left,focusdir,left"
            "ALT,Right,focusdir,right"
            "ALT,Up,focusdir,up"
            "ALT,Down,focusdir,down"
          ]
          ++ builtins.concatLists (
            builtins.genList (
              i:
              let
                n = toString (i + 1);
              in
              [
                "Ctrl,${n},view,${n},0"
                "Alt,${n},tag,${n},0"
              ]
            ) 9
          );
        };
      };
    };
}
