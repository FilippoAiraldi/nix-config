{
  flake.modules.homeManager.ssh =
    { config, lib, ... }:
    let
      inherit (lib.hm.dag) entryAfter;
      inherit (config.sops) placeholder;
      inherit (config.home) homeDirectory;

      hosts = {
        crappy-server = "id_ed25519_crappy-server";
        crappy-server-tailscale = "id_ed25519_crappy-server";
        olaf-tailscale = "id_ed25519_olaf-tailscale";
      };
      mkHostTemplateEntry = host: ''
        Host ${host}
          Hostname ${placeholder."ssh/${host}/hostname"}
      '';
      mkHostConfigEntry =
        host: keyfile:
        lib.nameValuePair "${host}-key" (
          entryAfter [ "common" ] {
            header = "Host ${host}";
            IdentityFile = "${homeDirectory}/.ssh/${keyfile}";
          }
        );
    in
    {
      sops.templates."ssh-hosts".content = lib.concatStringsSep "\n" (
        map mkHostTemplateEntry (builtins.attrNames hosts)
      );

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ config.sops.templates."ssh-hosts".path ];
        settings = {
          "*" = {
            AddKeysToAgent = "yes";
            ForwardX11 = "yes";
            ForwardX11Trusted = "yes";
            IdentitiesOnly = "yes";
            ServerAliveInterval = 60;
            User = config.home.username;
          };
        }
        // lib.mapAttrs' mkHostConfigEntry hosts;
      };
    };
}
