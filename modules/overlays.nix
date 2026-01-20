{
  den.aspects.overlays.nixos =
    { inputs, ... }:
    {
      nixpkgs.overlays = [
        (_final: prev: {
          neovim = inputs.nixcats.packages.${prev.system}.default;
        })
      ];
    };
}
