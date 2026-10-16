# Mango Windows Manager
# https://mangowm.github.io/docs
# https://wiki.nixos.org/wiki/Mango
# https://github.com/mangowm/mango/wiki
{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.mango = {
    imports = [ inputs.mangowm.nixosModules.mango ];

    programs.mango.enable = true;
    home-manager.sharedModules = [ homeManager.mango ];
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

      wayland.windowManager.mango = {
        enable = true;
        settings = {
          # disable window effects and animations
          blur = 0;
          shadows = 0;
          animations = 0;
          layer_animations = 0;
          dim_enable = 0;

          border_radius = 6;
          no_radius_when_single = 0;
          focused_opacity = "1.0";
          unfocused_opacity = "1.0";

          # Scroller Layout Setting
          scroller_structs = 20;
          scroller_default_proportion = "0.8";
          scroller_focus_center = 0;
          scroller_prefer_center = 0;
          edge_scroller_pointer_focus = 1;
          edge_scroller_focus_allow_speed = "0.0";
          scroller_default_proportion_single = "1.0";
          scroller_proportion_preset = "0.5,0.8,1.0";

          # Master-Stack Layout Setting
          new_is_master = 1;
          default_master_factor = "0.55";
          default_master_count = 1;
          tag_num = 9;
          smart_gaps = 0;

          # Dwindle Layout Setting
          dwindle_smart_split = 0;
          dwindle_drop_simple_split = 1;
          dwindle_manual_split = 0;
          dwindle_horizontal_split = 1;
          dwindle_vertical_split = 1;
          dwindle_preserve_split = 0;

          # Monocle Layout Setting
          monocle_tab_mode = 1;
          monocle_no_border = 0;
          monocle_no_gap = 0;

          # Deck Layout Setting
          deck_tab_mode = 1;

          # Overview Setting
          hotarea_size = 10;
          enable_hotarea = 0;
          hotarea_disable_on_fullscreen = 1;
          overview_gap_inner = 5;
          overview_gap_outer = 30;
          overcircle_center_ratio = "0.5";

          # Misc
          no_border_when_single = 0;
          axis_bind_apply_timeout = 100;
          focus_on_activate = 1;
          idle_inhibit_ignore_visible = 0;
          idle_inhibit_when_fullscreen = 0;
          sloppy_focus = 1;
          warp_cursor = 1;
          focus_cross_monitor = 0;
          focus_direction_only_zone_overlap = 1;
          focus_cross_tag = 0;
          enable_floating_snap = 0;
          snap_distance = 30;
          float_full_to_top = 0;
          cursor_size = 24;
          drag_tile_to_tile = 1;
          drag_tile_small = 1;

          # keyboard
          repeat_rate = 25;
          repeat_delay = 600;
          numlock_on = 0;
          xkb_rules_layout = "us";

          # Trackpad
          # need relogin to make it apply
          disable_trackpad = 0;
          tap_to_click = 1;
          tap_and_drag = 1;
          drag_lock = 1;
          trackpad_natural_scrolling = 0;
          trackpad_disable_while_typing = 1;
          trackpad_left_handed = 0;
          trackpad_middle_button_emulation = 0;
          swipe_min_threshold = 1;

          # mouse
          # need relogin to make it apply
          mouse_natural_scrolling = 0;

          # Appearance
          gap_inner_horizontal = 5;
          gap_inner_vertical = 5;
          gap_outer_horizontal = 10;
          gap_outer_vertical = 10;
          scratchpad_width_ratio = "0.8";
          scratchpad_height_ratio = "0.9";
          border_px = 4;
          root_color = "0x201b14ff";
          border_color = "0x444444ff";
          drop_color = "0x8FBA7C55";
          split_color = "0xEB441EFF";
          focus_color = "0xc9b890ff";
          maximized_screen_color = "0x89aa61ff";
          urgent_color = "0xad401fff";
          scratchpad_color = "0x516c93ff";
          global_color = "0xb153a7ff";
          overlay_color = "0x14a57cff";

          exec_once =
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
            in
            [
              "${clipBridge}" # TODO: remove outside a VM
              "env GDK_BACKEND=x11 ${pkgs.open-vm-tools}/bin/vmtoolsd -n vmusr" # TODO: remove outside a VM
              "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill"
            ];

          bind = [
            "ALT,SPACE,spawn,${config.mango.appLauncherCmd}"
            "ALT,RETURN,spawn,${config.mango.terminalCmd}"
            "SUPER,m,quit"
            "ALT,q,killclient,"
            "SUPER,Tab,focusstack,next"
            "ALT,Left,focusdir,left"
            "ALT,Right,focusdir,right"
            "ALT,Up,focusdir,up"
            "ALT,Down,focusdir,down"
            "SUPER+SHIFT,Up,move_client,up"
            "SUPER+SHIFT,Down,move_client,down"
            "SUPER+SHIFT,Left,move_client,left"
            "SUPER+SHIFT,Right,move_client,right"
            "SUPER,g,toggleglobal,"
            "ALT,Tab,togglejump,"
            "ALT,backslash,togglefloating,"
            "ALT,a,togglemaximizescreen,"
            "ALT,f,togglefullscreen,"
            "ALT+SHIFT,f,togglefakefullscreen,"
            "SUPER,i,minimized,"
            "SUPER,o,toggleoverlay,"
            "SUPER+SHIFT,I,restore_minimized"
            "ALT,z,toggle_scratchpad"
            "ALT,e,set_proportion,1.0"
            "ALT,x,switch_proportion_preset,"
            "alt+super+ctrl,Left,scroller_stack,left"
            "alt+super+ctrl,Right,scroller_stack,right"
            "alt+super+ctrl,Up,scroller_stack,up"
            "alt+super+ctrl,Down,scroller_stack,down"
            "alt+shift,Return,dwindle_toggle_split_direction"
            "SUPER,n,switch_layout"
            "SUPER,Left,viewtoleft,0"
            "CTRL,Left,viewtoleft_have_client,0"
            "SUPER,Right,viewtoright,0"
            "CTRL,Right,viewtoright_have_client,0"
            "CTRL+SUPER,Left,tagtoleft,0"
            "CTRL+SUPER,Right,tagtoright,0"
            "Ctrl,1,view,1,0"
            "Ctrl,2,view,2,0"
            "Ctrl,3,view,3,0"
            "Ctrl,4,view,4,0"
            "Ctrl,5,view,5,0"
            "Ctrl,6,view,6,0"
            "Ctrl,7,view,7,0"
            "Ctrl,8,view,8,0"
            "Ctrl,9,view,9,0"
            "Alt,1,tag,1,0"
            "Alt,2,tag,2,0"
            "Alt,3,tag,3,0"
            "Alt,4,tag,4,0"
            "Alt,5,tag,5,0"
            "Alt,6,tag,6,0"
            "Alt,7,tag,7,0"
            "Alt,8,tag,8,0"
            "Alt,9,tag,9,0"
            "alt+shift,Left,focusmon,left"
            "alt+shift,Right,focusmon,right"
            "SUPER+Alt,Left,tagmon,left"
            "SUPER+Alt,Right,tagmon,right"
            "ALT+SHIFT,X,incgaps,1"
            "ALT+SHIFT,Z,incgaps,-1"
            "ALT+SHIFT,R,togglegaps"
            "CTRL+SHIFT,Up,movewin,+0,-50"
            "CTRL+SHIFT,Down,movewin,+0,+50"
            "CTRL+SHIFT,Left,movewin,-50,+0"
            "CTRL+SHIFT,Right,movewin,+50,+0"
            "CTRL+ALT,Up,resizewin,+0,-50"
            "CTRL+ALT,Down,resizewin,+0,+50"
            "CTRL+ALT,Left,resizewin,-50,+0"
            "CTRL+ALT,Right,resizewin,+50,+0"
          ];

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

          mousebind = [
            "SUPER,btn_left,moveresize,curmove"
            "NONE,btn_middle,togglemaximizescreen,0"
            "SUPER,btn_right,moveresize,curresize"
          ];

          axisbind = [
            "SUPER,UP,viewtoleft_have_client"
            "SUPER,DOWN,viewtoright_have_client"
          ];

          gesturebind = [
            "none,left,3,focusdir,left"
            "none,right,3,focusdir,right"
            "none,up,3,focusdir,up"
            "none,down,3,focusdir,down"
            "none,right,4,viewprev_have_client"
            "none,left,4,viewnext_have_client"
            "none,up,4,enteroverview"
            "none,down,4,leaveoverview"
          ];
        };
      };
    };
}
