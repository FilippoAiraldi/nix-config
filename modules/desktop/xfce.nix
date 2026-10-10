{
  flake.modules.nixos.xfce =
    { config, ... }:
    {
      networking.networkmanager.enable = true;
      users.users.${config.primaryUser}.extraGroups = [ "networkmanager" ];

      services = {
        xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
          desktopManager.xfce.enable = true;
          xkb = {
            layout = "us";
            variant = "";
          };
        };
        printing.enable = true;
        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };

      security.rtkit.enable = true;
      programs.firefox.enable = true;
    };
}
