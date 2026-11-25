# Agent docs — index

Start here for any agent (or human) touching this repository.

| File | Read it when |
|---|---|
| [`REPO.md`](./REPO.md) | You need the layout, hosts/users/aspect inventory, conventions, recipes ("add a host", "add a package"), and the list of optional aspects. |
| [`DEN.md`](./DEN.md) | You need the den framework mental model: entities, aspects, classes, includes/provides, scopes, batteries, angle brackets, namespaces, policies, quirks, and the mistakes people make with them. |
| [`AUDIT.md`](./AUDIT.md) | You need the history of bugs found in this config, their fixes, and the traps behind them. |

`denful/` (git-ignored) holds read-only checkouts of `den`, `flake-aspects`, and
`import-tree` used as reference material. When den's behaviour is unclear, read
`denful/den/docs/src/content/docs/` — it ships the full docs site in-tree.
`denful/den/AGENTS.md` is den's own agent briefing.

## Ground rules for agents

1. **Never trust the aspect tree by eye.** A missing class key
   (`nixos` / `homeManager` / `user`) silently makes config inert. Prove a change
   with `nix eval`/`nix build` on a real option or a check.
2. **New files must be staged.** The flake source is the git tree; `nix` cannot
   see an untracked module. Deletions need `git add`/`git rm` too.
3. **Edit files under `modules/` (and `agents/`, `README.md`).** `flake.nix`,
   `justfile`, `disko/` are infrastructure; changes there need the user's
   sign-off.
4. **One aspect per file**, grouped in namespaces (`shell`, `system`, `apps`,
   `desktop`, `containers`). Do not define `den.aspects.<namespace>.*` next to a
   namespace of the same name — it shadows `<namespace/...>` resolution.
5. **No duplicated ownership.** A package or setting lives in exactly one aspect
   (see `REPO.md` for who owns what).
6. **Never commit secrets.** The account password hash is currently an
   `initialHashedPassword`; see `AUDIT.md` F19.
7. **Do not `git add -A`.** Stage explicit paths.

## Verify

```sh
# the regression net: standalone home build + wiring probes + treefmt
just check

# a single option
nix eval --json .#nixosConfigurations.argos.config.time.timeZone
nix eval --json .#nixosConfigurations.argos.config.home-manager.users.talarys.programs.git.enable

# warnings / failed assertions
nix eval .#nixosConfigurations.argos.config.warnings
nix eval .#nixosConfigurations.argos.config.assertions \
  --apply 'as: map (a: a.message) (builtins.filter (a: !a.assertion) as)'

# formatting (add --no-cache if treefmt appears to skip files)
just fmt

# apply for real (user's machine, needs sudo)
just rebuild
```

`nix flake check` alone does **not** evaluate `homeConfigurations` (Nix treats
the output as unknown), which is how a broken standalone home went unnoticed.
`modules/checks.nix` closes that gap; keep it in sync when you fix a
"silently dropped config" bug.
