{
  __findFile,
  ...
}:
{

  den.homes.x86_64-linux.talarys = { };

  den.aspects.talarys = {
    includes = [
      <shell/distrobox>
      <shell/git>
      <shell/nh>
      <shell/nix-tools>
      <shell/utils>
      <shell/packages>
      <shell/aliases>
      <shell/fish>
      <shell/nushell>
      <shell/yazi>
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        users.users.talarys = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPassword = "$6$5LmYUUbAfFd.ru3K$aCWG8.Vw2WXtkiWFav/Z/Vu44x65oRb5TU41s.QG3nrFrACCPovyRdFuqIixo0hPAbAVY9cgr36gu6l4Kvtqt0";
          shell = lib.getExe pkgs.nushell;
        };
      };
  };
}
