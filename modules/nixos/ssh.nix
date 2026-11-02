{
  flake.modules.nixos.ssh = {
    programs.ssh = {
      enableAskPassword = false;
      forwardX11 = false;

      startAgent = true;
      agentTimeout = "3h";
    };
  };
}
