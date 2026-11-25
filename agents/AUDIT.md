# Audit — findings and resolutions

Audited at commit `15d3952` against den `12b2146`; all items below were applied
and verified. Every "actual" value was read from a real `nix eval`/`nix build`
against this flake; the commands are kept so a future agent can re-check.

Verification gate used for the whole batch:

```sh
nix eval .#nixosConfigurations --apply builtins.attrNames   # both hosts
nix build .#checks.x86_64-linux.home-talarys                # standalone home
nix flake check                                             # checks + treefmt
```

## Status

| # | Finding | Resolution |
|---|---|---|
| F1 | `time.timeZone` unset — locale aspect had no class key | `system.locale.nixos` |
| F2 | keychain never enabled — `homeManger` typo | `system.ssh.homeManager` |
| F3 | mime apps inert — `xdg.mimeApps.enable` false | enabled explicitly |
| F4 | disko override targeted a non-existent disk | device fixed in `disko/btrfs.nix`, hack removed |
| F5 | git config never applied — aspect commented out | `<shell/git>` included |
| F6 | `homeConfigurations.talarys` did not evaluate | `<den/define-user>` added |
| F7 | `nix fmt` broken — no formatter output | `treefmt-nix.flakeModule` + nixfmt/statix |
| F8 | user-level `nixos` content relied on den's 2027 transition default | explicit `user-aspects` + `mutual-provider`; llm-agents moved to `homeManager`; account moved to `user` class |
| F9 | stale flake path in fish | `nh os switch` abbreviation |
| F10 | hard-coded `/home/talarys` PATH in nushell | `home.sessionPath` |
| F11 | duplicated wireless stack, open dev ports, ignored `nameservers` | duplicate settings removed; `networking.wireless` is nixpkgs' own default under NM; firewall reduced to 80/443/13378 |
| F12 | deprecated `pipewire.jack`, `pulseaudio` package | both removed |
| F13 | deprecated `prev.system` in overlay | `prev.stdenv.hostPlatform.system` |
| F14 | duplicated/contradictory env vars and packages | `shell/env.nix` is the only session-env source; package ownership split per aspect |
| F15 | `den.schema.host.home-manager.enable` thought to be a no-op | **corrected in round 2**: it is a real option (`host.home-manager.enable`, default derived from user classes). Re-added explicitly. |
| F16 | yazi plugins pinned to `rev = "main"` | pinned to commits (hashes re-prefetched) |
| F17 | Steam/Wine installed twice / system-wide | duplicate and system-wide Wine/dxvk removed |
| F18 | `libvirtd.qemu.runAsRoot = true` | removed (default false); groups now via `provides.to-users.user` |
| F19 | password hash committed | `initialHashedPassword` (mutable account), redundant user fields removed; moving it to a secret store is still recommended |
| F20 | 109 MB tracked (unused background, CJK fonts, shaders) | background + vendored Noto CJK deleted (system fonts remain); shaders kept — `mpv.conf` references their paths |
| F21 | unused inputs, duplicated nixpkgs | `nixcats`, `nvix`, `catppuccin`, `nix-colors` removed (`nixpkgs` ×1 + kernel's own) |
| F22 | `denful/` untracked | added to `.gitignore` |
| F23 | legacy `provides`/`_` grouping everywhere | migrated to `den.namespace` (`apps`, `containers`, `desktop`, `shell`, `system`) |
| F24 | overlay in a user aspect | overlay removed; packages referenced from the flake input |
| F25 | no tests/checks | `modules/checks.nix` guards the wiring above |
| F26 | no docs | `README.md` + `agents/` |
| F27 | commit style | documented in `agents/REPO.md`; history not rewritten |

Items that were **not** changed on purpose:

- `nix-cachyos-kernel` still brings its own nixpkgs: the kernel patches and the
  `cache.lantian.pub` cache are built against it. Forcing `nixpkgs.follows`
  trades a second evaluation for cache misses and likely build failures. A
  comment in `flake.nix` says so.
- The vendored mpv shaders stay: `modules/apps/mpv/mpv.conf` refers to them by
  path (`~~/shaders/...`), so replacing them with nixpkgs packages means
  rewriting those profiles.
- `warning: unknown flake output 'denful'` remains: den always emits the output;
  it only carries content when a namespace is exported (`true`).

---

## Details worth remembering

### F1 — a class key is mandatory

```nix
# broken: `i18n`/`time` are nested aspects, dropped silently
den.aspects.x = { i18n.defaultLocale = "..."; time.timeZone = "..."; };
```

Probe that caught it: `nix eval --json .#nixosConfigurations.argos.config.time.timeZone`
was `null`.

### F6 — `nix flake check` does not evaluate `homeConfigurations`

Nix treats that output as unknown, so the broken standalone home passed
`nix flake check` for months. `modules/checks.nix` now forces
`homeConfigurations.talarys.activationPackage`.

### F8 — the scope rule

Content a **user** aspect writes under `nixos` reaches the host only through
`den.batteries.user-aspects` (or `provides.to-hosts` with `mutual-provider`).
Both are now included in `modules/defaults.nix`, and the user aspect no longer
carries host-class content:

- account settings → `user` class (`den.aspects.talarys.user`).
- `EDITOR`/`PATH` → `homeManager` (`shell/env.nix`).
- `dsh`/`pi` packages → `homeManager` (`apps/llm-agents.nix`).

### F23 — namespace collision (important)

Registering `inputs.den.namespace "desktop" false` creates `den.ful.desktop`.
Angle-bracket resolution checks `den.aspects.<head>` **first**, so any leftover
`den.aspects.desktop.*` shadows the namespace and `<desktop/sddm>` fails with
"Aspect 'desktop' has no key 'sddm'". That is why `modules/desktop/catppuccin.nix`
(a dead aspect still defined as `den.aspects.desktop._.catppuccin`) had to be
removed as part of the migration.

Rule: never mix `den.aspects.<name>` and a namespace `<name>`.

### F25 — what the checks cover

`modules/checks.nix` builds `homeConfigurations.talarys.activationPackage` and
probes: timezone, the user's login shell, keychain, mime apps, git, git signing.
Add a probe whenever you fix a "silently dropped config" bug — it is the only
regression net this repo has.

### New files and git

Nix only sees `git`-tracked files. A newly created module is invisible to
`nix eval`/`nix build` until it is `git add`ed, which looks like "my change did
nothing". Same for deletions: `rm` without `git add` leaves the file in the
store/check output. `treefmt` also corrupts its cache if you forget; run
`nix run .#formatter.x86_64-linux -- --no-cache` to force a clean pass.

---

# Round 2 — den best-practice audit

Second pass, this time against the *den* documentation and templates
(`denful/den/docs/`, `denful/den/templates/`) rather than against runtime
correctness. Checked den `12b2146` (the locked rev) with the local clone at
`fa26ee3`.

| # | Finding | Resolution |
|---|---|---|
| D1 | `den.schema.user.classes` was a plain definition. `classes` is a list, so a per-user declaration **concatenates** with it; a user could not opt out of home-manager. den's own from-zero-to-den guide uses `lib.mkDefault`. | `lib.mkDefault [ "homeManager" ]` |
| D2 | `den.default` stateVersions were plain definitions, so no host/user could pin its own. den's guide point 3 uses `lib.mkDefault`. | both `lib.mkDefault` |
| D3 | `modules/den.nix` declared `systems = builtins.attrNames den.hosts;`. den already sets flake-parts `systems` from `den.hosts` **+ `den.homes`** (`den/modules/outputs/systems.nix`), so the manual list could drift (e.g. a home on a system with no host). | removed; comment explains why |
| D4 | Round 1 removed `den.schema.host.home-manager.enable` calling it a no-op. It is a real option (`host.home-manager.enable`, default = "this host has a user with the class"); `declare-hosts` documents it as the way to "specify features of all hosts". | re-added explicitly |
| D5 | `<den/host-aspects>` sat in `den.default.includes`, which is walked in host scope too. The battery's documented form for "every user opts in" is `den.schema.user.includes`. | moved to `den.schema.user.includes` |
| D6 | Firewall ports were hardcoded in `system/networking.nix` **and** in the container's `ports`, with 13378 declared twice (and only reachable by reading the container). This is den's canonical **quirk** example. | `den.quirks.firewall`; the container emits `firewall.ports = [ 13378 ]`, `system/networking.nix` aggregates |
| D7 | Optional desktops were selected by commenting includes in `modules/hosts/argos.nix` (`# <desktop/niri>`), i.e. dormant code. den's mechanism for "attach an aspect by a rule" is a policy. | host freeform attribute `session = "plasma";` + `den.policies.session` in `modules/desktop/session.nix`, with a validated error for typos |
| D8 | `den.schema.<kind>` cannot be assigned a module *and* have sibling sub-options at the same time ("attribute `den.schema.host` already defined"). Sibling attributes (`.includes`, `.home-manager.enable`) merge fine. | avoided by using host freeform metadata for `session`; documented in `DEN.md` |
| D9 | checkmate (`nix flake check --override-input target . github:denful/checkmate`), den's own CI harness, enables `deadnix` and `nixf-diagnose`. Both report **false positives** on this repo: a lambda arg used only in an attribute path (`{ system, ... }: { system.x = 1; }`) is reported unused. den itself disables both in `checkmate/modules/formatter.nix`. | not added to `treefmt`; `nixfmt` + `statix` stay |

## How D6 and D7 look

```nix
# modules/system/networking.nix — the only place that opens ports
system.networking.nixos = { firewall, lib, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ] ++ lib.concatMap (f: f.ports or [ ]) firewall;
};

# modules/containers/audiobookshelf.nix — declares, does not open
containers.audiobookshelf.firewall.ports = [ 13378 ];
```

```nix
# modules/hosts/argos.nix — no commented includes
den.hosts.x86_64-linux.argos = {
  users.talarys = { };
  session = "plasma";
};
```

`modules/desktop/session.nix` maps `session` to a bundle (`plasma` =
`desktop.sddm` + `desktop.kde`; `niri` and `hyprland` bring their own greeter)
through `den.lib.policy.include`, and throws on an unknown value:

```
den: host 'argos' has unknown session 'gnome'; expected one of: hyprland, niri, plasma
```

## Probes used for round 2

```console
# classes is a list: without mkDefault this stays true even when the user opts out
$ nix eval --json .#nixosConfigurations.argos.config.home-manager.users --apply builtins.attrNames
# with `users.talarys.classes = [ "user" ]` -> option `home-manager` disappears

# quirk aggregation
$ nix eval --json .#nixosConfigurations.argos.config.networking.firewall.allowedTCPPorts
[80,443,13378]

# policy selection
$ nix eval --json .#nixosConfigurations.argos.config.services.xserver.desktopManager.plasma6.enable
true
$ nix eval --json .#nixosConfigurations.void.config.services.displayManager.sddm.enable
false
```

## Kept as-is on purpose

- `den.aspects.overlays` is a top-level aspect, not in a namespace: it is
  cross-cutting (every host's nixpkgs), not a `system/` feature. The CachyOS
  kernel overlay stays in `modules/hosts/argos.nix` with the kernel choice it
  belongs to.
- The `settings` pattern (reserved `settings` key + generated option type) would
  only pay off with several hosts tuning the same reusable aspect; today each
  host owns its own file. See den's `guides/aspect-settings`.
- `den.lib.strict` / `isStrict` was not enabled: it would turn every undeclared
  host attribute into an error, which conflicts with the `session` freeform
  attribute above unless it is declared as a schema option first.
