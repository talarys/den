{
  den.aspects.shell._.nushell.homeManager = {
    programs = {
      nushell = {
        enable = true;
        extraConfig = ''
          $env.config.show_banner = false
          $env.PATH ++= ['/home/talarys/.bun/bin']
          $env.PATH ++= ['/home/talarys/.npm-global/bin']
          $env.PATH ++= ['/home/talarys/.local/bin']
           if ($env.TERM_PROGRAM? == "WezTerm") {
                $env.config.shell_integration.osc133 = false
           }
        '';
        shellAliases = { };
      };
    };
  };
}
