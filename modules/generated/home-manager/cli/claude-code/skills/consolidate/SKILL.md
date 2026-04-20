---
description: Distill lessons from the current session into CLAUDE.md, skills, and memory files so future runs have them upfront
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(ls:*), Bash(readlink:*), Bash(test:*), Bash(realpath:*), AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/consolidate/SKILL.md -->

## Your task

Reflect on this conversation and upstream what you learned into the instruction files that would have made your work easier if present at the start. Target CLAUDE.md files, SKILL.md files, and memory files. Edit in place; prefer shortening existing lines to adding new ones. Ask the user per proposal.

### Step 1: Extract lessons

Scan the whole conversation for moments that cost time or turns:

- **Corrections** — user said "no", "don't", "actually X", "stop doing Y".
- **Surprises** — you discovered a convention, path, constraint, or tool behavior only mid-task.
- **Retries** — a command/tool call you'd have gotten right on first try if you'd known X.
- **Validated judgment** — user approved an unusual choice without pushback; worth recording so future-you doesn't second-guess.

For each, write one sentence: "If I had known ___, I would have ___." Discard lessons that are: ephemeral task state, derivable from reading the repo, or already covered by existing instructions.

### Step 2: Pick the target file for each lesson

Match the lesson to the narrowest file that will load it in the right context:

- **Project CLAUDE.md** (`./CLAUDE.md` in the repo) — conventions tied to this repo that every session in it needs.
- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`) — cross-project user preferences and workflows.
- **Skill** (`~/.claude/skills/<name>/SKILL.md` or plugin skill) — lesson belongs inside a task already covered by a skill; fold it into that skill's steps.
- **Memory** (`~/.claude/projects/<id>/memory/*.md`) — facts, state, references per the auto-memory rules already in global CLAUDE.md. New memory still requires a `MEMORY.md` index line.

If a lesson fits multiple, pick the most specific one. Never duplicate across files.

### Step 3: Detect Nix-managed sources

Before editing any file under `~/.claude/` or a system path, check whether it's a symlink into the Nix store:

```bash
readlink ~/.claude/CLAUDE.md
readlink ~/.claude/skills/<name>/SKILL.md
```

If the path resolves into `/nix/store/...`, the deployed file is read-only — find and edit the source in `/etc/nixos` instead. Common sources:

- `~/.claude/CLAUDE.md` → `/etc/nixos/modules/generated/home-manager/cli/claude-code/CLAUDE.md`
- `~/.claude/skills/<name>/SKILL.md` → `/etc/nixos/modules/generated/home-manager/cli/claude-code/skills/<name>/SKILL.md`
- `~/.claude/settings.json` → defined in `/etc/nixos/modules/generated/home-manager/cli/claude-code/default.nix`

If you can't locate the source, `grep` for a unique string from the deployed file under `/etc/nixos`. Memory files under `~/.claude/projects/*/memory/` are **not** Nix-managed — edit them in place.

Changes to Nix-managed files only take effect after a rebuild. Do not run the rebuild yourself — tell the user at the end.

### Step 4: Draft each edit

For each lesson, draft the smallest possible change:

- **Prefer editing an existing line** over adding a new one. If a rule is almost right, tighten its wording instead of appending a sibling rule.
- **Prefer deletion** when a lesson obsoletes existing guidance — don't leave both.
- **One line, imperative** for CLAUDE.md rules. No preamble, no examples unless the rule is non-obvious.
- **Skill edits** go inside the existing step that was wrong, not in a new section.
- **Memory files** follow the frontmatter + body structure already documented in global CLAUDE.md (feedback/project memories need **Why:** and **How to apply:** lines).

These are LLM-consumed files — every extra word costs context on every future load. If the draft is longer than what it replaces, reconsider.

### Step 5: Confirm per proposal

For each drafted edit, call AskUserQuestion with one question per lesson. Include:

- The target file path (and note if Nix-managed).
- A short diff (before → after, or "new line: ...").
- Options: **Apply**, **Skip**, **Edit wording** (user supplies a rewrite), **Move to different file**.

Batch related lessons into one AskUserQuestion call (multi-question form) when they share a theme, but keep each lesson as its own question so the user can accept/reject independently.

### Step 6: Apply and report

Apply only approved edits. For memory additions, also update the corresponding `MEMORY.md` index line.

Report:

- Files changed, grouped by (Nix-managed vs live).
- Count of lessons applied / skipped / reworded.
- If any Nix-managed files changed: remind the user to rebuild to deploy.
