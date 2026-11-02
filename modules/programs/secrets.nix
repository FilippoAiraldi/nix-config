# SOPS
# https://dl.thalheim.io
{ inputs, ... }:
{
  flake.modules.homeManager.secrets =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        age.keyFile = "${config.xdg.configHome}/sops-nix/age/key.txt";
        defaultSopsFile = ../../secrets + "/${config.home.username}.yaml";
        secrets = {
          "ssh/crappy-server/hostname" = { };
          "ssh/crappy-server-tailscale/hostname" = { };
          "ssh/olaf-tailscale/hostname" = { };
        };
      };

      # systemd.user.services.ssh-agent.Unit.After = [ "sops-nix.service" ];
    };
}
