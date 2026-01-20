{
  den,
  __findFile,
  ...
}:
{
  den.default = {
    nixos = {
      system.stateVersion = "25.05";
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      home.stateVersion = "25.05";
    };

    systemd.user.startServices = "sd-switch";

    nix = {
      settings = {
        warn-dirty = false;
        extra-system-features = [ "recursive-nix" ];
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
          "recursive-nix"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

  };

  den.default.includes = [
    # Enable home-manager on all hosts.
    <den/home-manager>

    # Automatically create the user on host.
    <den/primary-user>

    # Autoset hostname
    (den.lib.take.exactly (
      { OS, host }:
      den.lib.take.unused OS {
        nixos.networking.hostName = host.hostName;
      }
    ))
  ];
}
