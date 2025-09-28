{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.telegram-desktop ];

  xdg = {
    mimeApps = {
      defaultApplications = lib.mkMerge [
        (config.lib.xdg.mimeAssociations [ pkgs.telegram-desktop ])
      ];

    };
  };
}
