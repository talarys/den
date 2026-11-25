{
  desktop,
  inputs,
  ...
}:
{
  # Optional desktop: enable with `<desktop/niri>` on a host and drop
  # `<desktop/kde>` / `<desktop/sddm>`.
  desktop.niri.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.dms.nixosModules.dank-material-shell ];

      environment.systemPackages = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        gnome-keyring
        cups-pk-helper
        xwayland-satellite
        fuzzel
      ];

      services.displayManager.dms-greeter = {
        enable = true;
        compositor.name = "niri";
      };

      programs = {
        niri.enable = true;

        # Option names come from the `dms` flake module (same as hyprland.nix).
        dank-material-shell = {
          enable = true;

          systemd = {
            enable = true; # Systemd service for auto-start
            restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
          };

          enableSystemMonitoring = true;
          enableVPN = true;
          enableDynamicTheming = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
        };
      };
    };
}
