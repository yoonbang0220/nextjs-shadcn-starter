#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Approximate cost (Sonnet pricing per 1M tokens)
# Input: $3.00, Output: $15.00, Cache write: $3.75, Cache read: $0.30
cost=""
if [ -n "$input_tokens" ] && [ "$input_tokens" != "null" ] && [ "$input_tokens" != "0" ]; then
  cost=$(echo "$input_tokens $output_tokens $cache_write $cache_read" | awk '{
    inp=$1; out=$2; cw=$3; cr=$4;
    total = (inp * 3.00 + out * 15.00 + cw * 3.75 + cr * 0.30) / 1000000;
    printf "$%.4f", total
  }')
fi

# Build context display
ctx_display=""
if [ -n "$used_pct" ]; then
  ctx_display=$(printf "CTX:%.0f%%" "$used_pct")
fi

# Build output
model_str=$(printf '\033[1m%s\033[0m' "$model")
out="$model_str"

if [ -n "$ctx_display" ]; then
  out="$out $(printf '\033[36m%s\033[0m' "$ctx_display")"
fi

if [ -n "$cost" ]; then
  out="$out $(printf '\033[33m%s\033[0m' "$cost")"
fi

printf "%s" "$out"
