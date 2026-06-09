{
  den.aspects.desktop._.niri.nixos =
    { pkgs, ... }:
    {
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
        niri = {
          enable = true;
        };

        dms-shell = {
          enable = true;

          systemd = {
            enable = true; # Systemd service for auto-start
            restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
          };

          # Core features
          enableSystemMonitoring = true; # System monitoring widgets (dgop)
          enableVPN = true; # VPN management widget
          enableDynamicTheming = true; # Wallpaper-based theming (matugen)
          enableAudioWavelength = true; # Audio visualizer (cava)
          enableCalendarEvents = true; # Calendar integration (khal)
        };
      };
    };
}
