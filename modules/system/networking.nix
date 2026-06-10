{
  den.aspects.system._.networking = {
    nixos = {
      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            80
            443
            3000
            5173
            8080
          ];
          allowedUDPPorts = [ 3377 ];
        };
        networkmanager.enable = true;
        wireless.enable = true;
        nameservers = [
          "1.1.1.1" # Cloudflare
          "8.8.8.8" # Google
        ];
      };
    };
  };
}
