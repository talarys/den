{
  den.aspects.apps._.apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        obsidian
        qbittorent
        blender
      ];
    };
}
