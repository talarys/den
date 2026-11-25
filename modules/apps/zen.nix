{
  apps,
  inputs,
  ...
}:
{
  apps.zen.homeManager = {
    imports = [ inputs.zen-browser.homeModules.default ];
    programs.zen-browser.enable = true;
    # `BROWSER` is exported once in modules/shell/env.nix.
  };
}
