{
  flake.modules.homeManager.zellij = {
    programs.zellij = {
      enable = true;

      enableBashIntegration = false; # keep false if we don't want to be dropped into a session at each ssh login
      settings = {
        show_startup_tips = false;
      };
    };

    # let a new generation build overwrite previous config files
    xdg.configFile."zellij/config.kdl".force = true;
  };
}
