{
  den.aspects.shell._.nh = {
    homeManager =
      { config, ... }:
      {
        programs.nh = {
          enable = true;
          osFlake = "${config.home.homeDirectory}/den";
        };
      };
  };
}
