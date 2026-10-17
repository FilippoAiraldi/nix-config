# Mango Windows Manager
# https://mangowm.github.io/docs
# https://wiki.nixos.org/wiki/Mango
# https://github.com/mangowm/mango/wiki
{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.mango = { pkgs, ... }: {
    imports = [ inputs.mangowm.nixosModules.mango ];

    home-manager.sharedModules = [ homeManager.mango ];
    programs.mango.enable = true;

    environment.systemPackages = with pkgs; [ wlr-randr ];
  };

  flake.modules.homeManager.mango =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.mangowm.hmModules.mango
        homeManager.application-launcher
        homeManager.terminal-emulator
      ];

      wayland.windowManager.mango =
        let
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
          inherit (config.lib.stylix) colors;
          inherit (config.profile.appearance) border;
          colorFmt = color: alpha: "0x${color}${alpha}";
        in
        {
          enable = true;
          settings = {
            # blur, shadows, animations and dim
            animations = 0;
            layer_animations = 0;
            blur = 0;
            blur_layer = 0;
            shadows = 0;
            dim_enable = 0;

            # appearance
            border_px = border.width;
            border_radius = border.radius;
            root_color = colorFmt colors.base00 "ff";
            border_color = colorFmt colors.base03 "ff";
            drop_color = colorFmt colors.base0B "55";
            split_color = colorFmt colors.base09 "ff";
            focus_color = colorFmt colors.base0D "ff";
            maximized_screen_color = colorFmt colors.base0B "ff";
            urgent_color = colorFmt colors.base08 "ff";
            scratchpad_color = colorFmt colors.base0A "ff";
            global_color = colorFmt colors.base0E "ff";
            overlay_color = colorFmt colors.base0C "ff";

            # miscellaneous
            sloppy_focus = 0;
            warp_cursor = 0;

            # input devices: keyboard, trackpad, mouse
            repeat_delay = 500;
            xkb_rules_layout = "us";
            trackpad_middle_button_emulation = 1;
            mouse_natural_scrolling = 0;

            # commands executed once at startup
            exec_once = [
              "${clipBridge}" # TODO: remove outside a VM
              "env GDK_BACKEND=x11 ${pkgs.open-vm-tools}/bin/vmtoolsd -n vmusr" # TODO: remove outside a VM
              "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill"
            ];

            # monitors
            monitor_rule = [
              "name:^Virtual-1$,width:2558,height:1238,x:0,y:0,refresh:60,primary:1"
            ];

            # mouse and trackpad gestures for workspace and window management
            axisbind = [
              "super,up,viewtoleft_have_client" # scroll up -> scroll left
              "super,down,viewtoright_have_client" # scroll down -> scroll right
            ];
            gesturebind = [
              # 3-finger
              "none,left,3,focusdir,left"
              "none,right,3,focusdir,right"
              "none,up,3,focusdir,up"
              "none,down,3,focusdir,down"
              # 4-finger
              "none,left,4,viewnext_have_client" # left -> next tag
              "none,right,4,viewprev_have_client" # right -> previous tag
              "none,up,4,enteroverview" # up -> overview
              "none,down,4,leaveoverview" # down -> close overview
            ];
            mousebind = [
              "super,btn_left,moveresize,curmove" # move selected window
              "super,btn_right,moveresize,curresize" # resize selected window
              "super,btn_middle,smartkillclient" # kill selected window if not in any other tag
              "super+shift,btn_middle,killclient" # kill selected window
            ];

            # default layout for each tag
            tag_rule = [
              "id:1,layout_name:tile"
              "id:2,layout_name:tile"
              "id:3,layout_name:tile"
              "id:4,layout_name:tile"
              "id:5,layout_name:tile"
              "id:6,layout_name:tile"
              "id:7,layout_name:tile"
              "id:8,layout_name:tile"
              "id:9,layout_name:tile"
            ];

            # keyboard shortcuts
            bind = [
              "super,r,reload_config" # reload configuration
              "alt,space,spawn,${config.mango.appLauncherCmd}" # menu
              "alt,return,spawn,${config.mango.terminalCmd}" # terminal
              "super,m,quit" # quit to display-manager
              "alt,q,killclient," # close window

              # switch window focus
              "super,tab,focusstack,next"
              "alt,left,focusdir,left"
              "alt,right,focusdir,right"
              "alt,up,focusdir,up"
              "alt,down,focusdir,down"

              # move window
              "super+shift,up,move_client,up"
              "super+shift,down,move_client,down"
              "super+shift,left,move_client,left"

              # switch window status
              "super,g,toggleglobal,"
              "alt,tab,togglejump,"
              "alt,backslash,togglefloating,"
              "alt,a,togglemaximizescreen,"
              "alt,f,togglefullscreen,"
              "alt+shift,f,togglefakefullscreen,"
              "super,i,minimized,"
              "super+shift,I,restore_minimized"
              "super,o,toggleoverlay,"

              # scroller layout
              "alt,e,set_proportion,1.0"
              "alt,x,switch_proportion_preset,"
              "alt+super+ctrl,left,scroller_stack,left"
              "alt+super+ctrl,right,scroller_stack,right"
              "alt+super+ctrl,up,scroller_stack,up"
              "alt+super+ctrl,down,scroller_stack,down"

              # dinwdle layout
              "alt+shift,return,dwindle_toggle_split_direction"

              # switch layout
              "super,n,switch_layout"

              # tag switch
              "super,left,viewtoleft,0"
              "super,right,viewtoright,0"
              "ctrl,left,viewtoleft_have_client,0" # skips empty tags
              "ctrl,right,viewtoright_have_client,0"
              "ctrl+super,left,tagtoleft,0" # move window to another tag
              "ctrl+super,right,tagtoright,0"
              "ctrl,1,view,1,0"
              "ctrl,2,view,2,0"
              "ctrl,3,view,3,0"
              "ctrl,4,view,4,0"
              "ctrl,5,view,5,0"
              "ctrl,6,view,6,0"
              "ctrl,7,view,7,0"
              "ctrl,8,view,8,0"
              "ctrl,9,view,9,0"

              # move client to tag and focus it
              "alt,1,tag,1,0"
              "alt,2,tag,2,0"
              "alt,3,tag,3,0"
              "alt,4,tag,4,0"
              "alt,5,tag,5,0"
              "alt,6,tag,6,0"
              "alt,7,tag,7,0"
              "alt,8,tag,8,0"
              "alt,9,tag,9,0"

              # monitor switch
              "alt+shift,left,focusmon,left"
              "alt+shift,right,focusmon,right"
              "super+alt,left,tagmon,left"
              "super+alt,right,tagmon,right"

              # move and resize window
              "ctrl+shift,up,movewin,+0,-50"
              "ctrl+shift,down,movewin,+0,+50"
              "ctrl+shift,left,movewin,-50,+0"
              "ctrl+shift,right,movewin,+50,+0"
              "ctrl+alt,up,resizewin,+0,-50"
              "ctrl+alt,down,resizewin,+0,+50"
              "ctrl+alt,left,resizewin,-50,+0"
              "ctrl+alt,right,resizewin,+50,+0"
            ];
          };
        };
    };
}
