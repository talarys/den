{
  den.aspects.system._.ssh = {
    homeManger = {
      programs.keychain = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        keys = [ "id_ed25519" ];
        agents = [ "ssh" ];
      };
    };
  };
}
