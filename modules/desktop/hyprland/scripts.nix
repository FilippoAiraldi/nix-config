# Shared scripts and commands for Hyprland
{
  flake.modules.homeManager.scripts =
    {
      isVM,
      lib,
      pkgs,
      ...
    }:
    {
      options.desktop = with lib.types; {
        colorPickerCmd = lib.mkOption {
          type = str;
          description = "Command to launch the color picker";
        };
        ocrCmd = lib.mkOption {
          type = str;
          description = "Command to run OCR and extract text from images";
        };
        screenshotMonitorCmd = lib.mkOption {
          type = str;
          description = "Command to screenshot the monitor";
        };
        screenshotRegionCmd = lib.mkOption {
          type = str;
          description = "Command to screenshot an interactive region";
        };
        screenshotRegionAndAnnotateCmd = lib.mkOption {
          type = str;
          description = "Command to screenshot an interactive region and open it for annotation";
        };
        setWallpaperFn = lib.mkOption {
          type = functionTo str;
          description = "Function to set the given image as wallpaper";
        };
        shutdownCmd = lib.mkOption {
          type = str;
          description = "Command to exit Hyprland";
        };
      };

      config =
        with pkgs;
        let
          inherit (lib) getExe getExe';
          satty-wrapped = symlinkJoin {
            name = "satty-wrapped";
            paths = [ satty ];
            nativeBuildInputs = [ makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/satty --set-default LIBGL_ALWAYS_SOFTWARE 1
            '';
            meta = satty.meta or { } // {
              mainProgram = "satty";
            };
          };
          satty-pkg = if isVM then satty-wrapped else satty;

          ocrLanguages = [
            "eng"
            "ita"
            "nld"
          ];
          tesseract-pkg = tesseract.override { enableLanguages = ocrLanguages; };
          ocr = pkgs.writeShellScriptBin "ocr-region" ''
            ${getExe hyprshot} --freeze --raw -m region --silent \
              | ${getExe tesseract-pkg} stdin stdout -l ${lib.concatStringsSep "+" ocrLanguages} \
              | ${getExe' coreutils "tr"} -d '\f' \
              | ${getExe' wl-clipboard "wl-copy"}
          '';
        in
        {
          # commands
          desktop = {
            colorPickerCmd = "${getExe hyprpicker}";
            ocrCmd = "${getExe ocr}";
            screenshotMonitorCmd = "${getExe hyprshot} --freeze --clipboard-only -m output";
            screenshotRegionCmd = "${getExe hyprshot} --freeze --clipboard-only -m region";
            screenshotRegionAndAnnotateCmd = "${getExe hyprshot} --freeze --raw -m region | ${getExe satty-pkg} --filename -";
            setWallpaperFn = img: "${getExe swaybg} -m fill -i ${img}";
            shutdownCmd = if isVM then "hl.dsp.exit()" else "hl.dsp.exec_cmd('${getExe hyprshutdown}')";
          };

          # companion packages & programs
          home.packages = [ hyprpicker ocr ];
          programs = {
            hyprshot = {
              enable = true;
              package = hyprshot;
            };
            satty = {
              enable = true;
              package = satty-pkg;
            };
          };
        };
    };
}
