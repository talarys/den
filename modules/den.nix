{
  inputs,
  den,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
    inputs.treefmt-nix.flakeModule

    # Aspect groups are namespaces: define `shell.fish` and include it as
    # `<shell/fish>`. `false` keeps them local (not exported as flake.denful).
    (inputs.den.namespace "apps" false)
    (inputs.den.namespace "containers" false)
    (inputs.den.namespace "desktop" false)
    (inputs.den.namespace "shell" false)
    (inputs.den.namespace "system" false)
  ];

  _module.args.__findFile = den.lib.__findFile;

  systems = builtins.attrNames den.hosts;

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
    programs.statix.enable = true;
    settings.global.excludes = [
      "agents/**"
      "denful/**"
      "*.md"
    ];
  };
}
