{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        # Nix
        nixfmt.enable = false;
        keep-sorted.enable = true;
        # Others
        prettier.enable = true;
        shfmt.enable = true;
        yamlfmt.enable = true;
      };
      settings = {
        on-unmatched = "warn";
        global.excludes = [
          "*.jpg"
          "*.png"
          "*.toml"
          "*/.gitignore"
          "*karabiner/**"
          "LICENSE"
          "envdis"
          "modules/_scripts/*"
        ];
      };
    };
  };
}
