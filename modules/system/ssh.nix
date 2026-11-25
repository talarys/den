{
  system,
  ...
}:
{
  # ssh-agent + key management for the user session.
  system.ssh.homeManager = {
    programs.keychain = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      keys = [ "id_ed25519" ];
    };
  };
}
