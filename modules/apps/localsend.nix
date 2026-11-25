{
  apps,
  ...
}:
{
  # LocalSend is a GUI application; the package is the whole feature (there is
  # no `programs.localsend` NixOS module).
  apps.localsend.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
