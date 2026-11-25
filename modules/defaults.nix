{
  den,
  __findFile,
  inputs,
  lib,
  ...
}:
{
  # Every user is a real account with a home directory: `define-user` also
  # covers standalone homes (`home.username` / `home.homeDirectory`), which the
  # home-manager NixOS module would otherwise provide only inside a host.
  # mkDefault so a host/user declaration can still pick a different set of
  # classes (`classes` is a list, so a plain definition would be concatenated).
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Explicit: every host integrates home-manager, whatever its users declare.
  # The option defaults to "this host has a user with the homeManager class".
  den.schema.host.home-manager.enable = true;

  # Hosts accept what their users write for them. Declared explicitly instead of
  # relying on den's transition defaults (removed 2027-01-01), so the behaviour
  # is stable across den updates and evaluation stays warning-free.
  den.schema.host.includes = [
    den.batteries.user-aspects
    den.batteries.mutual-provider
  ];

  # Every user takes the host's `homeManager` content (battery docs: "every user
  # on every host opts in"). Put on the user schema, where it belongs, instead
  # of on `den.default` which is also walked in host scope.
  den.schema.user.includes = [ den.batteries.host-aspects ];

  den.default = {
    # Fleet-wide defaults; mkDefault so a host or user can pin its own.
    nixos.system.stateVersion = lib.mkDefault "26.11";
    homeManager.home.stateVersion = lib.mkDefault "26.11";

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
  ];
}
