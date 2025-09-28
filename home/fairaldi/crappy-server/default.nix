{ nhModules, ... }:
{
  imports = [
    "${nhModules}/common"
    "${nhModules}/programs/neovim"
  ];
}
