{
  den,
  inputs,
  ...
}:
{
  # One place for nixpkgs overlays. Overlays are host-level because
  # `home-manager.useGlobalPkgs = true` makes user packages share the host's
  # nixpkgs instance. Packages that only a user needs are referenced from their
  # flake input directly instead (see modules/apps/llm-agents.nix).
  den.aspects.overlays.nixos.nixpkgs.overlays = [
    (_final: prev: {
      neovim = inputs.neovim.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];
}
