{
  den.aspects.desktop._.sddm.nixos =
    { pkgs, ... }:
    {
      services.displayManager.sddm = {
        enable = true;
        extraPackages = [ pkgs.sddm-astronaut ];
        theme = "sddm-astronaut-theme";
        wayland.enable = true;
      };
    };
}
