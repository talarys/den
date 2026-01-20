{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.void.users.talarys = { };

  den.aspects.void = {
    includes = [
      <system/no-boot>
      <overlays>
    ];
  };
}
