{
  flake.modules.nixos."network-filesystem" =
    { config, lib, ... }:
    {
      # module options
      options = {
        sharesDir = lib.mkOption {
          type = lib.types.str;
          description = "Absolute path to the share directory";
          default = "/home/${config.primaryUser}/Shares/";
        };
        syncthingPort = lib.mkOption {
          type = lib.types.int;
          description = "Syncthing web GUI port";
          default = 8384;
        };
      };

      config = {
        # ensure the shared directory is created
        systemd.tmpfiles.rules = [ "d ${config.sharesDir} 0770 ${config.primaryUser} root -" ];

        services = {
          # network storage (Samba)
          # https://nixos.wiki/wiki/Samba
          # https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
          # https://chriskalos.notion.site/The-0-Home-Server-Written-Guide-5d5ff30f9bdd4dfbb9ce68f0d914f1f6
          # to use Samba after a successful build:
          #   - run `sudo smbpasswd -a USERNAME`, with USERNAME the user that needs to access Samba.
          #     The password is needed at the next step.
          #   - on a Windows client
          #      1. clear Z: (or any other free mount) with `net use Z: /delete /y`
          #      2. mount Z: with `net use Z: \\HOSTNAME\shares /user:USERNAME PASSWD /persistent:yes`
          samba = {
            enable = true;
            openFirewall = true;
            settings = {
              # global settings
              global = {
                "invalid users" = [
                  "root"
                  "nobody"
                ];
                "map to guest" = "never";
                security = "user";
                "server string" = "smbnix %h";
                "use sendfile" = "yes";
              };
              # share settings (this share is named `shares`)
              shares = {
                path = config.sharesDir;
                comment = "Samba share";
                browseable = "no";
                "read only" = "no";
                "guest ok" = "no";
                "valid users" = config.primaryUser;
                "force user" = config.primaryUser;
                "create mask" = "0644";
                "directory mask" = "0755";
              };
            };
          };

          # `samba-wsdd` advertises the shares to Windows hosts
          # samba-wsdd = {
          #   enable = true;
          #   openFirewall = true;
          # };

          # file syncing (Syncthing)
          # https://wiki.nixos.org/wiki/Syncthing
          # https://nixos.wiki/wiki/Syncthing
          syncthing = {
            enable = true;
            openDefaultPorts = true;
            user = config.primaryUser;
            group = "users";

            guiAddress = "0.0.0.0:${toString config.syncthingPort}";
            guiPasswordFile = "/secrets/syncthing/gui-passwd"; # manually created

            settings = {
              gui.user = "fairaldi";
              devices = {
                "C4SV5D3" = {
                  id = "M4PBHWJ-A7XXPSY-BTBYGBA-3BZECO5-7VDT3F4-PXLKTNC-U5JJOQT-XEUF3A4";
                };
              };
              folders.shares = {
                path = config.sharesDir;
                devices = [ "C4SV5D3" ];
              };
            };
          };
        };

        # open port for syncthing GUI
        networking.firewall.allowedTCPPorts = [ config.syncthingPort ];
      };
    };
}
