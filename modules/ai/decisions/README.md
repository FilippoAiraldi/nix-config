# Decisions endpoint

Local, GLiDE-style decision endpoint running on `crappy-server`. It is queried with `curl` (or any HTTP client) and answers yes/no, pick-one and rate-on-a-scale questions about a piece of text or structured state.

## Overview

[`fastino/GLiNER2.5-Decide`](https://huggingface.co/fastino/GLiNER2.5-Decide) is served by a FastAPI app (`decisions/`) and wrapped in a NixOS module (`default.nix`).

| Item         | Value                                                              |
| ------------ | ------------------------------------------------------------------ |
| systemd unit | `decisions`                                                        |
| Listens on   | `127.0.0.1:3004` (option `ai.decisionsPort`)                       |
| Proxied at   | `https://decisions.crappy-server.home` (Caddy)                     |
| Health check | `GET /health`, also monitored by Gatus                             |
| State        | `/var/lib/decisions` (project copy, venv, Hugging Face model cache) |

The model is loaded once at startup and stays in memory, so requests do not pay the loading cost.

## Deployment

- **Python:** 3.13 comes from nixpkgs (`torch.jit.script` requires 3.13 or older). uv is told never to download a Python (`UV_PYTHON_DOWNLOADS=never`, `UV_PYTHON_PREFERENCE=only-system`).
- **Dependencies:** installed by [uv](https://docs.astral.sh/uv/) (FastAPI, `gliner2[local]`, CPU-only torch) into a venv in `/var/lib/decisions`. The venv is rebuilt when the Python store path changes.
- **Native libraries:** `nix-ld` lets the native libraries inside the wheels run.
- **First start:** downloads torch and the model, so give it a few minutes (see `journalctl -u decisions -f`).

## API

The API mirrors the closed-source [GLiDE](https://docs.fastino.ai) `POST /v1/systemone` contract, so switching to it later only means changing the URL and adding the API key.

Questions are `noul` (yes/no), `choice` (pick one) or `score` (ordered levels):

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

### Differences from GLiDE

- `usage` and `token_usage` are not returned.
- `model` is the local model id.
- All questions of a request are scored in one pass, so they can influence each other slightly.
- Text containing parentheses is rejected with 422, because the model prompt cannot carry them.

## Development

From `modules/ai/decisions/`:

- `uv run pytest` runs the tests with a stub classifier.
- `uv run uvicorn decisions.api:app` serves locally.

## Known limitations

`uv.lock` is not committed yet: the CPU torch index (`download.pytorch.org`) was unreachable when this was written, so the service resolves on first start. Run `uv lock` in `modules/ai/decisions/` and commit the result to pin versions.
