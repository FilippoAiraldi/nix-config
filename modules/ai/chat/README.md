# Chat endpoint

Local LLM chat running on `crappy-server` with [Ollama](https://ollama.com), CPU only. It is used from the terminal (`ai-chat`) or queried with `curl` (or any HTTP client).

## Overview

| Item         | Value                                                                    |
| ------------ | ------------------------------------------------------------------------ |
| systemd unit | `ai-chat` (backend), `ai-chat-proxy` (socket-activated proxy)            |
| Listens on   | `127.0.0.1:3006` (option `ai-chatPort`); backend on `3007` (`ai-chatBackendPort`) |
| Proxied at   | `https://ai-chat.crappy-server.home` (Caddy)                             |
| Health check | `GET /` returns `Ollama is running`                                      |
| State        | `/var/lib/ai/chat` (Ollama models)                                       |

The model is `smollm2:135m` by default, a tiny model chosen to make debugging easier. Override it with the `AI_CHAT_MODEL` environment variable (any Ollama model id).

## Deployment

- **CPU only:** uses `pkgs.ollama-cpu`, as no GPU is available.
- **On demand:** a systemd socket starts the proxy (and thus Ollama) on the first request. The proxy exits after 15 minutes of idleness, which also stops Ollama (`StopWhenUnneeded`).
- **First use:** `ai-chat` pulls the model if not already stored, so give it a moment (see `journalctl -u ai-chat -f`).

## Usage

Chat in the terminal (opens the Ollama REPL):

```bash
ai-chat
AI_CHAT_MODEL=qwen2.5:0.5b ai-chat
```

## API

Check that the server is up (this also wakes it):

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
