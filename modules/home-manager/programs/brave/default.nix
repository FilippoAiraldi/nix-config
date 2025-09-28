{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Ensure Brave browser package installed
  home.packages = [ pkgs.brave ];

  xdg = {
    mimeApps = {
      defaultApplications = lib.mkMerge [
        (config.lib.xdg.mimeAssociations [ pkgs.brave ])
      ];

    };
  };
}
