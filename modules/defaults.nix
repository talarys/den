{
  den,
  __findFile,
  ...
}:
{
  den.default = {
    nixos.system.stateVersion = "25.05";
    homeManager.home.stateVersion = "25.05";
  };

  den.default.includes = [
    # Enable home-manager on all hosts.
    <den/home-manager>

    # Automatically create the user on host.
    <den/primary-user>

    # Disable booting when running on CI on all NixOS hosts.
    <no-boot>
    # Autoset hostname
    (den.lib.take.exactly (
      { OS, host }:
      den.lib.take.unused OS {
        nixos.networking.hostName = host.hostName;
      }
    ))
  ];
}
