#!/usr/bin/env bash
# Compare Ollama generation speed on GPU (all layers offloaded) vs CPU only.
# Usage: ./bench-ollama.sh [model ...]
# Env:   OLLAMA_HOST (default 127.0.0.1:3006), RUNS (default 5),
#        NUM_PREDICT (default 256), NUM_CTX (default 2048), PROMPT
set -euo pipefail

for tool in curl jq awk; do
  command -v "$tool" >/dev/null || { echo "missing tool: $tool (try: nix-shell -p curl jq)" >&2; exit 1; }
done

HOST="${OLLAMA_HOST:-127.0.0.1:3006}"
HOST="${HOST#http://}"
URL="http://$HOST"
RUNS="${RUNS:-5}"
NUM_PREDICT="${NUM_PREDICT:-256}"
NUM_CTX="${NUM_CTX:-2048}"
PROMPT="${PROMPT:-Write a long story about a lighthouse keeper.}"

if [ "$#" -eq 0 ]; then
  MODELS=("smollm2:135m")
else
  MODELS=("$@")
fi

curl -sf "$URL/api/version" >/dev/null || { echo "no Ollama server answering at $URL" >&2; exit 1; }

unload() {
  jq -n --arg m "$1" '{model: $m, keep_alive: 0}' \
    | curl -s "$URL/api/generate" -d @- >/dev/null
  sleep 2
}

# $1 model, $2 num_gpu, $3 num_predict
generate() {
  jq -n --arg m "$1" --arg p "$PROMPT" \
        --argjson gpu "$2" --argjson n "$3" --argjson ctx "$NUM_CTX" '
    {model: $m, prompt: $p, stream: false,
     options: {num_predict: $n, num_ctx: $ctx, temperature: 0, seed: 1, num_gpu: $gpu}}' \
    | curl -s "$URL/api/generate" -d @-
}

placement() {
  curl -s "$URL/api/ps" | jq -r --arg m "$1" '
    [.models[] | select(.name == $m or .model == $m)][0]
    | if . == null then "not loaded"
      elif .size_vram == 0 then "CPU"
      elif .size_vram == .size then "GPU"
      else "split \((.size_vram / .size * 100) | floor)% GPU" end'
}

median() {
  sort -n | awk '{a[NR]=$1} END {if (NR==0) print "n/a"; else if (NR%2) printf "%.1f", a[(NR+1)/2]; else printf "%.1f", (a[NR/2]+a[NR/2+1])/2}'
}

run_mode() {
  local model="$1" label="$2" num_gpu="$3"
  local gen_rates="" prompt_rates="" out placed

  unload "$model"
  generate "$model" "$num_gpu" 16 >/dev/null     # warm-up, discarded
  placed="$(placement "$model")"

  for _ in $(seq "$RUNS"); do
    out="$(generate "$model" "$num_gpu" "$NUM_PREDICT")"
    gen_rates+="$(jq -r 'if .eval_duration > 0 then .eval_count / .eval_duration * 1e9 else empty end' <<<"$out")"$'\n'
    prompt_rates+="$(jq -r 'if .prompt_eval_duration > 0 then .prompt_eval_count / .prompt_eval_duration * 1e9 else empty end' <<<"$out")"$'\n'
  done

  printf '%-10s %-18s %12s %14s\n' "$label" "$placed" \
    "$(printf '%s' "$gen_rates" | grep -v '^$' | median)" \
    "$(printf '%s' "$prompt_rates" | grep -v '^$' | median)"
}

echo "server: $URL | runs: $RUNS | num_predict: $NUM_PREDICT | num_ctx: $NUM_CTX"
for model in "${MODELS[@]}"; do
  echo
  echo "model: $model"
  printf '%-10s %-18s %12s %14s\n' "mode" "placement" "gen tok/s" "prompt tok/s"
  run_mode "$model" "GPU" 999
  run_mode "$model" "CPU" 0
  unload "$model"
done
