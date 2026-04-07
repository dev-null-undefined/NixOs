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
git log --oneline origin/HEAD..HEAD
```

If this fails (no upstream tracking), try:
```bash
git log --oneline origin/master..HEAD
```

If there are no unpushed commits, tell the user and stop.

### Step 2: Review each commit

For each unpushed commit, review its diff:

```bash
git show <hash>
```

Analyze each commit using the two-pass checklist below.

---

## Review Checklist

### Pass 1 — CRITICAL

Issues that can cause data loss, security vulnerabilities, or runtime failures.

#### Data Safety
- String interpolation in SQL or shell commands — use parameterized queries / proper escaping
- TOCTOU races: check-then-write patterns that should be atomic
- Unsafe deserialization of untrusted data
- Write operations that bypass validation or constraints

#### Race Conditions & Concurrency
- Read-check-write without atomicity (missing locks, missing unique constraints, no retry on conflict)
- Shared mutable state accessed without synchronization
- Status/state transitions that aren't atomic — concurrent updates can skip or double-apply
- Missing cleanup in error paths for acquired resources (locks, file handles, connections)

#### Memory & Resource Safety
- Use-after-free, double-free, dangling pointers (C/Rust unsafe blocks)
- Missing resource cleanup: unclosed file handles, sockets, temp files
- Buffer overflows, unchecked allocations, unbounded reads
- Nix: infinite recursion from circular imports or self-referencing attrsets

#### Input Trust Boundary
- Unsanitized external input (user input, API responses, LLM output, environment variables) used in:
  - Database queries, shell commands, file paths, HTML output
- Structured data from external sources accepted without type/shape validation before use
- Missing bounds checks on externally-provided indices, sizes, or counts

#### Enum & Value Completeness
When the diff introduces a new enum value, variant, option type, or status string:
- **Trace it through every consumer.** Use Grep to find all files that switch/match/branch on sibling values, then Read those files. Flag any consumer that doesn't handle the new value.
- **Check allowlists and filter arrays.** Search for arrays/lists containing sibling values — verify the new value is included where needed.
- **Check exhaustiveness.** In languages with exhaustive matching (Rust `match`, Nix `if/else` chains on type), verify all arms are covered.
- This step requires reading code OUTSIDE the diff.

### Pass 2 — INFORMATIONAL

Lower severity but still worth flagging.

#### Magic Numbers & String Coupling
- Bare numeric/string literals duplicated across files — should be named constants
- Error/status strings used as matching keys elsewhere (grep for the string — is anything pattern-matching on it?)
- Hardcoded paths, ports, or URLs that should be configurable

#### Dead Code & Consistency
- Variables/imports assigned but never read
- Comments/docstrings that describe old behavior after the code changed
- Stale configuration: options set for features that were removed in the same diff
- Version mismatches between related files (e.g., changelog vs actual changes)

#### Test Gaps
- Missing negative-path tests for new error conditions
- Assertions on existence/status but not on side effects (was the file written? was the callback fired?)
- New code paths with no test coverage where sibling paths are tested
- Security-relevant features (auth, rate limiting, input validation) without tests verifying enforcement

#### Completeness Gaps
- Implementations at 80-90% where 100% is straightforward to achieve (missing edge cases, partial error handling, incomplete pattern coverage)
- Functions that handle some variants of an input type but silently ignore others
- Error paths that swallow errors or return generic messages when specific diagnostics are available

---

## Severity Classification

```
CRITICAL:                           INFORMATIONAL:
├─ Data Safety                      ├─ Magic Numbers & String Coupling
├─ Race Conditions & Concurrency    ├─ Dead Code & Consistency
├─ Memory & Resource Safety         ├─ Test Gaps
├─ Input Trust Boundary             └─ Completeness Gaps
└─ Enum & Value Completeness
```

Present CRITICAL findings first, then INFORMATIONAL. Label each finding with its severity.

---

### Step 3: Documentation staleness check

For each `.md` file in the repo root (README.md, CLAUDE.md, etc.):

1. Check if code changes in the reviewed commits affect features, workflows, or architecture described in that doc.
2. If the doc was NOT updated but the code it describes WAS changed, add an INFORMATIONAL finding:
   `Documentation may be stale: [file] describes [feature] but code changed in this branch.`

Skip silently if no documentation files exist.

---

### Step 4: Present findings

Present all issues as a single numbered list across all commits. For each issue:
- Severity label: `[CRITICAL]` or `[INFORMATIONAL]`
- Category name
- Which commit it belongs to (short hash + title)
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

If no issues are found, tell the user and stop.

**Use AskUserQuestion to ask which issues to fix (e.g., "all", "1,3", "none"). Do not proceed until they respond.**

### Step 5: Apply fixes

For each selected issue, make the minimal fix. Do not change anything beyond what's needed for the selected issues.

After all fixes are applied, stage and commit each fix so it can be squashed into the correct original commit:

```bash
git add <files>
git commit -m "fixup! <original commit title>"
```

Use the exact original commit title after `fixup!` so autosquash can match it.

### Step 6: Squash fixes into original commits

Run interactive rebase with autosquash:

```bash
git rebase -i --autosquash <base>
```

Where `<base>` is the commit before the first unpushed commit (the merge base).

### Step 7: Report

Show the final cleaned-up history:

```bash
git log --oneline origin/HEAD..HEAD
```
