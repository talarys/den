{ inputs, ... }:
{
  den.aspects.desktop._.hyprland.nixos =
    { pkgs, ... }:
    {
      imports = with inputs; [
        dms.nixosModules.dank-material-shell
      ];

      environment = {
        systemPackages = with pkgs; [
          kdePackages.dolphin
          qt5.qtwayland
          qt6.qtwayland
          hyprpaper
          hyprpicker
          hyprlauncher
          hypridle
          hyprlock
          hyprpolkitagent
          hyprland-qt-support
          hyprpwcenter
          hyprshutdown
        ];
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };
      };

      services = {
        displayManager.dms-greeter = {
          enable = true;
          compositor.name = "hyprland";
        };
        hypridle.enable = true;
      };

      programs = {
        hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
        };

        hyprlock.enable = true;

        dank-material-shell = {
          enable = true;

          systemd = {
            enable = true; # Systemd service for auto-start
            restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
          };

          # Core features
          enableSystemMonitoring = true; # System monitoring widgets (dgop)
          # enableVPN = true; # VPN management widget
          enableDynamicTheming = true; # Wallpaper-based theming (matugen)
          enableAudioWavelength = true; # Audio visualizer (cava)
          enableCalendarEvents = true; # Calendar integration (khal)
        };
      };
    };
}
