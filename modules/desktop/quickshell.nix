{
  den.aspects.desktop._.quickshell =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        quickshell

        # Qt6 dependencies for Quickshell
        qt6.qt5compat
        qt6.qtbase
        qt6.qtquick3d
        qt6.qtwayland
        qt6.qtdeclarative
        qt6.qtsvg
      ];

      # Environment variables for Qt and Wayland
      environment.sessionVariables = {
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };
    };
}
