{ shell, ... }:
{
  shell.distrobox.homeManager.programs = {
    distrobox.enable = true;
    distrobox.enableSystemdUnit = false;
  };
}
