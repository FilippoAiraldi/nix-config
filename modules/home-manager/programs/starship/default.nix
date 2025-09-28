{ ... }:
{
  # Starship configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      directory = {
        style = "bold lavender";
      };
      golang = {
        symbol = " ";
      };
      helm = {
        symbol = " ";
      };
      gradle = {
        symbol = " ";
      };
      java = {
        symbol = " ";
      };
      kotlin = {
        symbol = " ";
      };
      lua = {
        symbol = " ";
      };
      package = {
        symbol = " ";
      };
      php = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
    };
  };

  # Enable catppuccin theming for starship.
  catppuccin.starship.enable = true;
}
