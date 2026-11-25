{
  system,
  ...
}:
{
  system.networking.nixos = {
    networking = {
      # NetworkManager owns interfaces and DNS; do not also enable
      # `networking.wireless` (they fight over wpa_supplicant) and do not set
      # `networking.nameservers` (ignored while NM manages resolv.conf).
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
          13378 # audiobookshelf
        ];
      };
    };
  };
}
