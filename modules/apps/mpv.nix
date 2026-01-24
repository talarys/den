{
  den.aspects.apps._.mpv.homeManager =
    { pkgs, ... }:
    {
      programs.mpv = {
        enable = true;
      };

      home.file.mpv = {
        source = pkgs.fetchFromGitHub {
          owner = "talarys";
          repo = "mpv-config";
          rev = "eng";
          sha256 = "sha256-lHogvK6EL4tp9vYyI0elqWIWSpV4d4NIWPHoISXcU80=";
        };
        target = ".config/mpv";
      };
    };
}
