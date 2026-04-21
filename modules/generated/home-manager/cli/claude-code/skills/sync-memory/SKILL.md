---
description: Sync Claude memories between current machine and homie via SSH
allowed-tools: Bash(ssh:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(hostname:*), Bash(scp:*), Bash(rm:*), Bash(md5sum:*), Bash(for:*), Bash(git:*), Bash(*gather-state.sh*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-memory/SKILL.md -->

## Your task

Synchronize Claude Code memories between this machine and homie. Local memories upload to homie; relevant remote memories download here. After syncing, audit all memories for relevance.

**Scope:** every `~/.claude/projects/*/memory/` directory is synced against homie's matching project dir. Keep per-project namespaces separate — never flatten across projects.

**Git-backed:** every memory dir (both sides) is a git repo. Commit each meaningful change with a descriptive message so future sync sessions can read the history.

**Interactive:** present findings and proposed actions to the user for approval. Never silently merge, overwrite, or skip.

### Directory layout

```
~/.claude/projects/<project-id>/memory/
├── .git/
├── MEMORY.md              # project index
├── *.md                   # global memories
└── hosts/<hostname>/
    ├── MEMORY.md          # host-specific index
    └── *.md               # host-specific memories
```

Project IDs are path-encoded (e.g. `-home-martin-GitHub-martin-nixos`) and identical on both sides.

### Step 1: Gather state

Run the bundled discovery script:

```bash
~/.claude/skills/sync-memory/scripts/gather-state.sh
```

It starts SSH multiplexing (`-o ControlPath=/tmp/ssh-homie-sync-%r@%h`), initializes git repos on both sides if missing, and emits the full state as parseable sections:

- `===HOSTNAME===` — local hostname
- `===LOCAL_DIRS===` / `===REMOTE_DIRS===` — one project ID per line
- `===LOCAL_LOG:<pid>===` / `===REMOTE_LOG:<pid>===` — 30 recent commits per project; use these to understand provenance when deciding conflicts and deletions
- `===LOCAL_FILE:<pid>/<rel> md5=<sum>===` / `===REMOTE_FILE:…===` — file header; content follows, terminated by `===END_FILE===`

Build the union of project IDs — any project existing on either side is in scope. All subsequent commits you author use `-c user.email=claude@<host> -c user.name=Claude` so Claude-authored syncs are identifiable in history.

Reuse the multiplexing socket on every subsequent ssh/scp: `-o ControlPath=/tmp/ssh-homie-sync-%r@%h`.

### Step 2: Detect duplicates and conflicts

Analyze **per project** — never cross-correlate memories between different projects.

**2a. Checksums first.** Matching md5 on both sides = already in sync, skip. Only inspect files that exist on just one side or differ.

**2b. Exact filename matches.** Same relative path, different content = conflict. Use `git log --all -- <file>` on each side to see history — helps decide which is fresher / more intentional. Also compare each local flat file against `hosts/<local-hostname>/` on homie — these are your own previously-uploaded host-specific memories.

**2c. Semantic duplicates.** Same topic, different filenames. Signals: matching `name`/`description` frontmatter, same core rule with different wording, one is a subset of the other.

**2d. Classify new memories.** For memories existing on only one side with no duplicates:

- **Global** — relevant across all machines. `user` and `feedback` types are almost always global; `project` and `reference` usually are unless tied to hardware or local-only services.
- **Host-specific** — hardware specifics, host-only services, host-only debugging history.

**2e. Deletions.** If a file is referenced in one side's `MEMORY.md` index but missing from disk on that side (while present on the other), the deletion was probably intentional. Check `git log` for recent delete commits — if there's a justifying message, propagate the deletion rather than re-uploading.

### Step 3: Present sync plan

Use AskUserQuestion for every merge/overwrite/skip/delete decision. Group decisions by project.

- **Conflicts:** show diff + relevant `git log` lines. Options: **Keep local**, **Keep remote**, **Merge** (you draft merged version).
- **Semantic duplicates:** show both side by side. Options: **Merge into one**, **Keep both**, **Keep only local**, **Keep only remote**. Prefer the more detailed version as base; use the more descriptive filename.
- **Deletions:** show the deletion's commit message + surviving copy. Ask to propagate or restore.
- **New memories:** per project, list by category (upload global / upload host-specific / download global / download host-specific with `<source-hostname>_` prefix / skip). Let the user override any classification.

### Step 4: Execute sync

Only after approval. Every mutating action is followed by a git commit on both affected sides with a Claude-authored message explaining the action. Use short imperative subjects; add a body when the reason needs more than a line. Helpers:

```bash
CM='-c user.email=claude@<host> -c user.name=Claude'   # substitute <host> per side
SSH_OPTS='-o ControlPath=/tmp/ssh-homie-sync-%r@%h'
```

**Upload to homie (global):**

```bash
scp $SSH_OPTS <local>/<file>.md homie:~/.claude/projects/<pid>/memory/<file>.md
ssh $SSH_OPTS homie "git -C ~/.claude/projects/<pid>/memory $CM add <file>.md && \
  git -C ~/.claude/projects/<pid>/memory $CM commit -q \
    -m 'sync: upload <file>.md from <local-host>' -m '<why>'"
# Also record locally as a marker commit (--allow-empty if the file was already committed)
git -C <local> $CM add <file>.md
git -C <local> $CM commit -q -m 'sync: upload <file>.md to homie' -m '<why>' --allow-empty
```

**Upload host-specific:** same pattern, but `mkdir -p ~/.claude/projects/<pid>/memory/hosts/<local-host>` on homie first, scp to that path, and commit that path.

**Download from homie:**

```bash
scp $SSH_OPTS homie:~/.claude/projects/<pid>/memory/<file>.md <local>/<file>.md
git -C <local> $CM add <file>.md
git -C <local> $CM commit -q -m 'sync: download <file>.md from homie' -m '<why relevant here>'
```

For host-specific memories from **other** hosts, rename on download: `<other-host>_<file>.md`.

**Merges:** write merged content to the surviving filename locally → upload → remove retired filename on both sides → single merge commit per side: `sync: merge <old-a>.md + <old-b>.md -> <new>.md` with a body naming what was kept from each.

**Conflicts:** overwrite the losing side → commit both sides: `sync: resolve conflict on <file>.md (keep <winner>) — <reason from user or inferred from git log>`.

**Deletions:** `rm <file>.md` → commit both sides: `sync: remove <file>.md (<short reason>)` with body.

### Step 5: Update indices

After content changes settle for a project, update its `MEMORY.md` files as a **separate "chore: update index" commit** so it's visually distinct in `git log`:

- **Main `MEMORY.md`** (per project, each side): add entries for new global memories, remove entries for deletions/merges. Don't list host-specific memories here.
- **`hosts/<local-host>/MEMORY.md`** (on homie only): list host-specific memories uploaded from this machine.

### Step 6: Relevance audit

Audit **all local memories across all projects**. Goal: identify memories wasting context or actively harmful.

Check each for:

- **Stale/outdated** — references files/functions/options that no longer exist (grep/glob to verify), describes changed project state, passed dates/deadlines (today's date is in CLAUDE.md context), decommissioned tools.
- **Redundant** — duplicates CLAUDE.md, describes patterns derivable from code, restates git history.
- **Too vague** — generic common-sense advice, no actionable content ("user mentioned X once").
- **Contradictory** — conflicts with current CLAUDE.md, correct at the time but now wrong, recommends approaches that have been explicitly rejected.

`git log` on each file is a powerful staleness signal — a long-untouched memory referencing recent-looking code is a prime candidate for review.

Use AskUserQuestion to present grouped removal suggestions:
- **Recommend removal** (high confidence harmful/useless) — with specific reason
- **Consider removal** (possibly stale) — with what seems off and what would need to be true for it to still be valid
- **Suggest update** (still valid, details outdated) — with what needs changing

Apply selections on both sides. Each removal/update is its own commit; update `MEMORY.md` indices in a separate index commit.

### Step 7: Cleanup and report

Close the SSH control connection:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h -O exit homie 2>/dev/null
```

Summary grouped by project:
- **Merged**: pairs combined, resulting filename
- **Uploaded to homie**: global + host-specific
- **Downloaded from homie**: files with source
- **Conflict resolutions**: files with winner
- **Deletions propagated**: files + direction
- **Skipped (not relevant)**: files with reason
- **Already in sync**: count
- **Removed (stale/poisonous)**: files with reasons
- **Updated**: files with what changed

Then print the new commit count per side (`git -C <dir> rev-list --count HEAD` compared to the pre-sync count if you captured it) so the user can see how much was recorded this session.
