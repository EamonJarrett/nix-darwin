# Nix-Darwin Setup

System configuration managed by nix-darwin with flakes.

## Layout

```
~/.config/nix-darwin/
  flake.nix           # Entry point: inputs, overlays, system config
  flake.lock          # Pinned dependency versions
  hosts/eamon.nix     # Machine-specific: hostname, platform, nix settings
  modules/
    packages.nix      # CLI tools (nix-managed)
    homebrew.nix      # GUI apps (brew cask) + taps
    shell.nix         # Zsh config, shell init, direnv, env vars, PATH
  pkgs/               # Custom derivations for packages not in nixpkgs
    skhd-zig.nix
    taws.nix
    bv.nix
    bd.nix
```

## Common Operations

### Apply config changes

After editing any `.nix` file:

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

Open a new shell to pick up changes to `interactiveShellInit`.

### Add a CLI tool

Edit `modules/packages.nix`, add the package name to `environment.systemPackages`, rebuild.

```bash
# Search for a package
nix search nixpkgs <name>
```

### Add a GUI app

Edit `modules/homebrew.nix`, add to `casks`, rebuild.

### Add a custom package not in nixpkgs

Create a derivation in `pkgs/<name>.nix`, add it to the overlay in `flake.nix`, reference it by name in `packages.nix`.

### Update all packages

```bash
cd ~/.config/nix-darwin
nix flake update        # updates flake.lock to latest nixpkgs
darwin-rebuild switch --flake .
```

### Rollback

```bash
darwin-rebuild switch --rollback
```

### Garbage collect old generations

```bash
nix-collect-garbage -d       # delete all old generations
nix store gc                 # reclaim disk space
```

## Dev Environments (direnv + devShells)

Language-specific toolchains (Go, Python, etc.) are NOT installed globally. Instead, each project defines its own `flake.nix` with a `devShell`, and `direnv` activates it automatically when you `cd` into the project.

### How it works

1. `programs.direnv.enable = true` in `shell.nix` installs direnv, hooks it into zsh, and enables nix-direnv (cached flake evaluation)
2. A project has a `flake.nix` defining `devShells.default` and a `.envrc` containing `use flake`
3. On `cd` into the project, direnv evaluates the flake and adds its packages to your PATH
4. On `cd` out, the environment is deactivated
5. nix-direnv caches the evaluation -- subsequent activations are instant

### Add a devShell to a project

1. Create `flake.nix`:

```nix
{
  description = "my-project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_25
            python312
            # add more packages here
          ];
        };
      });
    };
}
```

2. Create `.envrc`:

```
use flake
```

3. Track both files in git (nix flakes require tracked files):

```bash
git add flake.nix .envrc
```

4. Add `.direnv/` to `.gitignore` (nix-direnv cache).

5. Allow direnv:

```bash
direnv allow
```

First activation downloads/builds dependencies (one-time cost). After that, it's cached.

### Find available package names

```bash
# Search by name
nix search nixpkgs python
nix search nixpkgs go_1

# Check if a specific package exists
nix eval --raw 'nixpkgs#go_1_25.version'
```

### Force re-evaluation of a devShell

```bash
direnv reload
```

### Enter a devShell without direnv

```bash
nix develop            # uses ./flake.nix in current directory
nix develop .#python36 # use a named devShell
```

## Architecture Decisions

### What goes where

| Thing | Where | Why |
|---|---|---|
| CLI tools | `packages.nix` (nix) | Reproducible, pinned, no brew dependency |
| GUI apps | `homebrew.nix` (cask) | Nix cask support is poor; brew handles updates/signing |
| Language toolchains | Per-project `flake.nix` | Different projects need different versions |
| Shell config | `shell.nix` | Zsh plugins, tool init hooks, aliases, env vars |
| Secrets | `~/.config/zsh/secrets.zsh` | NOT in nix store (world-readable) |

### Overlays

The `customPackages` overlay in `flake.nix` serves two purposes:
- Custom derivations (`pkgs/*.nix`) for tools not in nixpkgs
- Workarounds for broken nixpkgs builds (e.g., direnv CGO_ENABLED fix)

### Homebrew cleanup

`homebrew.onActivation.cleanup` is set to `"none"` -- brew won't uninstall packages not declared in `homebrew.nix`. Change to `"uninstall"` once the migration is fully settled.

## Troubleshooting

### `darwin-rebuild switch` fails with a build error

Check if the package is broken in nixpkgs-unstable. Options:
- Override it in the `customPackages` overlay in `flake.nix`
- Pin nixpkgs to an older rev where it builds
- Use `nix log <drv-path>` to read the full build log (the error output tells you the drv path)

### direnv says "is taking a while to execute"

First activation of a new/changed `flake.nix` evaluates the full derivation. This is a one-time cost. Subsequent activations use the nix-direnv cache.

### "Path 'flake.nix' is not tracked by Git"

Nix flakes only see git-tracked files. Run:

```bash
git add flake.nix .envrc
```

Files don't need to be committed -- just staged.

### Shell startup is slow

Profile it:

```bash
# Measure total interactive startup
cd /tmp && time zsh -ic 'exit'

# Timestamp each sourced file
cd /tmp && PS4='+%D{%s%.} %N:%i> ' zsh -xic 'exit' 2>/tmp/zsh-trace.log

# Summarize time per source file
python3 -c "
import re
from collections import defaultdict
lines = open('/tmp/zsh-trace.log').readlines()
entries = []
for l in lines:
    m = re.match(r'\+(\d+)\s+(\S+)', l)
    if m: entries.append((int(m.group(1)), m.group(2)))
totals = defaultdict(int)
for i, (t, f) in enumerate(entries):
    nt = entries[i+1][0] if i+1 < len(entries) else t
    totals[f] += nt - t
for f, dt in sorted(totals.items(), key=lambda x: -x[1]):
    if dt >= 5: print(f'{dt:5d}ms  {f}')
print(f'\ntotal: {entries[-1][0] - entries[0][0]}ms')
"
```

### Checking what's installed

```bash
# Nix-managed packages
darwin-rebuild --list-generations
nix profile list

# Brew-managed
brew list --cask
brew list --formula    # should be mostly empty post-migration
```
