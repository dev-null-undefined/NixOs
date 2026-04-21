---
description: Review unpushed commits, fix selected issues, and squash fixes into originals
allowed-tools: Bash(git:*), Read, Grep, Glob, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/review/SKILL.md -->

## Your task

Review all unpushed commits, present issues as a numbered list, wait for the user to select which to fix, apply fixes, then squash each fix into its original commit.

### Step 1: Find unpushed commits

```bash
git log --oneline @{u}..HEAD
```

If there's no upstream tracking, fall back to `origin/master..HEAD` (or `origin/main`). If there are no unpushed commits, tell the user and stop.

### Step 2: Review each commit

For each unpushed commit, review its diff with `git show <hash>` and apply the two-pass checklist below.

---

## Review Checklist

### Pass 1 — CRITICAL

Issues that can cause data loss, security vulnerabilities, or runtime failures.

**Data Safety**
- String interpolation in SQL or shell — use parameterized queries / proper escaping
- TOCTOU: check-then-write patterns that should be atomic
- Unsafe deserialization of untrusted data
- Writes that bypass validation or constraints

**Race Conditions & Concurrency**
- Read-check-write without atomicity (missing locks, unique constraints, or retry on conflict)
- Shared mutable state accessed without synchronization
- Non-atomic state transitions — concurrent updates can skip or double-apply
- Missing cleanup in error paths for acquired resources (locks, handles, connections)

**Memory & Resource Safety**
- Use-after-free, double-free, dangling pointers (C/Rust unsafe)
- Unclosed file handles, sockets, temp files; unchecked allocations, unbounded reads
- Buffer overflows
- Nix: infinite recursion from circular imports or self-referencing attrsets

**Input Trust Boundary**
- Unsanitized external input (user input, API responses, LLM output, env vars) used in DB queries, shell, file paths, or HTML
- Structured external data used without type/shape validation, or missing bounds checks on externally-provided indices/sizes

**Enum & Value Completeness** — when a commit introduces a new enum value, variant, option type, or status string:
- **Trace it through every consumer.** Grep for files that switch/match on sibling values, then Read them. Flag any consumer that doesn't handle the new value.
- **Check allowlists and filter arrays.** Search for arrays containing sibling values — verify the new one is included where needed.
- **Check exhaustiveness** in languages with exhaustive matching (Rust `match`, Nix `if/else` chains on type).
- This step requires reading code OUTSIDE the diff.

### Pass 2 — INFORMATIONAL

Lower severity but worth flagging.

**Magic Numbers & String Coupling**
- Bare numeric/string literals duplicated across files — should be named constants
- Error/status strings used as matching keys elsewhere (grep — is anything pattern-matching on it?)
- Hardcoded paths, ports, or URLs that should be configurable

**Dead Code & Consistency**
- Variables/imports assigned but never read
- Comments/docstrings describing old behavior after the code changed
- Stale configuration: options set for features removed in the same diff
- Version mismatches between related files (changelog vs actual changes)

**Test Gaps**
- Missing negative-path tests for new error conditions
- Assertions on existence/status but not on side effects (was the file written? was the callback fired?)
- New code paths with no coverage where sibling paths are tested
- Security-relevant features (auth, rate limiting, input validation) without enforcement tests

**Completeness Gaps**
- 80-90% implementations where 100% is straightforward (missing edge cases, partial error handling)
- Functions that handle some variants of an input type but silently ignore others
- Error paths that swallow errors or return generic messages when specific diagnostics are available

---

### Step 3: Documentation staleness check

For each `.md` file in the repo root (README.md, CLAUDE.md, etc.), check if reviewed commits changed features/workflows/architecture described there. If yes and the doc wasn't updated, add an INFORMATIONAL finding:

> Documentation may be stale: [file] describes [feature] but code changed in this branch.

Skip silently if no doc files exist.

### Step 4: Present findings

Single numbered list across all commits. For each issue:
- Severity: `[CRITICAL]` or `[INFORMATIONAL]`
- Category
- Commit (short hash + title)
- What the issue is
- Suggested fix

Example:
```
1. [CRITICAL] [Data Safety] [abc1234 add user module] — unsanitized input in SQL query on line 15
   Fix: use parameterized query
2. [INFORMATIONAL] [Dead Code] [abc1234 add user module] — unused import `lib` on line 3
   Fix: remove import
3. [INFORMATIONAL] [Documentation] [def5678 update bar] — CLAUDE.md describes old module path
   Fix: update architecture section
```

Present CRITICAL first, then INFORMATIONAL. If no issues, tell the user and stop.

**Use AskUserQuestion to ask which issues to fix (e.g., "all", "1,3", "none"). Don't proceed until they respond.**

### Step 5: Apply fixes

For each selected issue, make the minimal fix — nothing beyond what's needed.

After all fixes, stage and commit each so autosquash can match it:

```bash
git add <files>
git commit -m "fixup! <original commit title>"
```

Use the exact original commit title after `fixup!`.

### Step 6: Squash fixes

```bash
git rebase -i --autosquash <base>
```

`<base>` is the commit before the first unpushed commit.

### Step 7: Report

```bash
git log --oneline @{u}..HEAD
```
