{ inputs, ... }:
{
  den.aspects.overlays.nixos = {
    nixpkgs.overlays = [
      (_final: prev: {
        neovim = inputs.nvix.packages.${prev.system}.default;
      })
    ];
  };
}
