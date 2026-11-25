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
      <shell/cli>
      <shell/dev>
      <shell/aliases>
      <shell/fish>
      <shell/nushell>
      <shell/yazi>
      <shell/env>
      <apps/llm-agents>

      # Default login shell at both the OS and home-manager level.
      (<den/user-shell> "nushell")
    ];

    # The account itself belongs to the `user` class: den routes it to
    # `users.users.talarys` on every host this user is declared on.
    # `isNormalUser` and the wheel/networkmanager groups come from
    # `<den/primary-user>` (modules/defaults.nix), so they are not repeated.
    user = {
      initialHashedPassword = "$6$5LmYUUbAfFd.ru3K$aCWG8.Vw2WXtkiWFav/Z/Vu44x65oRb5TU41s.QG3nrFrACCPovyRdFuqIixo0hPAbAVY9cgr36gu6l4Kvtqt0";
    };

    # The home directory / username for the standalone home and for
    # home-manager inside a host come from `<den/define-user>`.
  };
}
