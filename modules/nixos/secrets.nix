# SOPS
# https://dl.thalheim.io
{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";
        defaultSopsFile = ../../secrets/server.yaml;
        secrets = {
          grafana-secret-key = { };
          librechat-env = { };
          searxng-env = { };
          syncthing-gui-passwd = {
            owner = config.primaryUser;
            group = "users";
          };
          wireless = { };
        };
      };
    };
}
