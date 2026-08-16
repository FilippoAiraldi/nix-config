{
  flake.modules.homeManager.eza = {
    programs.eza = {
      enable = true;
      extraOptions = [ "--group-directories-first" "--header" "--icons=always" ];
    };
  };
}
