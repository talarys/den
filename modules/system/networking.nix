{
  system,
  ...
}:
{
  # Quirk (den's canonical example): any aspect can declare the ports a service
  # listens on; this aspect is the only one that opens them. See
  # modules/containers/audiobookshelf.nix for a producer.
  den.quirks.firewall = {
    description = "Firewall port declarations";
  };

  system.networking.nixos =
    { firewall, lib, ... }:
    {
      networking = {
        # NetworkManager owns interfaces and DNS; do not also enable
        # `networking.wireless` (they fight over wpa_supplicant) and do not set
        # `networking.nameservers` (ignored while NM manages resolv.conf).
        networkmanager.enable = true;

        firewall = {
          enable = true;

          # Ports this aspect itself is responsible for.
          allowedTCPPorts = [
            80
            443
          ]
          # Ports declared by other aspects.
          ++ lib.concatMap (f: f.ports or [ ]) firewall;
        };
      };
    };
}
