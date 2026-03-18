{
  den.aspects.apps._.mpv.homeManager =
    { pkgs, ... }:
    {
      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          mpv-cheatsheet-ng
          evafast
          dynamic-crop
          quality-menu
          eisa01.simplehistory
          eisa01.simplebookmark
          eisa01.smart-copy-paste-2
        ];
      };

      home.file = {
        ".config/mpv/shaders".source = ./shaders;
        ".config/mpv/fonts".source = ./fonts;
        ".config/mpv/input.conf".source = ./input.conf;
        ".config/mpv/inputevent_key.conf".source = ./inputevent_key.conf;
        ".config/mpv/mpv.conf".source = ./mpv.conf;
      };
    };
}
