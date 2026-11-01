{ inputs, ... }:
{
  flake.modules.nixos.secrets-server =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";
        defaultSopsFile = ../../secrets/server.yaml;
        secrets = {
          grafana-secret-key.key = "grafana-secret-key";
          librechat-env.key = "librechat-env";
          searxng-env.key = "searxng-env";
          syncthing-gui-passwd = {
            key = "syncthing-gui-passwd";
            owner = config.primaryUser;
            group = "users";
          };
          wireless.key = "wireless";
        };
      };
    };
}
