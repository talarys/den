# den

My NixOS configuration, built with [den](https://den.denful.dev) —
aspect-oriented Nix on top of `flake-parts` + `import-tree`.

## Machines

| Host | What it is |
|---|---|
| `argos` | Daily driver: Ryzen/NVIDIA desktop, CachyOS Zen4 kernel, `session = "plasma"` (KDE Plasma 6 + SDDM), gaming stack, btrfs-on-NVMe (disko), audiobookshelf container. |
| `void` | NixOS-WSL, minimal (no graphical session). |

User `talarys` on both, with a standalone home-manager configuration as well.

## How it is organised

```
flake.nix      inputs + the flake-parts entry point (import-tree ./modules)
justfile       rebuild / update / disko helpers
disko/         disk layouts
modules/
  den.nix      den wiring: namespaces, angle brackets, treefmt
  defaults.nix settings for every host/user (den.default, den.schema)
  checks.nix   flake checks that guard the wiring below
  hosts/       one file per host: entity + host aspect (hardware, boot, disko)
  users/       one file per user: entity + user aspect (account, aspect list)
  system/      NixOS-class aspects: audio, fonts, networking, nvidia, ...
  shell/       home-manager aspects: fish, nushell, cli, dev, git, ...
  apps/        applications, split by class where needed
  desktop/     compositors, display managers, session policy, theming
  containers/  podman services (declare `firewall.ports`, never edit the firewall)
  overlays.nix nixpkgs overlays
agents/        documentation for AI agents (and humans) working on this repo
```

Aspects live in **namespaces** (`shell`, `system`, `apps`, `desktop`,
`containers`): a file defines `shell.fish = { homeManager = ...; }` and a host
includes it as `<shell/fish>`. Cross-cutting choices are declarative: a host sets
`session = "plasma"` and a policy includes the right desktop bundle; a service
declares `firewall.ports` and one aspect opens them.

Every file under `modules/` is imported automatically. New files must be
`git add`ed before Nix can see them.

## Commands

```sh
just rebuild          # nh os switch .
just up               # update all flake inputs
just upp <input>      # update one input
just check            # nix flake check (builds the checks in modules/checks.nix)
just fmt              # nixfmt + statix via treefmt
just repl             # nh os repl
just clean            # garbage collect
```

## Adding things

- **a package for all users** → `modules/shell/cli.nix` or `modules/shell/dev.nix`
- **a GUI app** → `modules/apps/apps.nix`, or its own file if it needs config
- **a system service** → new file under `modules/system/`, then add
  `<system/<name>>` to the host's `includes` in `modules/hosts/<host>.nix`
- **a listening port** → `firewall.ports = [ … ]` on the aspect that owns the
  service; `system/networking.nix` opens it
- **a different desktop** → `session = "niri"` (or `plasma`, `hyprland`) on the
  host
- **a host / user** → copy the shape of `modules/hosts/argos.nix` /
  `modules/users/talarys.nix`

## Notes

- `denful/` is a git-ignored read-only checkout of the den sources used as
  reference material.
- Agent-facing documentation (den semantics, repo conventions, known traps) is
  in [`agents/`](./agents/README.md).
