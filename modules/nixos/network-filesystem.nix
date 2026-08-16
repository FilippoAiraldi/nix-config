# network storage
# https://nixos.wiki/wiki/Samba
# https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
# https://chriskalos.notion.site/The-0-Home-Server-Written-Guide-5d5ff30f9bdd4dfbb9ce68f0d914f1f6
#
# To use Samba (after a successful build)
#   - run `sudo smbpasswd -a USERNAME`, with USERNAME the user that needs to access Samba.
#     The password is needed at the next step.
#   - on a Windows client
#      1. clear Z: (or any other free mount) with `net use Z: /delete /y`
#      2. mount Z: with `net use Z: \\HOSTNAME\shares /user:USERNAME PASSWD /persistent:yes`
{
  flake.modules.nixos."network-filesystem" =
    { config, lib, ... }:
    {
      options.sambaDir = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path to the Samba share directory";
      };

      config = {
        services = {
          # definition of samba global settings and share with name `shares`
          samba = {
            enable = true;
            openFirewall = true;
            settings = {
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
              shares = {
                path = config.sambaDir;
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
        };

        # create the shared directory
        systemd.tmpfiles.rules = [ "d ${config.sambaDir} 0770 ${config.primaryUser} root -" ];
      };
    };
}
