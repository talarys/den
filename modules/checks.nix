{
  lib,
  self,
  ...
}:
let
  argosHm = self.nixosConfigurations.argos.config.home-manager.users.talarys;
  argos = self.nixosConfigurations.argos.config;

  # Cheap value-level probes for the wiring that has silently broken before
  # (see agents/AUDIT.md). A dropped class key or an unset `enable` shows up
  # here instead of at runtime.
  expect = name: cond: ''
    if [ "${lib.boolToString cond}" != "true" ]; then
      echo "FAIL: ${name}" >&2
      exit 1
    fi
  '';
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        # Forces the standalone home to evaluate fully: `home.username` /
        # `home.homeDirectory` come from `<den/define-user>`.
        home-talarys = self.homeConfigurations.talarys.activationPackage;

        argos-wiring = pkgs.runCommandLocal "check-argos-wiring" { } ''
          set -eu
          ${expect "timezone" (argos.time.timeZone == "Europe/Madrid")}
          ${expect "nushell-shell" (argos.users.users.talarys.shell != null)}
          ${expect "keychain" argosHm.programs.keychain.enable}
          ${expect "mimeapps" argosHm.xdg.mimeApps.enable}
          ${expect "git" argosHm.programs.git.enable}
          ${expect "git-signing" argosHm.programs.git.signing.signByDefault}
          touch $out
        '';
      };
    };
}
