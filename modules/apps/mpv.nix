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
          sha256 = "sha256-3/ujckxnT1eYg90qnOYcHrwGsHaZtvTG5U0C8cSVzHM=";
        };
        target = ".config/mpv";
      };
    };
}
