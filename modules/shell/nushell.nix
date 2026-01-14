{
  den.aspects.shell._.nushell.homeManager = {
    programs = {
      nushell = {
        enable = true;
        extraConfig = ''
          $env.config.show_banner = false
        '';
        shellAliases = { };
      };
    };
  };
}
