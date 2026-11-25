{ system, ... }:
{
  system.cursors.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        capitaine-cursors
      ];
    };
}
