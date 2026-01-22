{ inputs, ... }:
{
  den.aspects.overlays.nixos = {
    nixpkgs.overlays = [
      (_final: prev: {
        neovim = inputs.nixcats.packages.${prev.system}.default;
      })
    ];
  };
}
