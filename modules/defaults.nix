{
  den,
  __findFile,
  inputs,
  ...
}:
{
  # Every user is a real account with a home directory: `define-user` also
  # covers standalone homes (`home.username` / `home.homeDirectory`), which the
  # home-manager NixOS module would otherwise provide only inside a host.
  den.schema.user.classes = [ "homeManager" ];

  # Hosts accept what their users write for them. Declared explicitly instead of
  # relying on den's transition defaults (removed 2027-01-01), so the behaviour
  # is stable across den updates and evaluation stays warning-free.
  den.schema.host.includes = [
    den.batteries.user-aspects
    den.batteries.mutual-provider
  ];

  den.default = {
    nixos.system.stateVersion = "26.11";
    homeManager.home.stateVersion = "26.11";

    nixos = {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.disko.nixosModules.disko
      ];

      nixpkgs.config.allowUnfree = true;
      programs.nix-index-database.comma.enable = true;
      programs.nix-ld.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
      };

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
            "https://nix-community.cachix.org"
            "https://cache.lantian.pub/lantian"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
          ];
        };
      };
    };

    homeManager = {
      systemd.user.startServices = "sd-switch";
    };

  };

  den.default.includes = [
    # Automatically create the user on host and define their home directory.
    <den/define-user>
    # Automatically create the user on host.
    <den/primary-user>
    # Automatically set hostname
    <den/hostname>
    # Allows host to ingest homeManager aspects
    <den/host-aspects>
  ];
}
