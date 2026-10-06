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
- `modules/ai/<feature>/` holds vertical features that ship their own non-Nix code (e.g. a Python service). Only its `.nix` files are picked up by `import-tree`.
- Files and directories prefixed with `_` (for example `_hardware.nix`) are skipped by `import-tree` and imported explicitly where needed.


## Decisions endpoint

`modules/ai/decisions/` runs [`fastino/GLiNER2.5-Decide`](https://huggingface.co/fastino/GLiNER2.5-Decide) as a FastAPI service on `crappy-server` (systemd unit `decisions`, `127.0.0.1:3004`, proxied by Caddy at `https://decisions.crappy-server.home`). The model is loaded once at startup and stays in memory. Python 3.13 and the dependencies are installed by [uv](https://docs.astral.sh/uv/) (CPU-only torch) into `/var/lib/decisions`; `nix-ld` lets those binaries run. The first start downloads everything, so give it a few minutes (see `journalctl -u decisions -f`).

The API mirrors the closed-source [GLiDE](https://docs.fastino.ai) `POST /v1/systemone` contract, so switching to it later only means changing the URL and adding the API key. Questions are `noul` (yes/no), `choice` (pick one) or `score` (ordered levels):

```bash
curl -s https://decisions.crappy-server.home/v1/systemone -k \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Refund request: the receipt is attached, the purchase was 10 days ago, and refunds are allowed within 30 days.",
    "questions": {
      "refund_allowed": {
        "type": "noul",
        "instructions": "Does this request qualify for a refund?",
        "criteria": { "true": "Qualifies", "false": "Does not qualify" }
      },
      "department": {
        "type": "choice",
        "criteria": { "billing": "Payments", "returns": "Returns and refunds", "shipping": "Delivery" }
      },
      "urgency": { "type": "score", "criteria": ["low urgency", "medium urgency", "high urgency"] }
    }
  }'
```

`GET /health` reports readiness. Differences from GLiDE: `usage`/`token_usage` are not returned, `model` is the local model id, all questions of a request are scored in one pass (so they can influence each other slightly), and text containing parentheses is rejected with 422 because the model prompt cannot carry them.

Development (from `modules/ai/decisions/`): `uv run pytest` runs the tests with a stub classifier; `uv run uvicorn decisions.api:app` serves locally.

`uv.lock` is not committed yet: the CPU torch index (`download.pytorch.org`) was unreachable when this was written, so the service resolves on first start. Run `uv lock` in `modules/ai/decisions/` and commit the result to pin versions.
