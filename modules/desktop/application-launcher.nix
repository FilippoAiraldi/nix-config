# Vicinae
# https://www.vicinae.com
{ inputs, ... }:
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
          inherit (config.profile.appearance) border;
          inherit (config.lib.stylix) colors;
          inherit (config.stylix) fonts;
          pkg = pkgs.vicinae;
        in
        {
          desktop = {
            appLauncherCmd = "${lib.getExe pkg} toggle";
            hyprlandKeybindsMenuCmd = "${lib.getExe pkg} toggle";
          };

          systemd.user.services.vicinae.Service.Environment = lib.mkIf isVM [
            "LIBGL_ALWAYS_SOFTWARE=1"
            # "USE_LAYER_SHELL=0"
            # "QT_QUICK_BACKEND=\"software\""
          ];
          programs.vicinae = {
            enable = true;
            package = pkg;
            systemd.enable = true;

            # https://github.com/vicinaehq/vicinae/blob/main/extra/config.jsonc
            settings = {
              close_on_focus_loss = true;
              consider_preedit = true;
              # encrypt_sensitive_data = true;  # crashes the service
              escape_key_behavior = "close_window";
              keybinding = "vim";
              launcher_window = {
                blur.enabled = false;
                client_side_decorations.shadow_size = 0;
                clock.enabled = false;
                compact_mode.enabled = true;
                material = "none";
                rounding = border.radius;
              };
              pop_to_root_on_close = true;
              search_files_in_root = true;
              telemetry.system_info = false;
              tray.enabled = false;
              updates.show_notice = false;

              fallbacks = [
                "files:search"
                "system:browse-apps"
                "system:run"
              ];
              providers = {
                applications.preferences.defaultAction = "launch";
                browser-extension.enabled = false;
                core.entrypoints = {
                  manage-fallback.enabled = false;
                  report-bug.enabled = false;
                  search-builtin-icons.enabled = true;
                  sponsor.enabled = false;
                };
                clipboard.preferences.evictionThreshold = 7776000;
                developer.enabled = false;
                files.preferences.indexingPaths = [
                  "/home/${config.home.username}"
                  "/etc/nixos/home"
                ];
                manage-shortcuts.enabled = false;
                media.enabled = false;
                power.enabled = false;
                raycast-compat.enabled = false;
                snippets.enabled = false;
                system.entrypoints = {
                  set-default-browser.enabled = false;
                  set-default-terminal.enabled = false;
                };
                theme.enabled = false;
                wm.enabled = false;
              };
            };

            # adjust some theme-related options from Stylix
            settings.font.normal.family = lib.mkForce fonts.monospace.name;
            themes.stylix.colors.core.border = lib.mkForce colors.withHashtag.base0E;

            # https://github.com/vicinaehq/extensions/tree/main/extensions
            extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
              bitwarden
              coffee
              color-converter
              # fff-search
              hypr-keybinds
              # hypr
              # hyprland-monitors
              # nerdfont-search
              nix
              number-converter
              # power-profile
              # otp
            ];
            settings.providers."@bl4zee1g/vicinae-extension-bitwarden-0".preferences.rbwPath = lib.getExe pkgs.rbw;
          };
        };
    };
}
