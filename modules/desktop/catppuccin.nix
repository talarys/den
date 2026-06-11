{ inputs, lib, ... }:
{
  den.aspects.desktop._.catppuccin =
    {
      flavor ? "mocha",
      accent ? "lavender",
    }:
    {
      nixos = {
        imports = [ inputs.catppuccin.nixosModules.default ];
        catppuccin = {
          enable = true;
          inherit flavor accent;
        };
      };

      homeManager =
        { config, pkgs, ... }:
        {
          imports = [
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-colors.homeManagerModule
          ];

          catppuccin = {
            enable = true;
            autoEnable = false;
            inherit flavor accent;
          };

          colorScheme = inputs.nix-colors.colorSchemes."catppuccin-${flavor}";

          qt = {
            # style.catppuccin.enable = (config.qt.platformTheme.name == "kvantum");
            style.name = lib.mkDefault "kvantum";
            platformTheme.name = lib.mkDefault "kvantum";
            kde.settings.kdeglobals.UI.ColorScheme = "*";
          };

          gtk.gtk3.theme = {
            name = "adw-gtk3";
            package = pkgs.adw-gtk3;
          };
        };
    };
}
