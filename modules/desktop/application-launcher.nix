# Walker
# https://github.com/abenz1267/walker
{
  flake.modules.homeManager.application-launcher =
    {
      config,
      isVM,
      lib,
      pkgs,
      ...
    }:
    {
      options.desktop = {
        appLauncherCmd = lib.mkOption {
          type = lib.types.str;
          description = "Command to toggle the app launcher";
        };
        hyprlandKeybindsMenuCmd = lib.mkOption {
          type = lib.types.str;
          description = "Command to show the Hyprland keybinds menu";
        };
      };
      config =
        let
          pkg = pkgs.walker;
          providers = [
            "calc" # =
            "clipboard" # :
            "desktopapplications"
            "files" # /
            "menus"
            "providerlist" # ;
            "runner"
            "symbols" # .
            "unicode" # ,
          ];
          hyprlandKeybindsMenu = pkgs.writeShellApplication {
            name = "hypr-keybinds";
            text = with pkgs; ''
              ${lib.getExe' hyprland "hyprctl"} -j binds | ${lib.getExe jq} -r '
                def mods: . as $m
                  | [[1,"SHIFT"],[4,"CTRL"],[8,"ALT"],[64,"SUPER"]]
                  | map(select(($m / .[0] | floor) % 2 == 1) | .[1]);
                .[] | select(.description != "")
                | ((.modmask | mods) + [.key] | join(" + ")) + "\t" + .description
              ' | ${lib.getExe' util-linux "column"} -t -s $'\t' \
                | ${lib.getExe pkg} --dmenu --placeholder 'Keybinds' || true
            '';
          };
        in
        {
          desktop = {
            appLauncherCmd = "nc -U \"$XDG_RUNTIME_DIR/walker/walker.sock\"";
            hyprlandKeybindsMenuCmd = lib.getExe hyprlandKeybindsMenu;
          };

          systemd.user.services.walker.Service.Environment = lib.mkIf isVM [ "LIBGL_ALWAYS_SOFTWARE=1" ];

          services = {
            elephant = {
              enable = true;
              package = pkgs.elephant.override { enabledProviders = providers; };
            };

            walker = {
              enable = true;
              package = pkg;
              enableElephantIntegration = true;
              systemd.enable = true;

              settings.providers = {
                empty = [ "desktopapplications" "runner" ];
                prefixes = [
                  {
                    provider = "unicode";
                    prefix = ",";
                  }
                ];
              };

              theme =
                let
                  inherit (config.profile.appearance) border;
                  inherit (config.lib.stylix) colors;
                  inherit (config.stylix) fonts;
                in
                {
                  name = "stylix";
                  style = with colors.withHashtag; ''
                    * {
                      font-family: "${fonts.monospace.name}";
                      font-size: ${toString fonts.sizes.popups}pt;
                      color: ${base05};
                      text-shadow: none;
                      box-shadow: none;
                      transition: none;
                      animation: none;
                    }
                    .window,
                    .box-wrapper {
                      background: alpha(${base00}, 0.89);
                      border: ${toString border.width}px solid ${base0E};
                      border-radius: ${toString border.radius}px;
                      padding: 12px;
                    }
                    .window {
                      background: transparent;
                      border: none;
                      padding: 0;
                    }
                    .search-container,
                    .input {
                      background: ${base01};
                      border-radius: ${toString border.radius}px;
                      padding: 6px 10px;
                    }
                    .input {
                      padding: 0;
                      caret-color: ${base0E};
                    }
                    .input placeholder {
                      color: ${base03};
                    }
                    .list,
                    .preview,
                    .content-container {
                      background: transparent;
                    }
                    .item-box {
                      background: transparent;
                      border-radius: ${toString border.radius}px;
                      padding: 6px 10px;
                    }
                    child:hover .item-box,
                    child:selected .item-box,
                    .item-box:selected {
                      background: alpha(${base02}, 0.8);
                    }
                    .item-text,
                    .item-text-box {
                      color: ${base05};
                    }
                    .item-subtext {
                      color: ${base04};
                      font-size: ${toString fonts.sizes.desktop}pt;
                    }
                    .keybind-bind,
                    .keybind-label,
                    .elephant-hint,
                    .placeholder {
                      color: ${base03};
                    }
                    scrollbar,
                    scrollbar slider {
                      background: transparent;
                      min-width: 0;
                    }
                  '';
                };
            };
          };

        };
    };
}
