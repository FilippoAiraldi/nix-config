{ config, ... }:
{
  programs.nixvim.plugins.wilder = {
    enable = true;

    options = {
      renderer = config.lib.nixvim.mkRaw ''
        wilder.popupmenu_renderer(
          wilder.popupmenu_border_theme({
            highlights = { border = 'Normal' },
            border = 'rounded',
            pumblend = 20,
          })
        )
      '';
      use_python_remote_plugin = 0;
    };

    settings.modes = [
      ":"
      "/"
      "?"
    ];
  };
}
