{
  den,
  __findFile,
  inputs,
  ...
}:
{
  den.schema.host.home-manager.enable = true;
  den.schema.user.classes = [ "homeManager" ];

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
    # Automatically create the user on host.
    <den/primary-user>
    # Automatically set hostname
    <den/hostname>
    # Allows host to ingest homeManager aspects
    <den/host-aspects>
  ];
}
