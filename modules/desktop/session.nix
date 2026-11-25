{
  den,
  desktop,
  lib,
  ...
}:
let
  # One bundle per selectable graphical session.
  bundles = {
    inherit (desktop) plasma;
    inherit (desktop) niri;
    inherit (desktop) hyprland;
  };

  names = lib.concatStringsSep ", " (builtins.attrNames bundles);
in
{
  # Plasma needs SDDM; niri/hyprland bring their own DMS greeter.
  desktop.plasma.includes = [
    desktop.sddm
    desktop.kde
  ];

  # Hosts select their session with the freeform host attribute `session`
  # (`den.hosts.x86_64-linux.<host>.session = "plasma";`). A policy attaches the
  # matching aspect, so machines never need includes commented in and out.
  # Activate the policy for every host.
  den.schema.host.includes = [ den.policies.session ];

  den.policies.session =
    { host, ... }:
    let
      session = host.session or null;
      bundle =
        if session == null then
          null
        else
          bundles.${session}
            or (throw "den: host '${host.name}' has unknown session '${session}'; expected one of: ${names}");
    in
    lib.optional (bundle != null) (den.lib.policy.include bundle);
}
