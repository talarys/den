{
  den.aspects.system._.cursors.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        capitaine-cursors
      ];
    };
}
