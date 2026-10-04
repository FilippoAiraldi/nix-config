{
  flake.modules.nixos.services = { config, ... }: {
    systemd.services = {
      NetworkManager-wait-online.enable = false;
      plymouth-quit-wait.enable = false;
    };

    services = {
      # automatic mounting (disabled for power reduction)
      devmon.enable = false;

      # enable ssh
      openssh = {
        enable = true;
        settings.X11Forwarding = true;
      };

      # ignore lid closing
      logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };

      # power management (consume as little as possible)
      thermald.enable = true;
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "schedutil";
            scaling_min_freq = "800000";
            scaling_max_freq = "1500000";
            turbo = "never";
          };
          charger = {
            governor = "schedutil";
            scaling_min_freq = "800000";
            scaling_max_freq = "1500000";
            turbo = "never";
          };
        };
      };
    };

    # enable tailscale (with home subnet advertising)
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      extraUpFlags = [ "--advertise-routes=${config.localIPAddr}/32" ];
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
