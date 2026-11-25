{
  shell,
  ...
}:
{
  shell.nushell.homeManager = _: {
    programs.nushell = {
      enable = true;
      extraConfig = ''
        $env.config.show_banner = false
        if ($env.TERM_PROGRAM? == "WezTerm") {
          $env.config.shell_integration.osc133 = false
        }
      '';
      # `home.sessionPath` (see modules/shell/env.nix) exports PATH additions
      # for nushell, fish and bash without hard-coding the home directory.
      shellAliases = { };
    };
  };
}
