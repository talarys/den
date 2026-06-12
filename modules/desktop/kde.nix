{ __findFile, ... }:
{
  den.aspects.desktop._.kde = {
    nixos = {
      security.pam.services.sddm.enableKwallet = true;
      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true;
      services.xserver.xkb.layout = "us";
      programs.kdeconnect.enable = true;
    };
  };
}
