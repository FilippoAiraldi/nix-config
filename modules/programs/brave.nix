{
  flake.modules.homeManager.brave =
    { pkgs, ... }:
    {
      programs.brave.enable = true;

      xdg.mimeApps =  {
        enable = true;
        defaultApplicationPackages = [
          pkgs.brave
        ];
      };
    };
}
