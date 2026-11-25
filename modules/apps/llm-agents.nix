{
  apps,
  inputs,
  ...
}:
{
  # Packages come straight from the input instead of an overlay: the same
  # expression works in a host-embedded home (global pkgs) and in the standalone
  # home evaluation, where no host-level overlay exists.
  apps.llm-agents.homeManager =
    { pkgs, ... }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [
        llm-agents.dsh
        llm-agents.pi
      ];
    };
}
