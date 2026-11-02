{ config, pkgs, ... }:
{
  programs.pi-coding-agent = {
    extraPackages = with pkgs; [
      bubblewrap
      ripgrep
      socat
      which
    ];
    settings.packages = [ "npm:pi-sandbox" ];
  };

  home.file = {
    "${config.programs.pi-coding-agent.configDir}/sandbox.json".text = builtins.toJSON {
      enabled = true;
      enableAccessRequestTool = true;
      sandboxUserShell = true;
      permissionPromptTimeoutSeconds = 0;
      filesystem = {
        allowRead = [
          "."
          "/tmp"
        ];
        denyRead = [
          "/home"
          "~/.ssh"
        ];
        allowWrite = [
          "."
          "/tmp"
        ];
        denyWrite = [
          ".env"
          ".git"
          "~/.ssh"
        ];
      };
      network = {
        allowedDomains = [
          "cache.nixos.org"
          "github.com"
          "*.github.com"
        ];
        deniedDomains = [ ];
      };
    };
  };
}
