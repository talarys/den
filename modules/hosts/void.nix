{
  inputs,
  den,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.void.users.talarys = { };

  den.aspects.void = {
    includes = with den; [ ];

    nixos = {
      imports = with inputs; [ ];
    };
  };

}
