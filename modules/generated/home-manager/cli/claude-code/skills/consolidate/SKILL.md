---
description: Distill lessons from the current session into CLAUDE.md, skills, and memory files so future runs have them upfront
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(ls:*), Bash(readlink:*), Bash(test:*), Bash(realpath:*), AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/consolidate/SKILL.md -->

## Your task

Reflect on this conversation and upstream what you learned into instruction files that would have made your work easier if present at the start: CLAUDE.md, SKILL.md, memory files. Edit in place; prefer shortening existing lines to adding new ones. Ask the user per proposal.

### Step 1: Extract lessons

Scan the conversation for moments that cost time or turns:

- **Corrections** — user said "no", "don't", "actually X", "stop doing Y".
- **Surprises** — a convention, path, constraint, or tool behavior you discovered mid-task.
- **Retries** — a command/tool call you'd have gotten right first try if you'd known X.
- **Validated judgment** — user approved an unusual choice without pushback; worth recording so future-you doesn't second-guess.

For each, write one sentence: "If I had known ___, I would have ___." Discard lessons that are ephemeral task state, derivable from reading the repo, or already covered.

### Step 2: Pick the target file

Match each lesson to the narrowest file that loads it in the right context:

- **Project CLAUDE.md** (`./CLAUDE.md`) — conventions every session in this repo needs.
- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) — cross-project preferences and workflows.
- **Skill** (`~/.claude/skills/<name>/SKILL.md` or plugin skill) — folds into a task already covered by a skill.
- **Memory** (`~/.claude/projects/<id>/memory/*.md`) — facts, state, references per the auto-memory rules in global CLAUDE.md. New memory still requires a `MEMORY.md` index line.

If a lesson fits multiple, pick the most specific one. Never duplicate across files.

### Step 3: Detect Nix-managed sources

Before editing any file under `~/.claude/` or a system path, check if it's a symlink into the Nix store:

```bash
readlink ~/.claude/CLAUDE.md
readlink ~/.claude/skills/<name>/SKILL.md
```

If it resolves into `/nix/store/...`, the deployed file is read-only — edit the source in `/etc/nixos`. Common sources:

- `~/.claude/CLAUDE.md` → `/etc/nixos/modules/generated/home-manager/cli/claude-code/CLAUDE.md`
- `~/.claude/skills/<name>/SKILL.md` → `/etc/nixos/modules/generated/home-manager/cli/claude-code/skills/<name>/SKILL.md`
- `~/.claude/settings.json` → defined in `/etc/nixos/modules/generated/home-manager/cli/claude-code/default.nix`

If the source isn't obvious, grep a unique string from the deployed file under `/etc/nixos`. Memory files under `~/.claude/projects/*/memory/` are **not** Nix-managed — edit in place.

Nix-managed changes only take effect after a rebuild. Don't run it yourself — tell the user at the end.

### Step 4: Draft each edit

Smallest possible change per lesson:

- **Edit an existing line** over adding a new one. Tighten wording instead of appending a sibling rule.
- **Delete** when a lesson obsoletes existing guidance — don't leave both.
- **One line, imperative** for CLAUDE.md rules. No preamble, no examples unless the rule is non-obvious.
- **Skill edits** go inside the existing step that was wrong, not a new section.
- **Memory files** follow the frontmatter + body structure in global CLAUDE.md (feedback/project memories need **Why:** and **How to apply:** lines).

Every extra word costs context on every future load. If the draft is longer than what it replaces, reconsider.

### Step 5: Confirm per proposal

Call AskUserQuestion with one question per lesson. Include:

- The target file path (and note if Nix-managed).
- A short diff (before → after, or "new line: ...").
- Options: **Apply**, **Skip**, **Edit wording** (user supplies a rewrite), **Move to different file**.

Batch related lessons into one multi-question AskUserQuestion call when they share a theme, but keep each lesson as its own question so the user can accept/reject independently.

### Step 6: Apply and report

Apply only approved edits. For memory additions, update the corresponding `MEMORY.md` index line.

Report:

- Files changed, grouped by (Nix-managed vs live).
- Count of lessons applied / skipped / reworded.
- If any Nix-managed files changed: remind the user to rebuild.
