# den — how it works (working notes for agents)

Reference checkout: `denful/den/` (git-ignored). Docs source lives at
`denful/den/docs/src/content/docs/`; the rendered site is https://den.denful.dev.
`denful/den/AGENTS.md` is den's own agent briefing and is worth reading in full
before touching den semantics.

Versions in use: `den` @ `12b2146`, `flake-aspects` @ `e5bbf7b`, `import-tree` @
`eb1b52e` (see `flake.lock`).

---

## 1. The pipeline in one paragraph

`flake.nix` calls `flake-parts` and hands it `inputs.import-tree ./modules`.
Every `.nix` file under `modules/` is a module of that flake-parts evaluation.
`modules/den.nix` imports `inputs.den.flakeModule`, which adds the `den.*`
options and materialises `nixosConfigurations` / `homeConfigurations` /
`denful` outputs from the declared **entities**. For each entity den walks its
**aspect** through an effect pipeline (resolve → compile → gate → classify →
emit-classes → nested/children → policies). Anything under a key matching a
registered **class** (`nixos`, `homeManager`, `user`, ...) becomes a module for
that class in that entity's scope; everything else is either structural, a
nested aspect, or noise.

## 2. The four nouns

| Noun | Meaning | Where it lives |
|---|---|---|
| **Entity** | Something that exists: a host, a user on a host, a standalone home. | `den.hosts.<system>.<name>`, `den.hosts.<system>.<name>.users.<user>`, `den.homes.<system>.<name>` |
| **Aspect** | What a feature does, across any number of classes. Composable. | `den.aspects.<name>` |
| **Policy** | A rule that emits typed effects (include/route/provide/spawn/resolve) when its argument signature is satisfied. | `den.policies.*`, or `policies` key on an aspect |
| **Quirk** | Structured **data** aspects share (ports, lists, records) instead of modules. | `den.quirks.<name>` + a pipe |

Remember: an aspect is *behaviour*, an entity is *identity*. Aspects should not
know which host or user they are attached to unless they explicitly take
`{ host }` / `{ user }` as arguments.

## 3. Aspect anatomy

```nix
den.aspects.foo = {
  # 1. owned config — one module per Nix class
  nixos       = { pkgs, ... }: { ... };   # or a plain attrset
  homeManager = { ... };
  user        = { extraGroups = [ "wheel" ]; };  # routes to users.users.<name>

  # 2. dependencies
  includes = [ den.aspects.bar <shell/fish> (<den/user-shell> "fish") ];

  # 3. structural keys
  excludes    = [ ... ];      # subtree exclusion
  provides / _= { ... };      # LEGACY sub-aspect namespace + cross-entity keys
  policies    = { ... };      # named aspect-local policies
  meta        = { ... };      # aspect-chain, handleWith (constraints), guard
  name / description = "...";
};
```

Structural keys recognised by den: `includes`, `excludes`, `provides`/`_`,
`policies`, `meta`, `classes`, `name`, `description` (+ anything in
`den.reservedKeys`).

**Anything that is not a class key and not structural becomes a nested aspect
child — and nested children are NOT walked unless included.** This is the single
most common source of "my config is not applied".

## 4. Entities and scopes (the rules that bite)

```nix
den.hosts.x86_64-linux.argos.users.talarys = { };  # host + user on it
den.homes.x86_64-linux.talarys = { };              # standalone HM config
```

Resolution happens in **scopes**: one for the host (`host=argos`), one per user
(`host=argos,user=talarys`), one per standalone home.

| Written on | Class | Lands in |
|---|---|---|
| host aspect | `nixos`, `darwin`, `os` | the host's OS config |
| host aspect | `homeManager`, `user` | **nowhere** (dropped, no warning) |
| user aspect | `homeManager` | that user's home |
| user aspect | `user` | `users.users.<name>` on the host |
| user aspect | `nixos`, `os` | host OS **only** because of den's transition default (removed 2027-01-01) |
| `den.default` | `nixos` | every host, once |
| `den.default` | `homeManager` | every user's home |
| `den.schema.host.includes` | `nixos` | every host |
| `den.schema.user.includes` | `homeManager` | every user |

Host → user delivery needs an explicit edge: `provides.to-users`,
`provides.<user>`, or the `host-aspects` battery (this repo includes
`<den/host-aspects>` in `den.default`, i.e. every user opts into the host's
home config). User → host delivery needs `mutual-provider` (for
`provides.to-hosts`) or `user-aspects` (for the user's raw `nixos` content).

Full table with measurements:
`denful/den/docs/src/content/docs/explanation/where-config-lands.mdx`.

## 5. Parametric aspects

A function is distinguished from a module by its argument names:

- `{ pkgs, lib, config, ... }:` → **static module**, emitted once.
- `{ host, user, home, ... }:` → **parametric aspect**, re-resolved per scope.
  Requesting `user` makes it run once per user; requesting `home` only binds at
  standalone-home scope.
- `{ class, aspect-chain }: { ... }` → **static leaf**, gets the class being
  resolved.

Parametric aspects are how this repo does per-host variation
(`modules/desktop/catppuccin.nix` takes `{ flavor, accent }`).

`host.hasAspect <aspect>` is safe **inside a class module body**, never inside
`includes` (infinite recursion). For "only if X is present" in `includes`, use
`meta.handleWith` + `den.lib.aspects.fx.constraints`.

## 6. Nested aspects, `provides`, `_`, and namespaces

Three ways to group, do not confuse them:

1. **Direct nested aspect** (current idiom):
   ```nix
   den.aspects.shell.fish = { homeManager = ...; };   # child name = "fish"
   den.aspects.talarys.includes = [ den.aspects.shell.fish ];
   ```
2. **`provides` / `_`** (legacy, still supported): `den.aspects.shell._.fish`.
   `<aspect>/<child>` resolves through it. Den's docs call this "Legacy
   sub-aspect namespace" and prefer direct nesting. It is **still required** for
   the cross-entity keys `to-users`, `to-hosts`, and `<host>` on a user aspect —
   that is the only place this repo uses it (`provides.to-users`,
   `provides.to-hosts`). Grouping uses namespaces.
3. **Namespace** (used by this repo, and the way to reuse/publish aspects):
   ```nix
   imports = [ (inputs.den.namespace "shell" false) ];  # false = don't export
   ```
   then declare `shell.fish = { ... };` (the module arg) and reference
   `<shell/fish>` or `den.ful.shell.fish`. Registered namespaces here: `apps`,
   `containers`, `desktop`, `shell`, `system` (see `modules/den.nix`).

<Aside type="danger">
Never mix `den.aspects.<name>` and a namespace called `<name>`. Angle brackets
check `den.aspects.<head>` **before** `den.ful.<head>`, so a single leftover
`den.aspects.desktop.foo` makes every `<desktop/...>` fail with
"Aspect 'desktop' has no key ...".
</Aside>

## 7. Angle brackets `<a/b>`

Enabled by `_module.args.__findFile = den.lib.__findFile;` (done globally in
`modules/den.nix`), but **each file must also list `__findFile` in its argument
set** to bring it into lexical scope.

Resolution order: `<den/battery>` → `den.batteries.battery`; `<den.x.y>` →
`den.x.y`; `<aspect/child>` → `den.aspects.aspect.child` (falling back to
`provides.child`); `<namespace/aspect>` → `den.ful.namespace.aspect`.

Because `den.aspects.<head>` is checked first, an aspect named like a namespace
shadows it (see the warning in section 6).

## 8. Schema, defaults, batteries

- `den.schema.{conf,host,user,home,aspect}` — per-kind metadata modules plus
  control keys (`includes`, `excludes`, `inherits`, `isEntity`, `isStrict`).
  e.g. `den.schema.user.classes = lib.mkDefault [ "homeManager" ]` is what
  enables home-manager for every user. `den.schema.host.home-manager.enable` is
  a **real** option (`host.<optionPath>.enable`, default derived from the users'
  classes) that the home-manager battery reads.

  Shape rule: a schema entry is one module **or** a set of sub-attributes
  (`.includes`, `.home-manager.enable`, `.classes`, …). Assigning
  `den.schema.host = <module>` together with `den.schema.host.includes = …`
  fails with "attribute `den.schema.host` already defined".

  Defaults that should remain overridable need `lib.mkDefault`: a plain list
  definition **concatenates** with another one, so without it a user cannot
  choose a different `classes` list.
- `den.systems` — flake-parts `systems`, derived from `den.hosts` + `den.homes`
  (`den/modules/outputs/systems.nix`). Don't set it manually unless you add a
  system with no entity.
- Freeform host/user attributes are legal and reachable from aspects
  (`den.hosts.x86_64-linux.argos.session = "plasma"` → `host.session`). This is
  the lightweight alternative to a schema option when one policy consumes it.- `den.default` — an aspect walked in *both* host and user scopes. Good place for
  universal config; dangerous for parametric functions (they run once per scope).
- `den.batteries.*` (aliases `den.provides.*`, `den._.*`) — shipped aspects:
  `primary-user`, `define-user`, `hostname`, `host-aspects`, `user-aspects`,
  `mutual-provider`, `user-shell`, `unfree`, `insecure`, `forward`,
  `import-tree`, ... Reference: `denful/den/docs/src/content/docs/reference/batteries.mdx`.
- `inputs.den.flakeModule` must be imported exactly once (`modules/den.nix`).

New `.nix` files are invisible to `nix eval`/`nix build` until `git add`ed —
the flake source only includes git-tracked paths. `import-tree` then picks them
up automatically.

## 9. Migration state (important for 2027)

den keeps two transition defaults on every host until a den release planned for
2027-01-01: `user-aspects` and `mutual-provider`. With them, a user aspect's
`nixos`/`os` content still reaches the host (old behaviour) and den warns once
listing exactly what only arrives that way.

Adopt the end state explicitly (this repo does):

```nix
den.schema.host.includes = [
  den.batteries.user-aspects
  den.batteries.mutual-provider
];
```
…or, if user-level OS content is unintended, move it to the host aspect and set
`den.migrations.user-host-content.acknowledged = true;`.
See `denful/den/docs/src/content/docs/explanation/crossing-scopes.mdx`.

## 10. Choosing a mechanism (den's own table, condensed)

| Goal | Mechanism |
|---|---|
| bundle aspects | `includes` |
| configure one module system | class key |
| vary by host/user | class module taking `{ host }` / parametric aspect |
| apply to every entity | `den.schema.<kind>.includes` / `den.default` |
| apply by rule | policy returning `policy.include` |
| include only if something else is present | `policy.when` / `meta.handleWith` |
| entity → users / users → entity | `provides.to-users` / `provides.to-hosts` |
| per-host tunables of a reusable aspect | `settings` pattern (reserved key) |
| share data, not modules | quirk (+ pipes to cross scopes) |

This repo uses two mechanisms beyond `includes`: a `firewall` **quirk**
(`den.quirks.firewall` in `modules/system/networking.nix`; producers write
`firewall.ports = [ … ]`) and a **policy** for the desktop session
(`den.policies.session` in `modules/desktop/session.nix`).

## 11. Tooling in this repo

- Format: `just fmt` → treefmt (`nixfmt` + `statix`). If formatting seems to do
  nothing, the treefmt cache is stale: `nix run .#formatter.x86_64-linux -- --no-cache`.
- Check: `just check` → `nix flake check` (builds `checks.home-talarys`,
  `checks.argos-wiring`, and the treefmt check).
- Rebuild: `just rebuild` (`nh os switch .`).
- Do not add `deadnix` / `nixf-diagnose` here: both report a lambda arg used only
  in an attribute path (`{ system, ... }: { system.x = 1; }`) as unused, which is
  every aspect in this repo. den disables both in its own `checkmate` formatter,
  and `checkmate` treefmt also runs with `on-unmatched = fatal`, so it trips on
  `justfile` and the vendored mpv data.

## 12. den repo map (for reading source)

```
denful/den/
  nix/default.nix          entry; exports flakeModule, lib, templates
  nix/flakeModule.nix      flake-parts module
  nix/lib/aspects/         aspect engine (types, resolve, fx pipeline + handlers)
  nix/lib/entities/        host.nix, home.nix entity kinds
  nix/lib/home-env.nix     home-manager/hjem/maid integration
  modules/options.nix      den.hosts / den.homes / den.schema / den.classes
  modules/aspects/batteries/   den.batteries.*
  templates/               runnable examples (templates/example is the closest
                           reference to this repo's style)
  templates/ci/modules/    the test suite; denTest fixtures igloo/tux
```
