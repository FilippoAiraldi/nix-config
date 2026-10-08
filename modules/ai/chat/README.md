# Chat endpoint

Local LLM chat running on `crappy-server` with [Ollama](https://ollama.com), CPU only. It is used from the terminal (`ai-chat`) or queried with `curl` (or any HTTP client).

## Overview

| Item         | Value                                                                    |
| ------------ | ------------------------------------------------------------------------ |
| systemd unit | `ollama` (`services.ollama`)                                              |
| Listens on   | `127.0.0.1:3006` (option `ai-chatPort`)                                  |
| Proxied at   | `https://ai-chat.crappy-server.home` (Caddy)                             |
| Health check | `GET /` returns `Ollama is running`                                      |
| State        | `/var/lib/ollama` (Ollama models)                                        |

The model is `smollm2:135m` by default, a tiny model chosen to make debugging easier. Override it with the `AI_CHAT_MODEL` environment variable (any Ollama model id).

## Deployment

- **CPU only:** uses `pkgs.ollama-cpu`, as no GPU is available.
- **Always on:** runs as the NixOS `services.ollama` module, which does not use much RAM when idle.
- **Idle models:** `OLLAMA_KEEP_ALIVE=5m` unloads a model from RAM after 5 minutes without requests.
- **CPU library:** `OLLAMA_LLM_LIBRARY=cpu_avx2` forces the AVX2 CPU backend.
- **Models:** the default model is pulled at startup (`loadModels`); `ai-chat` pulls other models on demand (see `journalctl -u ollama -f`).

## Usage

Chat in the terminal:

```bash
ai-chat
AI_CHAT_MODEL=qwen2.5:0.5b ai-chat
```

## API

Check that the server is up:

```bash
curl -k https://ai-chat.crappy-server.home/
```

Query the model:

```bash
curl -k https://ai-chat.crappy-server.home/api/chat \
  -d '{
    "model": "smollm2:135m",
    "stream": false,
    "messages": [{ "role": "user", "content": "Why is the sky blue?" }]
  }'
```

The model must already be pulled (run `ai-chat` once, or `curl -k https://ai-chat.crappy-server.home/api/pull -d '{"model": "smollm2:135m"}'`). See the [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md) for other endpoints.
