{ inputs, ... }:
{
  den.aspects.apps._.llm-agents.nixos = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
    environment.systemPackages = with pkgs.llm-agents; [
      dsh
      pi
    ];
  };
}
