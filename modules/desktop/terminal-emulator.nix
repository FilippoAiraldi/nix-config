# Foot
# https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
{
  flake.modules.homeManager.terminal-emulator =
    { lib, pkgs, ... }:
    {
      options.desktop.terminalCmd = lib.mkOption {
        type = lib.types.str;
        description = "Command that opens the terminal";
      };

      config =
        let
          pkg = pkgs.foot;
        in
        {
          desktop.terminalCmd = lib.getExe pkg;

          programs = {
            foot = {
              enable = true;
              package = pkg;
            };

            # https://codeberg.org/dnkl/foot/wiki/Home#spawning-new-terminal-instances-in-the-current-working-directory
            bash.initExtra = ''
              osc7_cwd() {
                  local strlen=''${#PWD}
                  local encoded=""
                  local pos c o
                  for (( pos=0; pos<strlen; pos++ )); do
                      c=''${PWD:$pos:1}
                      case "$c" in
                          [-/:_.!\'\(\)~[:alnum:]] ) o="$c" ;;
                          * ) printf -v o '%%%02X' "'$c" ;;
                      esac
                      encoded+="$o"
                  done
                  printf '\e]7;file://%s%s\e\\' "$HOSTNAME" "$encoded"
              }
              PROMPT_COMMAND=''${PROMPT_COMMAND:+''${PROMPT_COMMAND%;}; }osc7_cwd
            '';
          };

        };
    };
}
