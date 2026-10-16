# Foot
# https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
{
  flake.modules.homeManager.terminal-emulator =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mango.terminalCmd = lib.mkOption {
        type = lib.types.str;
        description = "Command that opens the terminal";
      };

      config =
        let
          pkg = pkgs.foot;
          inherit (config.profile.appearance.fonts) monospace;
        in
        {
          mango.terminalCmd = lib.getExe pkg;

          programs.foot = {
            enable = true;
            package = pkg;
            settings.main.font = "${monospace.family}:size=${toString monospace.size}";
          };
        };
    };
}
