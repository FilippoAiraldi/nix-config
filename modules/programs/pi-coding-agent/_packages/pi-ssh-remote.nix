{ config, pkgs, ... }:
{
  programs.pi-coding-agent.settings.packages = [ "npm:pi-ssh-remote" ];

  # helper script `pi-remote` to launch pi without extensions conflicting with pi-ssh-remote
  home.packages = [
    (pkgs.writeShellApplication {
      name = "pi-remote";
      runtimeInputs = with pkgs; [
        jq
        nodejs
      ];
      text = ''
        modules="${config.programs.pi-coding-agent.configDir}/npm/node_modules"
        args=(--no-extensions)

        for pkg in "$modules"/*/package.json "$modules"/@*/*/package.json; do
          [ -e "$pkg" ] || continue
          dir="$(dirname "$pkg")"
          name="$(jq -r '.name' "$pkg")"
          [ "$name" = "pi-sandbox" ] && continue
          while IFS= read -r entry; do
            args+=(-e "$dir/$entry")
          done < <(jq -r '.pi.extensions[]? | sub("^\\./"; "")' "$pkg")
        done

        if [ "''${1:-}" = "--dry-run" ]; then
          printf 'pi'
          printf ' %q' "''${args[@]}" "''${@:2}"
          printf '\n'
          exit 0
        fi
        exec pi "''${args[@]}" "$@"
      '';
    })
  ];
}
