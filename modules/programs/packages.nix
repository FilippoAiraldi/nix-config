{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dig
        fd
        jq
        nh
        nodejs
        openconnect
        pipenv
        python3
        ripgrep
        telegram-desktop
        anki
        gcc
        gnumake
        killall
        (tesseract.override {
          enableLanguages = [
            "eng"
            "pol"
            "rus"
          ];
        })
        unzip
        wl-clipboard
      ];
    };
}
