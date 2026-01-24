{
  den.aspects.system._.ssh.provides = {
    client.homemanger.services.ssh-agent = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    server.nixos.services.openssh = {
      enable = true;
    };
  };
}
