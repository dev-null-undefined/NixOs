---
description: Review changes and commit with smart grouping. Optional arg: `all` (default, commit everything), `ask` (confirm each group), `context` (only files touched this session).
argument-hint: "[all|ask|context]"
allowed-tools: Bash(git:*), Read, Grep, Glob, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/commit/SKILL.md -->

## Your task

Review all uncommitted changes, check for issues, split into logical commits matching the repo's style, and commit them.

### Scope argument

Controls which changes to commit:

- **`all`** (default) — commit every uncommitted change, grouped logically. Don't ask for confirmation on groupings.
- **`ask`** — like `all`, but call AskUserQuestion to confirm each proposed group (title + file list) before committing. Options: **Commit**, **Skip group**, **Edit message**, **Abort**.
- **`context`** — only commit files you touched or discussed this conversation. Leave unrelated pre-existing changes / untracked files alone. If nothing matches, report and exit.

If the argument is anything else, ask which mode to use first.

### Step 1: Gather context

```bash
git status
git diff
git diff --staged
git log --oneline -10
git log --oneline @{u}..HEAD   # unpushed; fails if no upstream → all local commits are unpushed
```

Match the commit-message style from `git log` exactly (casing, prefix conventions, tense, length).

### Step 2: Review the diff

Scan for issues below. If any are found, present them and **use AskUserQuestion** to ask whether to proceed, fix first, or abort. Don't commit until the user confirms.

**Security & hygiene:**
- Secrets, credentials, `.env` files, API keys, tokens
- Build artifacts, large binaries, editor temp files, `.DS_Store`

**LLM antipatterns:**
- Copy-pasted blocks that should be a shared helper
- Helpers/wrappers for one-time operations
- Extra error handling, feature flags, unused configurability
- Unused imports, unreachable branches, commented-out code
- Excessive comments on self-explanatory code
- Backwards-compat shims: re-exports, renamed `_vars`, `// removed` markers
- Deviates from patterns/idioms already in the codebase

### Step 3: Group into logical commits

Each group: one clear purpose (one feature, one fix, one refactor), no mixed concerns, short title matching `git log` style. A single commit is fine if all changes are related.

In **`context`** mode, first filter to files you touched/discussed this session. Drop the rest — don't stage them, don't mention them.

**Amending unpushed commits**: If the change logically belongs to an existing unpushed commit (same feature/fix, continuation of the same work), amend into it with `git commit --amend` instead of creating a new one. Only amend the most recent commit; use interactive rebase for older ones.

### Step 4: Execute commits

For each group:

```bash
git add <files>
git commit -m "<title>"
```

Multi-line messages — use HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
<title>

<body>
EOF
)"
```

In **`all`** and **`context`**, commit without confirmation. In **`ask`**, call AskUserQuestion per group and honor the user's choice.

### Step 5: Report

```bash
git log --oneline -<N>
```

N = number of commits you just created.
