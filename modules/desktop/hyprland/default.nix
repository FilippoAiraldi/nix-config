# Hyprland
# https://wiki.nixos.org/wiki/Hyprland
{ config, ... }:
let
  inherit (config.flake.modules) homeManager nixos;
in
{
  flake.modules.nixos.hyprland =
    { config, pkgs, ... }:
    {
      imports = [ nixos.lock-screen ];

      environment.systemPackages = with pkgs; [ wlr-randr ];
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      # load homeManager.hyprland with special arg `isVM`
      home-manager.extraSpecialArgs = {
        inherit (config) isVM;
      };
      home-manager.sharedModules = [ homeManager.hyprland ];
    };

  flake.modules.homeManager.hyprland =
    {
      isVM,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        homeManager.control-center
        homeManager.cursor
        homeManager.hyprexpo
        homeManager.settings
        homeManager.status-bar
      ];

      wayland.windowManager.hyprland =
        let
          lua = lib.generators.mkLuaInline;
          mkArgs = args: { _args = args; };
          mkVar = var: { _var = var; };

          inherit (config.profile.appearance) border;
          rescaleFactor = "1.1";
          directions = [
            {
              name = "left";
              x = "-50";
              y = "0";
            }
            {
              name = "right";
              x = "50";
              y = "0";
            }
            {
              name = "up";
              x = "0";
              y = "-50";
            }
            {
              name = "down";
              x = "0";
              y = "50";
            }
          ];

          clipBridge = pkgs.writeShellScript "clip-bridge" ''
            export PATH=${
              lib.makeBinPath [
                pkgs.wl-clipboard
                pkgs.xclip
                pkgs.clipnotify
                pkgs.coreutils
              ]
            }:$PATH

            # wayland to x11
            wl-paste --watch sh -c '
              new=$(cat)
              [ "$new" = "$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null)" ] && exit 0
              printf "%s" "$new" | xclip -selection clipboard -i -t UTF8_STRING
            ' &

            # x11 to wayland
            while clipnotify -s clipboard; do
              new=$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null) || continue
              [ "$new" = "$(wl-paste -n 2>/dev/null)" ] && continue
              printf '%s' "$new" | wl-copy
            done
          '';
          startupCmds = [
            "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill"
          ]
          ++ lib.optionals isVM [
            "${clipBridge}"
            "env GDK_BACKEND=x11 ${pkgs.open-vm-tools}/bin/vmtoolsd -n vmusr"
          ];
          shutdownCmd =
            if isVM then "hl.dsp.exit()" else "hl.dsp.exec_cmd('${lib.getExe pkgs.hyprshutdown}')";
        in
        {
          enable = true;
          systemd.enable = false; # conflicts with `withUWSM = true`

          configType = "lua";
          settings = {
            # https://wiki.hypr.land/configuring/core/config-options
            config = {
              animations.enabled = false;
              general = {
                border_size = border.width;
                gaps_in = 2;
                gaps_out = 5;
                resize_on_border = true;
              };
              decoration = {
                blur.enabled = false;
                rounding = border.radius;
                shadow.enabled = false;
              };
              input = {
                kb_layout = "us,it";
                kb_options = "grp:win_space_toggle";
                repeat_delay = 500;
                touchpad.middle_button_emulation = true;
              };

              # https://wiki.hypr.land/configuring/layouts/dwindle-layout
              dwindle = {
                force_split = 2;
                preserve_split = true;
                smart_split = false;
              };
            };

            # https://wiki.hypr.land/configuring/core/monitors
            monitor = {
              output = "Virtual-1";
              mode = "2558x1238@60";
              # mode = "2560x1440@60";
              position = "0x0";
              scale = 1.0;
            };

            # https://wiki.hypr.land/configuring/core/autostart
            on = mkArgs [
              "hyprland.start"
              (lua ''
                function()
                ${lib.concatMapStringsSep "\n" (cmd: "  hl.exec_cmd('${cmd}')") startupCmds}
                end
              '')
            ];

            # general keyboard shortcuts
            # https://wiki.hypr.land/configuring/core/binds
            # https://wiki.hypr.land/configuring/core/dispatchers
            mod = mkVar "SUPER";
            rescale_active_monitor = mkVar (lua ''
              function(dir)
                local factor = ${rescaleFactor}
                local monitor = hl.get_active_monitor()
                local scale = (dir == "down") and monitor.scale / factor or monitor.scale * factor
                scale = tonumber(string.format("%.2f", scale))
                hl.monitor({ output = monitor.name, scale = scale })
              end
            '');
            bind = map mkArgs (
              [
                # general & window management
                [
                  (lua "mod .. ' + R'")
                  (lua "hl.dsp.exec_cmd('hyprctl reload')")
                  { description = "Reload config"; }
                ]
                [
                  (lua "mod .. ' + M'")
                  (lua shutdownCmd)
                  { description = "Exit Hyprland"; }
                ]
                [
                  (lua "mod .. ' + L'")
                  (lua "hl.dsp.exec_cmd('${config.desktop.lockScreenCmd}')")
                  { description = "Lock screen"; }
                ]
                [
                  (lua "mod .. ' + I'")
                  (lua "hl.dsp.exec_cmd('${config.desktop.controlCenterCmd}')")
                  { description = "Control center"; }
                ]
                [
                  "ALT + Q"
                  (lua "hl.dsp.window.close()")
                  { description = "Close window"; }
                ]
                [
                  "SHIFT + ALT + Q"
                  (lua "hl.dsp.window.kill()")
                  { description = "Kill window"; }
                ]
                [
                  "ALT + RETURN"
                  (lua "hl.dsp.exec_cmd('${config.desktop.terminalCmd}')")
                  { description = "Open terminal"; }
                ]
                [
                  "ALT + SPACE"
                  (lua "hl.dsp.exec_cmd('${config.desktop.appLauncherCmd}')")
                  { description = "Toggle app launcher"; }
                ]
                [
                  (lua "mod .. ' + MINUS'")
                  (lua "function() rescale_active_monitor('down') end")
                  { description = "Scale monitor down"; }
                ]
                [
                  (lua "mod .. ' + EQUAL'")
                  (lua "function() rescale_active_monitor('up') end")
                  { description = "Scale monitor up"; }
                ]
                [
                  (lua "mod .. ' + H'")
                  (lua "hl.dsp.exec_cmd('${config.desktop.hyprlandKeybindsMenuCmd}')")
                  { description = "Show keybinds"; }
                ]

                # window focus, movement & resizing
                [
                  "ALT + TAB"
                  (lua ''
                    function()
                      hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
                      hl.dispatch(hl.dsp.window.bring_to_top())
                    end
                  '')
                  { description = "Focus next window"; }
                ]
                [
                  "SHIFT + ALT + TAB"
                  (lua ''
                    function()
                      hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
                      hl.dispatch(hl.dsp.window.bring_to_top())
                    end
                  '')
                  { description = "Focus previous window"; }
                ]
                [
                  "ALT + A"
                  (lua "hl.dsp.window.fullscreen({ mode = 'maximized' })")
                  { description = "Toggle maximized"; }
                ]
                [
                  "ALT + F"
                  (lua "hl.dsp.window.fullscreen({ mode = 'fullscreen' })")
                  { description = "Toggle fullscreen"; }
                ]
              ]
              ++ lib.concatMap (
                dir:
                let
                  key = lib.toUpper dir.name;
                in
                [
                  [
                    "ALT + ${key}"
                    (lua "hl.dsp.focus({ direction = '${dir.name}' })")
                    { description = "Focus window ${dir.name}"; }
                  ]
                  [
                    "SHIFT + ALT + ${key}"
                    (lua "hl.dsp.window.move({ direction = '${dir.name}' })")
                    { description = "Move window ${dir.name}"; }
                  ]
                  [
                    "CTRL + ALT + ${key}"
                    (lua "hl.dsp.window.resize({ x = ${dir.x}, y = ${dir.y}, relative = true })")
                    { description = "Resize window ${dir.name}"; }
                  ]
                ]
              ) directions
              # workspaces
              ++ lib.concatMap (
                i:
                let
                  n = toString i;
                in
                [
                  [
                    "CTRL + ${n}"
                    (lua "hl.dsp.focus({ workspace = ${n} })")
                    { description = "Go to workspace ${n}"; }
                  ]
                  [
                    "ALT + ${n}"
                    (lua "hl.dsp.window.move({ workspace = ${n}, follow = true })")
                    { description = "Move window to workspace ${n}"; }
                  ]
                ]
              ) (lib.range 1 9)
              ++ [
                [
                  "CTRL + LEFT"
                  (lua "hl.dsp.focus({ workspace = 'e-1' })")
                  { description = "Previous non-empty workspace"; }
                ]
                [
                  "CTRL + RIGHT"
                  (lua "hl.dsp.focus({ workspace = 'e+1' })")
                  { description = "Next non-empty workspace"; }
                ]
                # dwindle layout
                [
                  "SHIFT + ALT + RETURN"
                  (lua "hl.dsp.layout('togglesplit')")
                  { description = "Toggle split direction"; }
                ]
                # mouse and trackpad gestures
                # https://wiki.hypr.land/configuring/core/binds/devices/mouse
                # https://wiki.hypr.land/configuring/core/binds/gestures
                [
                  (lua "mod .. ' + mouse_up'")
                  (lua "hl.dsp.focus({ workspace = 'e-1' })")
                  { description = "Scroll to previous non-empty workspace"; }
                ]
                [
                  (lua "mod .. ' + mouse_down'")
                  (lua "hl.dsp.focus({ workspace = 'e+1' })")
                  { description = "Scroll to next non-empty workspace"; }
                ]
                [
                  (lua "mod .. ' + mouse:272'")
                  (lua "hl.dsp.window.drag()")
                  {
                    mouse = true;
                    description = "Drag window with left mouse button";
                  }
                ]
                [
                  (lua "mod .. ' + mouse:273'")
                  (lua "hl.dsp.window.resize()")
                  {
                    mouse = true;
                    description = "Resize window with right mouse button";
                  }
                ]
                [
                  (lua "mod .. ' + mouse:274'")
                  (lua "hl.dsp.window.close()")
                  { description = "Close window with middle mouse button"; }
                ]
                [
                  (lua "mod .. ' + SHIFT + mouse:274'")
                  (lua "hl.dsp.window.kill()")
                  { description = "Kill window with shift + middle mouse button"; }
                ]
              ]
            );
            gesture = map (g: mkArgs [ g ]) [
              {
                fingers = 3;
                direction = "horizontal";
                action = "workspace";
              }
              {
                fingers = 3;
                direction = "up";
                mods = "SUPER";
                scale = 1.5;
                action = "fullscreen";
              }
            ];
          };
        };
    };
}
