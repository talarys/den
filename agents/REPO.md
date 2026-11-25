# This repo — map, conventions, recipes

NixOS + home-manager flake built on [den](https://den.denful.dev). Read
[`DEN.md`](./DEN.md) first if you don't know den.

## Layout

```
flake.nix            inputs + flake-parts entry; `import-tree ./modules`
justfile             rebuild / update / disko helpers
README.md            human-facing overview
disko/               btrfs.nix (argos install layout), simple.nix (spare)
denful/              git-ignored read-only clones of den / flake-aspects / import-tree
agents/              these docs
modules/
  den.nix            den wiring: namespaces, __findFile, treefmt
  defaults.nix       den.default (all entities) + den.schema.* defaults
  checks.nix         flake checks that guard the wiring
  hosts/<host>.nix   den.hosts.<system>.<host> + that host's aspect
  users/<user>.nix   den.homes.<system>.<user> + that user's aspect
  overlays.nix       nixpkgs overlay aspect
  system/*.nix       nixos-class aspects
  shell/*.nix        home-manager aspects
  apps/*.nix         applications (split by class when needed)
  desktop/*.nix      compositors / display managers / theming
                     (`session.nix` maps a host's `session` to a bundle)
  containers/*.nix   podman services
```

`import-tree` imports **every `.nix` file under `modules/`** recursively: a new
file is picked up with no registration step, and every file's top-level value
must be a flake-parts module. `modules/apps/mpv/` also holds non-Nix data
(`shaders/`, `fonts/`, `*.conf`) which import-tree ignores.

**Nix only sees git-tracked files.** Create a module → `git add` it before
running `nix eval`/`nix build`, otherwise it is invisible. Deletions need
`git add` too (or `git rm`).

## Aspect grouping (namespaces)

Aspects are grouped in namespaces registered in `modules/den.nix`:

```nix
(inputs.den.namespace "shell" false)
```

A file then defines `shell.fish = { homeManager = ...; }` and a host/user
includes it as `<shell/fish>`. Namespaces in use: `apps`, `containers`,
`desktop`, `shell`, `system`. `den.aspects.overlays` is a plain aspect
(`<overlays>`).

Do **not** define `den.aspects.<namespace>.*` alongside a namespace with the
same name: angle brackets check `den.aspects.<head>` first, so the leftover
aspect shadows the namespace (see `AUDIT.md` F23).

## Entities

| Entity | Declared in | Aspect | Notes |
|---|---|---|---|
| host `argos` (x86_64-linux) | `modules/hosts/argos.nix` | `den.aspects.argos` | Daily driver: CachyOS Zen4 kernel, NVIDIA, `session = "plasma"`, gaming, btrfs disko, audiobookshelf. |
| host `void` (x86_64-linux) | `modules/hosts/void.nix` | `den.aspects.void` | NixOS-WSL. Minimal: overlays + ssh, no session. |
| user `talarys` on both | `den.hosts.*.users.talarys = { }` | `den.aspects.talarys` | `homeManager` via `den.schema.user.classes`. |
| standalone home `talarys` | `den.homes.x86_64-linux.talarys` | (same user aspect) | Guarded by `checks.home-talarys`. |

Global wiring in `modules/defaults.nix`:

- `den.schema.user.classes = lib.mkDefault [ "homeManager" ]` — home-manager for
  every user, still overridable per user (`classes` is a list; without
  `mkDefault` a per-user declaration would be *concatenated*, not chosen).
- `den.schema.host.home-manager.enable = true` — every host integrates
  home-manager regardless of user classes (den's own default derives it).
- `den.schema.host.includes = [ user-aspects mutual-provider ]` — hosts accept
  what users write for them, explicitly (not via den's 2027 transition default).
- `den.schema.user.includes = [ host-aspects ]` — every user takes the host's
  `homeManager` content.
- `den.default.includes = [ define-user primary-user hostname ]` — accounts, home
  dirs, wheel/networkmanager, hostname.
- `den.default.nixos` / `den.default.homeManager` use `lib.mkDefault` for
  `stateVersion`, so a host/user can pin its own.

## Aspect inventory

Included by `argos`: `overlays`, `system/{systemd-boot,locale,ssh,audio,fonts,cursors,networking,nvidia,gaming,xdg,podman}`,
`apps/{apps,ghostty,kitty,mpv,vicinae,zen}`, `containers/audiobookshelf`,
plus `desktop/plasma` (= `desktop/sddm` + `desktop/kde`) pulled in by the
`session` policy.

Included by `void`: `overlays`, `system/ssh`.

Included by user `talarys`: `shell/{distrobox,git,nh,nix-tools,utils,cli,dev,aliases,fish,nushell,yazi,env}`,
`apps/llm-agents`, `(<den/user-shell> "nushell")`.

Optional, defined but **not** included (verify before enabling):

| Aspect | File | Notes |
|---|---|---|
| `system/bluetooth` | `modules/system/bluetooth.nix` | ready to include |
| `system/virt` | `modules/system/virt.nix` | libvirt/qemu; groups via `provides.to-users.user` |
| `system/no-boot` | `modules/system/no-boot.nix` | CI helper from den's template |
| `desktop/plymouth` | `modules/desktop/plymouth.nix` | boot splash |
| `desktop/hyprland` | `modules/desktop/hyprland.nix` | selectable via `session = "hyprland"` |
| `desktop/niri` | `modules/desktop/niri.nix` | selectable via `session = "niri"` |
| `desktop/quickshell` | `modules/desktop/quickshell.nix` | Qt/Wayland deps only |
| `apps/localsend` | `modules/apps/localsend.nix` | home package only |

These are not evaluated by `nix flake check` (no host includes them), so treat
them as unreviewed until you enable one and run `just check`.

## Conventions

- One aspect per file; aspect name = feature (`nix-tools`, `mpv`).
- Namespace = broad domain (`shell`, `system`, `apps`, `desktop`, `containers`).
- Host files hold only host-specific hardware/boot/fs/virtualisation data; shared
  behaviour lives in `system/`, `apps/`, `desktop/`.
- User files hold the account (`user` class) and the list of included aspects.
- **Every setting needs a class key** (`nixos`, `homeManager`, `user`) or it is
  silently dropped. The only exceptions are structural keys (`includes`,
  `excludes`, `provides`, `policies`, `meta`, `name`, `description`) and nested
  aspects.
- Package ownership is exclusive: `nh`/nom/nix-tree in `shell/nh.nix`,
  lint/inspection tools in `shell/nix-tools.nix`, editors/LSPs in `shell/dev.nix`,
  CLI utilities in `shell/cli.nix`. Don't duplicate a package across aspects.
- Session environment variables (`EDITOR`, `BROWSER`, `PATH` additions) live only
  in `modules/shell/env.nix`.
- `den.default` / `den.schema.*` defaults that should stay overridable need
  `lib.mkDefault`. A plain list definition **concatenates** with another
  definition (e.g. `classes`), so a user could not opt out.
- `den.schema.<kind>` can be a module **or** a set of sub-attributes
  (`.includes`, `.home-manager.enable`, …), but not both at once: assigning
  `den.schema.host = <module>` alongside `den.schema.host.includes = …` fails
  with "attribute `den.schema.host` already defined".
- Shared data (ports, lists) goes through a **quirk**, not duplicated config:
  producers write `firewall.ports = [ … ]`, `system/networking.nix` aggregates
  and is the only place that opens ports.
- Per-host choices (which desktop) are **host freeform attributes** consumed by
  a policy (`session` + `den.policies.session`), never includes commented out.
- No `systems` in `modules/den.nix`: den derives flake-parts `systems` from
  `den.hosts` + `den.homes`.
- `with pkgs;` is used inside `home.packages` / `environment.systemPackages`
  lists; prefer `inherit` elsewhere.
- Format with `just fmt` (nixfmt + statix via treefmt). Do **not** add
  `deadnix`/`nixf-diagnose`: both report a lambda arg used only in an attribute
  path (`{ system, ... }: { system.x = 1; }`) as unused — den disables them in
  its own formatter for that reason.
- Format with `just fmt` (nixfmt + statix via treefmt). Commit messages:
  `type: summary` (`feat`, `fix`, `chore`, `docs`) — history is mixed, keep new
  commits clean.

## Recipes

### Switch a host's desktop session

```nix
# modules/hosts/<host>.nix
session = "niri";   # or "plasma" / "hyprland"
```

`modules/desktop/session.nix` maps the value to a bundle through
`den.lib.policy.include` and throws on an unknown value. Add a new desktop by
extending the `bundles` attrset there plus the aspect itself.

### Open a port for a service

Declare it on the aspect that needs it; never edit the firewall list:

```nix
containers.<svc> = {
  firewall.ports = [ 8081 ];
  nixos.virtualisation.oci-containers.containers.<svc>.ports = [ "8081:80" ];
};
```

`system/networking.nix` concatenates every `firewall.ports` entry in the host
scope (den quirk `firewall`).

### Add a package to every user

`modules/shell/cli.nix` (CLI tools) or `modules/shell/dev.nix` (toolchains).
GUI applications go to `modules/apps/apps.nix` (or their own file if they need
configuration).

### Add a system service for one host

Create `modules/system/<name>.nix`:

```nix
{ system, ... }:
{
  system.<name>.nixos = { pkgs, ... }: {
    services.<name>.enable = true;
    environment.systemPackages = [ pkgs.<name> ];
  };
}
```

Add `<system/<name>>` to the host's `includes` in `modules/hosts/argos.nix`.

### Add a new host

```nix
# modules/hosts/<name>.nix
{
  inputs,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.<name>.users.talarys = { };

  den.aspects.<name> = {
    nixos = { modulesPath, ... }: {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
      # hardware, boot, fileSystems, disko ...
    };

    includes = [
      <overlays>
      <system/systemd-boot>
      <system/locale>
      <system/networking>
    ];
  };
}
```

Name the aspect after the host: den looks it up by entity name, and `systems` in
`modules/den.nix` derives from `den.hosts`.

### Add a new user

`den.hosts.x86_64-linux.<host>.users.<user> = { };` plus
`modules/users/<user>.nix`:

```nix
{
  __findFile,
  ...
}:
{
  # only if they need a standalone home
  den.homes.x86_64-linux.<user> = { };

  den.aspects.<user> = {
    includes = [
      <shell/cli>
      <shell/fish>
      # <den/primary-user> only if admin
      (<den/user-shell> "fish")
    ];

    user = {
      extraGroups = [ "video" ];
      # never commit a plaintext secret; see AUDIT.md F19
    };
  };
}
```

### Home-manager config for one host only

Prefer explicit edges over relying on the host's whole tree:

```nix
# all users on the host
den.aspects.<host>.provides.to-users.homeManager.programs.foo.enable = true;

# one user on the host
den.aspects.<host>.provides.<user>.homeManager.programs.foo.enable = true;
```

### NixOS config from a user aspect

```nix
den.aspects.<user>.provides.to-hosts.nixos.services.foo.enable = true;
```

`user` class for account settings, `homeManager` for the home, and only
`provides.to-hosts`/`provides.<host>` for host-wide changes.

## Environment facts

- Home: `/home/talarys`; flake at `/home/talarys/den`
  (`programs.nh.osFlake`, `NH_OS_FLAKE`).
- Login shell: `nushell` (via `<den/user-shell>`); `fish` configured too.
- `EDITOR`/`VISUAL`/`GIT_EDITOR` = `nvim` (single source: `shell/env.nix`).
- Caches: `nix-community.cachix.org` + `cache.lantian.pub` (CachyOS kernel).

## Verification

```sh
just check     # nix flake check: builds checks/home-talarys + argos-wiring, treefmt
```

For a single option:

```sh
nix eval --json .#nixosConfigurations.argos.config.time.timeZone
nix eval --json .#nixosConfigurations.argos.config.home-manager.users.talarys.programs.git.enable
```
