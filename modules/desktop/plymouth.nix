{
  den.aspects.desktop._.plymouth.nixos =
    { pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        themePackages = [ (pkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
        theme = "catppuccin-mocha";
      };
    };
}
