#!/usr/bin/env bash
# gather-state.sh — discover memory state on local + homie, emit parseable output.
#
# Starts SSH multiplexing (close with: ssh -O exit -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie)
# and initializes git repos on both sides if missing. Idempotent; safe to rerun.
#
# Output is a stream of ===MARKER=== sections:
#   HOSTNAME                           - one line: local hostname
#   LOCAL_DIRS / REMOTE_DIRS           - project IDs, one per line
#   LOCAL_LOG:<pid>  / REMOTE_LOG:<pid>  - `git log --oneline -n 30` for that project
#   LOCAL_FILE:<pid>/<rel> md5=<sum>   - header followed by file content, ended by ===END_FILE===
#   REMOTE_FILE:<pid>/<rel> md5=<sum>  - same, remote side

set -euo pipefail

CTRL_PATH=/tmp/ssh-homie-sync-%r@%h

# Start SSH multiplexing if not already running
if ! ssh -o ControlPath="$CTRL_PATH" -O check homie 2>/dev/null; then
  ssh -o ControlMaster=yes -o ControlPath="$CTRL_PATH" -o ControlPersist=300 -fN homie
fi
SSH=(ssh -o ControlPath="$CTRL_PATH" homie)

HOST=$(hostname)
printf '===HOSTNAME===\n%s\n' "$HOST"

# Init local git repos if missing
for d in ~/.claude/projects/*/memory/; do
  [ -d "$d" ] || continue
  if [ ! -d "$d/.git" ]; then
    git -C "$d" init -q -b main
    git -C "$d" add -A
    git -C "$d" -c "user.email=claude@$HOST" -c user.name=Claude \
      commit -q -m "chore: initialize memory repo" 2>/dev/null || true
  fi
done

# Init remote git repos if missing
"${SSH[@]}" '
  for d in ~/.claude/projects/*/memory/; do
    [ -d "$d" ] || continue
    if [ ! -d "$d/.git" ]; then
      git -C "$d" init -q -b main
      git -C "$d" add -A
      git -C "$d" -c user.email=claude@homie -c user.name=Claude \
        commit -q -m "chore: initialize memory repo" 2>/dev/null || true
    fi
  done'

# Discover project IDs
printf '===LOCAL_DIRS===\n'
for d in ~/.claude/projects/*/memory/; do
  [ -d "$d" ] && basename "$(dirname "$d")"
done

printf '===REMOTE_DIRS===\n'
"${SSH[@]}" '
  for d in ~/.claude/projects/*/memory/; do
    [ -d "$d" ] && basename "$(dirname "$d")"
  done'

# Git log per project (local)
for d in ~/.claude/projects/*/memory/; do
  [ -d "$d/.git" ] || continue
  pid=$(basename "$(dirname "$d")")
  printf '===LOCAL_LOG:%s===\n' "$pid"
  git -C "$d" log --oneline -n 30 2>/dev/null || true
done

# Git log per project (remote)
"${SSH[@]}" '
  for d in ~/.claude/projects/*/memory/; do
    [ -d "$d/.git" ] || continue
    pid=$(basename "$(dirname "$d")")
    printf "===REMOTE_LOG:%s===\n" "$pid"
    git -C "$d" log --oneline -n 30 2>/dev/null || true
  done'

# File contents + md5 (local)
shopt -s nullglob
for d in ~/.claude/projects/*/memory/; do
  pid=$(basename "$(dirname "$d")")
  for f in "$d"*.md "$d"hosts/*/*.md; do
    [ "$(basename "$f")" = "MEMORY.md" ] && continue
    rel=${f#$d}
    sum=$(md5sum "$f" | cut -d' ' -f1)
    printf '===LOCAL_FILE:%s/%s md5=%s===\n' "$pid" "$rel" "$sum"
    cat "$f"
    printf '\n===END_FILE===\n'
  done
done

# File contents + md5 (remote)
"${SSH[@]}" '
  shopt -s nullglob
  for d in ~/.claude/projects/*/memory/; do
    pid=$(basename "$(dirname "$d")")
    for f in "$d"*.md "$d"hosts/*/*.md; do
      [ "$(basename "$f")" = "MEMORY.md" ] && continue
      rel=${f#$d}
      sum=$(md5sum "$f" | cut -d" " -f1)
      printf "===REMOTE_FILE:%s/%s md5=%s===\n" "$pid" "$rel" "$sum"
      cat "$f"
      printf "\n===END_FILE===\n"
    done
  done'
