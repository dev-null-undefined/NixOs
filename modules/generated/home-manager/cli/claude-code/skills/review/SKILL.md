---
description: Review unpushed commits, fix selected issues, and squash fixes into originals
allowed-tools: Bash(git:*), Read, Grep, Glob
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

Analyze each commit for:

**Code quality:**
- Bugs, logic errors, off-by-one mistakes
- Deprecated options or APIs
- Missing references (undefined variables, broken imports)
- Typos in code, comments, or strings
- Style violations relative to the rest of the codebase
- Dead code, unused imports

**NixOS-specific (if applicable):**
- Module conflicts (option defined in multiple places)
- Deprecated NixOS options
- Missing package references

**Security & hygiene:**
- Secrets, credentials, API keys in the diff
- Files that should not be committed

### Step 3: Present findings

Present all issues as a single numbered list across all commits. For each issue:
- Issue number
- Which commit it belongs to (short hash + title)
- What the issue is
- Suggested fix

Example:
```
1. [abc1234 add foo module] — unused import `lib` on line 3
2. [abc1234 add foo module] — typo: "enabel" → "enable" on line 12
3. [def5678 update bar] — deprecated option `services.foo.bar`, use `services.foo.baz`
```

If no issues are found, tell the user and stop.

**Wait for the user to tell you which issues to fix. Do not proceed until they respond.**

### Step 4: Apply fixes

For each selected issue, make the minimal fix. Do not change anything beyond what's needed for the selected issues.

After all fixes are applied, stage and commit each fix so it can be squashed into the correct original commit:

```bash
git add <files>
git commit -m "fixup! <original commit title>"
```

Use the exact original commit title after `fixup!` so autosquash can match it.

### Step 5: Squash fixes into original commits

Run interactive rebase with autosquash:

```bash
git rebase -i --autosquash <base>
```

Where `<base>` is the commit before the first unpushed commit (the merge base).

### Step 6: Report

Show the final cleaned-up history:

```bash
git log --oneline origin/HEAD..HEAD
```
