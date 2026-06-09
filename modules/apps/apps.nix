{
  den.aspects.apps._.apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        obsidian
        qbittorrent
        blender
        zathura
        feh
        nsxiv
        readest
        calibre
        vscode
        whatsie
        zapzap
      ];
    };
}
