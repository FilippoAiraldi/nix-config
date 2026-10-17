# mangobar
# https://mangowm.github.io/docs/visuals/status-bar#recommended-mangobar
# https://github.com/mangowm/mangobar/wiki
{ inputs, ... }:
{
  flake.modules.homeManager.status-bar = {
    imports = [ inputs.mangobar.homeManagerModules.default ];

    services.mangobar = {
      enable = true;
      systemdTarget = "mango-session.target";
    };
  };
}
