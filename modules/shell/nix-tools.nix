{ shell, ... }:
{
  shell.nix-tools = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # Nix development / inspection. `nh`, nom, nix-tree and friends are
          # owned by modules/shell/nh.nix.
          deadnix
          nix-init
          nix-inspect
          nixpkgs-review
          nix-update
          nurl
          statix
          vulnix
        ];
      };
  };
}
