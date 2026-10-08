# NixOS Configuration

A single Nix flake covering my NixOS and WSL hosts.

The repo is forked from and follows [Alex Nabokikh's config](https://github.com/AlexNabokikh/nix-config).

## Layout

```text
.
├── flake.nix            # Inputs; imports everything in modules/
├── justfile             # Common rebuild, update, and check commands
└── modules/
    ├── ai/              # AI features (a Nix module plus the code it runs)
    ├── configurations/  # Instantiates hosts and generates system checks
    ├── hosts/           # Hosts definitions
    ├── nixos/           # NixOS-only system features
    ├── profile/         # Identity and shared appearance settings
    ├── programs/        # Program-oriented modules, mostly for Home Manager
    ├── base.nix         # Composes features into server and WSL hosts
    ├── flake-parts.nix  # Flake-parts module integrations
    ├── formatter.nix    # Repository-wide Nix formatter
    ├── systems.nix      # Systems supported by per-system outputs
    └── *.nix            # Repository-level features for one or more module classes
```

## Conventions

- Files under `modules/nixos/`, or `modules/programs/` typically declare modules of a single class (`nixos.*`, `homeManager.*`). Vertical program features may declare modules for more than one class.
- `modules/base.nix` collects default workstation features into `nixos.base` and `homeManager.base`. Opt-in features are composed by their owning host or parent feature instead.
- `modules/ai/<feature>/` holds vertical features that ship their own non-Nix code (e.g. a Python service), documented in a README next to the code (see [decisions](modules/ai/decisions/README.md), [chat](modules/ai/chat/README.md)). Only its `.nix` files are picked up by `import-tree`.
- Files and directories prefixed with `_` (for example `_hardware.nix`) are skipped by `import-tree` and imported explicitly where needed.

