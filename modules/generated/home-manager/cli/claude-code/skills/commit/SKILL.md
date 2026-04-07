---
description: Review changes and commit with smart grouping
allowed-tools: Bash(git:*), Read, Grep, Glob, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/commit/SKILL.md -->

## Your task

Review all uncommitted changes, check for issues, split into logical commits matching the repo's style, and commit them.

### Step 1: Gather context

Run these commands to understand the current state:

```bash
git status
```

```bash
git diff
```

```bash
git diff --staged
```

```bash
git log --oneline -10
```

Note the commit message style from `git log` — you must match it exactly (casing, prefix conventions, tense, length).

Check for unpushed local commits:
```bash
git log --oneline @{u}..HEAD
```
If this fails (no upstream), all local commits are unpushed.

### Step 2: Review changes

Analyze the full diff for the following issues. If any are found, present them and **use AskUserQuestion** to ask whether to proceed, fix the issues first, or abort. Do not commit until the user confirms.

**Security & hygiene:**
- Secrets, credentials, `.env` files, API keys, tokens in the diff
- Files that should not be committed: build artifacts, large binaries, editor temp files, `.DS_Store`

**Code quality — LLM antipatterns:**
- Duplicate code: copy-pasted blocks that should be a shared function or module
- Unnecessary abstractions: helpers, wrappers, or utilities for one-time operations
- Over-engineering: complexity beyond what the change requires (extra error handling, feature flags, unused configurability)
- Dead code: unused imports, unreachable branches, commented-out code left behind
- Excessive comments or docstrings on self-explanatory code
- Backwards-compat shims: re-exports, renamed `_vars`, `// removed` markers for deleted code
- Style inconsistency: code that does not follow the patterns, naming conventions, and idioms used in the rest of the codebase

### Step 3: Group into logical commits

Analyze all changes and split them into groups where each group:
- Has a single clear purpose (one feature, one fix, one refactor)
- Does NOT mix unrelated changes
- Gets a short commit title matching the style from `git log`

If all changes are related, a single commit is fine.

**Amending unpushed commits**: If there are unpushed local commits and the current changes logically belong to one of them (same feature, same fix, continuation of the same work), amend into that commit using `git commit --amend` instead of creating a new one. Only amend the most recent commit (use interactive rebase for older ones if needed). If the changes are unrelated to any existing unpushed commit, create a new commit as usual.

### Step 4: Execute commits

For each group, stage the relevant files and commit:

```bash
git add <files>
```

```bash
git commit -m "<message>"
```

Use a HEREDOC for multi-line messages:
```bash
git commit -m "$(cat <<'EOF'
<title>

<body if needed>
EOF
)"
```

Do not ask for confirmation. Just commit.

### Step 5: Report

Print the final list of commits created:

```bash
git log --oneline -<N>
```

Where N is the number of commits you just created. Show only the new commits.
