{
  __findFile,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.void.users.talarys = { };

  den.aspects.void = {
    nixos = {
      imports = [ inputs.nixos-wsl.nixosModules.wsl ];

      networking.hostName = "void";

      wsl = {
        enable = true;
        defaultUser = "talarys";
        docker-desktop.enable = true;
      };
    };

    includes = [
      <overlays>
      <system/ssh>
    ];
  };
}
