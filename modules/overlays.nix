{ inputs, ... }:
{
  den.aspects.overlays.nixos = {
    nixpkgs.overlays = [
      (_final: prev: {
        neovim = inputs.neovim.packages.${prev.system}.default;
      })
    ];
  };
}
