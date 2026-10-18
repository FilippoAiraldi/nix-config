# Hyprland
# https://wiki.nixos.org/wiki/Hyprland
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ homeManager.hyprland ];
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
      environment.systemPackages = with pkgs; [ wlr-randr ];
    };

  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
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
            "${clipBridge}" # TODO: remove outside a VM
            "env GDK_BACKEND=x11 ${pkgs.open-vm-tools}/bin/vmtoolsd -n vmusr" # TODO: remove outside a VM
            "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill"
          ];
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
                  (lua "mod .. ' + R'") # reload configuration
                  (lua "hl.dsp.exec_cmd('hyprctl reload')")
                ]
                [
                  (lua "mod .. ' + M'") # elegant quit
                  (lua "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
                ]
                [
                  "ALT + Q" # close window
                  (lua "hl.dsp.window.close()")
                ]
                [
                  "SHIFT + ALT + Q" # kill window
                  (lua "hl.dsp.window.kill()")
                ]
                [
                  "ALT + RETURN" # launch terminal
                  (lua "hl.dsp.exec_cmd('${config.desktop.terminalCmd}')")
                ]
                [
                  "ALT + SPACE" # toggle application launcher
                  (lua "hl.dsp.exec_cmd('pkill ${config.desktop.appLauncherName} || ${config.desktop.appLauncherCmd}')")
                ]
                [
                  (lua "mod .. ' + MINUS'") # scale active monitor down
                  (lua "function() rescale_active_monitor('down') end")
                ]
                [
                  (lua "mod .. ' + EQUAL'") # scale active monitor up
                  (lua "function() rescale_active_monitor('up') end")
                ]

                # window focus, movement & resizing
                [
                  "ALT + TAB" # focus next window
                  (lua ''
                    function()
                      hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
                      hl.dispatch(hl.dsp.window.bring_to_top())
                    end
                  '')
                ]
                [
                  "SHIFT + ALT + TAB" # jump back to previously focused window
                  (lua ''
                    function()
                      hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
                      hl.dispatch(hl.dsp.window.bring_to_top())
                    end
                  '')
                ]
                [
                  "ALT + A" # toggle maximized
                  (lua "hl.dsp.window.fullscreen({ mode = 'maximized' })")
                ]
                [
                  "ALT + F" # toggle fullscreen
                  (lua "hl.dsp.window.fullscreen({ mode = 'fullscreen' })")
                ]
              ]
              ++ lib.concatMap (
                dir:
                let
                  key = lib.toUpper dir.name;
                in
                [
                  [
                    "ALT + ${key}" # move window focus in direction
                    (lua "hl.dsp.focus({ direction = '${dir.name}' })")
                  ]
                  [
                    "SHIFT + ALT + ${key}" # move window in direction
                    (lua "hl.dsp.window.move({ direction = '${dir.name}' })")
                  ]
                  [
                    "CTRL + ALT + ${key}" # resize window
                    (lua "hl.dsp.window.resize({ x = ${dir.x}, y = ${dir.y}, relative = true })")
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
                    "CTRL + ${n}" # go to workspace n
                    (lua "hl.dsp.focus({ workspace = ${n} })")
                  ]
                  [
                    "ALT + ${n}" # move active window to workspace n
                    (lua "hl.dsp.window.move({ workspace = ${n}, follow = true })")
                  ]
                ]
              ) (lib.range 1 9)
              ++ [
                [
                  "CTRL + LEFT" # go to previous non-empty workspace
                  (lua "hl.dsp.focus({ workspace = 'e-1' })")
                ]
                [
                  "CTRL + RIGHT" # go to next non-empty workspace
                  (lua "hl.dsp.focus({ workspace = 'e+1' })")
                ]
                # dwindle layout
                [
                  "SHIFT + ALT + RETURN" # toggle split direction
                  (lua "hl.dsp.layout('togglesplit')")
                ]
                # mouse and trackpad gestures
                # https://wiki.hypr.land/configuring/core/binds/devices/mouse
                # https://wiki.hypr.land/configuring/core/binds/gestures
                [
                  (lua "mod .. ' + mouse_up'") # mouse scroll up -> previous non-empty workspace
                  (lua "hl.dsp.focus({ workspace = 'e-1' })")
                ]
                [
                  (lua "mod .. ' + mouse_down'") # mouse scroll down -> next non-empty workspace
                  (lua "hl.dsp.focus({ workspace = 'e+1' })")
                ]
                [
                  (lua "mod .. ' + mouse:272'") # left mouse button -> move window
                  (lua "hl.dsp.window.drag()")
                  { mouse = true; }
                ]
                [
                  (lua "mod .. ' + mouse:273'") # right mouse button -> resize window
                  (lua "hl.dsp.window.resize()")
                  { mouse = true; }
                ]
                [
                  (lua "mod .. ' + mouse:274'") # middle mouse button -> close window
                  (lua "hl.dsp.window.close()")
                ]
                [
                  (lua "mod .. ' + SHIFT + mouse:274'") # shift + middle mouse button -> kill window
                  (lua "hl.dsp.window.kill()")
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
              # TODO: hyprexpo for 4-finger gestures
            ];

            # # default layout for each tag
            # tag_rule = [
            #   "id:1,layout_name:tile"
            #   "id:2,layout_name:tile"
            #   "id:3,layout_name:tile"
            #   "id:4,layout_name:tile"
            #   "id:5,layout_name:tile"
            #   "id:6,layout_name:tile"
            #   "id:7,layout_name:tile"
            #   "id:8,layout_name:tile"
            #   "id:9,layout_name:tile"
            # ];

            # # keyboard shortcuts
            # bind = [
            #   # switch window status
            #   "super,g,toggleglobal,"
            #   "alt,tab,togglejump,"
            #   "alt,backslash,togglefloating,"
            #   "alt,a,togglemaximizescreen,"
            #   "alt,f,togglefullscreen,"
            #   "alt+shift,f,togglefakefullscreen,"
            #   "super,i,minimized,"
            #   "super+shift,I,restore_minimized"
            #   "super,o,toggleoverlay,"

            #   # tag switch
            #   "super,left,viewtoleft,0"
            #   "super,right,viewtoright,0"
            #   "ctrl,left,viewtoleft_have_client,0" # skips empty tags
            #   "ctrl,right,viewtoright_have_client,0"
            #   "ctrl+super,left,tagtoleft,0" # move window to another tag
            #   "ctrl+super,right,tagtoright,0"
            #   "ctrl,1,view,1,0"
            #   "ctrl,2,view,2,0"
            #   "ctrl,3,view,3,0"
            #   "ctrl,4,view,4,0"
            #   "ctrl,5,view,5,0"
            #   "ctrl,6,view,6,0"
            #   "ctrl,7,view,7,0"
            #   "ctrl,8,view,8,0"
            #   "ctrl,9,view,9,0"

            #   # move client to tag and focus it
            #   "alt,1,tag,1,0"
            #   "alt,2,tag,2,0"
            #   "alt,3,tag,3,0"
            #   "alt,4,tag,4,0"
            #   "alt,5,tag,5,0"
            #   "alt,6,tag,6,0"
            #   "alt,7,tag,7,0"
            #   "alt,8,tag,8,0"
            #   "alt,9,tag,9,0"
            # ];
          };
        };
    };
}
