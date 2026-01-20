{
  den.aspects.system._.xdg = {
    nixos = {
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

    homeManager = {
      xdg = {
        enable = false;
        cacheHome = "";
        configHome = "";
        dataHome = "";
        userDirs = {
          desktop = "";
          documents = "";
          download = "";
          music = "";
          pictures = "";
          publicShare = "";
          templates = "";
          videos = "";
          createDirectories = true;
        };
      };
    };
  };
}
