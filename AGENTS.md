# AGENTS.md

This is a NixOS + home-manager flake built on [den](https://den.denful.dev)
(aspect-oriented Nix). Agent documentation lives in [`agents/`](./agents/):

- [`agents/README.md`](./agents/README.md) — start here: ground rules + how to verify.
- [`agents/REPO.md`](./agents/REPO.md) — layout, entities, aspect inventory, conventions, recipes.
- [`agents/DEN.md`](./agents/DEN.md) — how den works (aspects, classes, scopes, batteries, namespaces).
- [`agents/AUDIT.md`](./agents/AUDIT.md) — bug history, fixes, and the traps behind them.

Non-negotiables:

1. Prove a change with `just check` or `nix eval` on the real option; a missing
   class key (`nixos` / `homeManager` / `user`) makes config silently inert.
2. New `.nix` files must be `git add`ed before nix can see them; deletions too.
3. Aspects are grouped in namespaces (`shell`, `system`, `apps`, `desktop`,
   `containers`) and included as `<namespace/aspect>`. Never define
   `den.aspects.<namespace>.*` next to a namespace of the same name.
4. `nix flake check` does not evaluate `homeConfigurations` — the checks in
   `modules/checks.nix` do.
5. `denful/` is a read-only reference clone (git-ignored). Never edit it.
6. Stage files explicitly; never `git add -A`.
7. Do not commit secrets.
