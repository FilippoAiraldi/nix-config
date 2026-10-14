{
  flake.modules.nixos.display-manager =
    { config, pkgs, ... }:
    {
      # greetd (login manager) + tuigreet (greeter)
      # https://wiki.nixos.org/wiki/Greetd
      # https://ryjelsum.me/homelab/greetd-session-choose
      # https://man.sr.ht/~kennylevinsen/greetd
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session = {
          command = builtins.concatStringsSep " " [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--battery"
            "--remember"
            "--remember-session"
            "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
            "--theme \"${
              builtins.concatStringsSep ";" [
                "border=magenta"
                "prompt=magenta"
                "text=magenta"
              ]
            }\""
            "--time"
            "--title"
            "--user-menu"
          ];
          user = "greeter";
        };
      };
    };
}
