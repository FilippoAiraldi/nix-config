{ lib, ... }:
{
  options.theme = {
    colors = lib.mkOption {
      type = lib.types.attrsOf (lib.types.strMatching "[0-9a-fA-F]{6}");
      default = { };
      description = "Color palette as bare RRGGBB hex (no leading # or 0x)";
    };
    colorFmt = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Methods to format colors into proper strings.";
    };
  };

  config.theme = {
    colors = {
      # https://coolors.co
      baby-blue-ice = "89b4fa";
      ink-black = "11111b";
      lavender = "cdd6f4";
      shadow-grey = "181825";
      space-indigo = "313244";
    };
    colorFmt = {
      hex = color: "#${color}";
      rgba = color: alpha: "${color}${alpha}";
    };
  };
}
