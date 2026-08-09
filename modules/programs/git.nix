{
  flake.modules.homeManager.git =
    { config, ... }:
    {
      programs = {
        git = {
          enable = true;
          settings = {
            user = {
              inherit (config.profile) email;
              name = config.profile.fullName;
            };
            safe.directory = "/etc/nixos/home";
            pull.rebase = true;
            alias = {
              lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
            };
          };
        };

        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            keep-plus-minus-markers = true;
            line-numbers = true;
            navigate = true;
          };
        };
      };
    };
}
