---
description: Sync Claude memories between current machine and homie via SSH
allowed-tools: Bash(ssh:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(hostname:*), Bash(scp:*), Bash(rm:*), Bash(md5sum:*), Bash(for:*), Bash(git:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-memory/SKILL.md -->

## Your task

Synchronize Claude Code memories between this machine and homie. Memories are merged bidirectionally — local memories are uploaded to homie, and relevant remote memories are downloaded here. After syncing, audit all memories for relevance and suggest cleanup.

**Scope:** Sync **every** project memory directory under `~/.claude/projects/*/memory/`, not just the NixOS one. Each project is synced independently against homie's matching project directory. Keep per-project namespaces separate — never flatten memories across projects.

**Git-backed:** Every memory directory (on this machine and on homie) is a git repository. You author a commit for each meaningful change (upload, download, merge, conflict resolution, deletion, cleanup) with a message explaining **what** and **why**. Future sync sessions read `git log` to understand context.

**Important: This is an interactive process.** Present findings and proposed actions to the user for approval before making changes. Never silently merge, overwrite, or skip memories.

### Directory structure

Each project has its own memory directory on both sides. The layout is mirrored:

```
~/.claude/projects/
├── <project-id-1>/memory/
│   ├── .git/                      # per-project git repo
│   ├── MEMORY.md                  # index for this project
│   ├── *.md                       # global + local memory files
│   └── hosts/
│       └── <hostname>/
│           ├── MEMORY.md          # host-specific index
│           └── *.md               # host-specific memories
├── <project-id-2>/memory/
│   └── ...
└── ...
```

Project IDs are path-encoded (e.g. `-home-martin-GitHub-martin-nixos`). The same project ID is used on both machines.

### Step 1: Gather state

#### 1a. Discover paths and set up SSH multiplexing

Start a persistent SSH control connection to avoid repeated handshakes and noisy fingerprint output:

```bash
ssh -o ControlMaster=yes -o ControlPath=/tmp/ssh-homie-sync-%r@%h -o ControlPersist=300 -fN homie
```

Use `-o ControlPath=/tmp/ssh-homie-sync-%r@%h` on all subsequent `ssh`/`scp` commands. Clean up at the very end:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h -O exit homie 2>/dev/null
```

Discover the local hostname and all local project memory directories:

```bash
hostname
ls -d ~/.claude/projects/*/memory/ 2>/dev/null
```

Discover all remote project memory directories on homie in one call:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie 'ls -d ~/.claude/projects/*/memory/ 2>/dev/null'
```

Build the union of project IDs — any project that exists on either side is in scope.

#### 1b. Ensure git repositories exist

For every project memory dir on this machine, initialize a git repo if one isn't already present:

```bash
for d in ~/.claude/projects/*/memory/; do
  if [ ! -d "$d/.git" ]; then
    git -C "$d" init -q -b main
    git -C "$d" add -A
    git -C "$d" -c user.email=claude@local -c user.name=Claude commit -q -m "chore: initialize memory repo" 2>/dev/null || true
  fi
done
```

Do the same on homie in a single SSH call:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie '
for d in ~/.claude/projects/*/memory/; do
  if [ ! -d "$d/.git" ]; then
    git -C "$d" init -q -b main
    git -C "$d" add -A
    git -C "$d" -c user.email=claude@homie -c user.name=Claude commit -q -m "chore: initialize memory repo" 2>/dev/null || true
  fi
done'
```

All subsequent commits you author should use `-c user.email=claude@<host> -c user.name=Claude` so history clearly identifies Claude-authored syncs.

#### 1c. Read git history for context

For each project, read recent commit history on **both** sides. The messages explain why memories were added, merged, or removed — use this when judging conflicts and staleness in later steps.

```bash
for d in ~/.claude/projects/*/memory/; do
  echo "===HISTORY:$(basename "$(dirname "$d")")==="
  git -C "$d" log --oneline -n 30 2>/dev/null
done
```

And remotely:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie '
for d in ~/.claude/projects/*/memory/; do
  echo "===HISTORY:$(basename "$(dirname "$d")")==="
  git -C "$d" log --oneline -n 30 2>/dev/null
done'
```

#### 1d. Read all memory files

**Local:**

```bash
for d in ~/.claude/projects/*/memory/; do
  pid=$(basename "$(dirname "$d")")
  shopt -s nullglob
  for f in "$d"*.md "$d"hosts/*/*.md; do
    [ "$(basename "$f")" = "MEMORY.md" ] && continue
    echo "===FILE:$pid/${f#$d}==="
    cat "$f"
  done
done
```

**Remote** — batch-read all projects in a single SSH command:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie '
shopt -s nullglob
for d in ~/.claude/projects/*/memory/; do
  pid=$(basename "$(dirname "$d")")
  for f in "$d"*.md "$d"hosts/*/*.md; do
    [ "$(basename "$f")" = "MEMORY.md" ] && continue
    rel="${f#$d}"
    echo "===FILE:$pid/$rel==="
    cat "$f"
  done
done'
```

**Important:** `shopt -s nullglob` prevents failed globs from emitting literal strings. The `MEMORY.md` filter is inside the loop — do NOT pipe through `grep -v` externally, as it can silently swallow all output. The emitted path is `<project-id>/<relative-path>` so you can route each file back to its project.

Parse each `===FILE:<project-id>/<rel>===` block into project, relative path, and content.

### Step 2: Detect duplicates and conflicts

Analyze all memories from both sides together, **per project**. Do not cross-correlate memories between different projects.

#### 2a. Checksum comparison (fast path)

Before reading full content comparisons, checksum every file so identical ones can be skipped:

```bash
# Local
for d in ~/.claude/projects/*/memory/; do
  pid=$(basename "$(dirname "$d")")
  shopt -s nullglob
  for f in "$d"*.md "$d"hosts/*/*.md; do
    [ "$(basename "$f")" = "MEMORY.md" ] && continue
    echo "$pid/${f#$d} $(md5sum "$f" | cut -d' ' -f1)"
  done
done

# Remote
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie '
shopt -s nullglob
for d in ~/.claude/projects/*/memory/; do
  pid=$(basename "$(dirname "$d")")
  for f in "$d"*.md "$d"hosts/*/*.md; do
    [ "$(basename "$f")" = "MEMORY.md" ] && continue
    echo "$pid/${f#$d} $(md5sum "$f" | cut -d" " -f1)"
  done
done'
```

Files with matching checksums are already in sync — skip reading their content. Only diff/inspect files that exist on just one side or that differ.

#### 2b. Exact filename matches (conflicts)

Within the **same project**, files with the same relative path on both sides with different content are conflicts. Use `git log --all -- <file>` on each side to see each memory's history — this helps decide which side is fresher / more intentional.

**Also compare each local flat file against `hosts/<local-hostname>/` on homie** — these are your own previously-uploaded host-specific memories. Same rules apply.

#### 2c. Semantic duplicates (different filenames, same topic)

Within the **same project**, scan for memories that cover the same topic but have different filenames. Common patterns:
- Same `name` or `description` in frontmatter
- Same core advice/rule with different wording
- One is a subset of the other

#### 2d. Classify new memories

For memories that exist on only one side with no duplicates, classify as:

**Global** — relevant across all machines for this project. Signals:
- `user` and `feedback` types are almost always global
- `project` and `reference` types are usually global unless tied to hardware or local-only services

**Host-specific** — relevant only to the originating machine:
- Hardware-specific details, host-only services, host-only debugging history

#### 2e. Detect deletions

If a file is referenced in one side's `MEMORY.md` index but missing from disk on that side (while still present on the other side), the deletion was probably intentional. Also inspect `git log` for recent `rm` / delete commits — if a file was removed with a justifying commit message, propagate the deletion rather than re-uploading it.

### Step 3: Present sync plan to user

Use AskUserQuestion for every decision that involves merging, overwriting, skipping, or deleting. Group decisions by project so the user sees each project's plan as a coherent unit.

#### 3a. Conflicts (same filename, different content)

Show a diff summary and ask:
- **Keep local** — overwrite remote with local
- **Keep remote** — overwrite local with remote
- **Merge** — draft a merged version for approval

Include the relevant `git log` line from each side so the user understands provenance.

#### 3b. Semantic duplicates

Show both memories side by side and ask:
- **Merge into one** (you draft merged content + filename)
- **Keep both**
- **Keep only local** / **Keep only remote**

Prefer the more detailed version as the base; use the more descriptive filename.

#### 3c. Deletions

For each detected deletion, show the deletion's commit message (if any) and the surviving copy. Ask to propagate or restore.

#### 3d. New memories (no conflicts or duplicates)

Per project, list:
- **Will upload to homie (global)**
- **Will upload to homie (host-specific)**
- **Will download from homie (global)**
- **Will download from homie (host-specific from other hosts)** — prefix filename with `<source-hostname>_` to avoid collisions
- **Will skip (not relevant to this machine)**

Let the user override any classification.

### Step 4: Execute sync

Only after user approval. Every file-mutating action is followed by a git commit with a Claude-authored message explaining the action. Use short, imperative commit subjects plus a body when the reason needs more than a line.

Shared commit boilerplate (abbreviate `$CM` below):

```
CM='-c user.email=claude@<host> -c user.name=Claude'
```

On homie, substitute `<host>=homie`; locally, substitute the real hostname.

#### 4a. Upload to homie

**Global:**

```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h <local-memory>/<file>.md homie:~/.claude/projects/<project-id>/memory/<file>.md
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "
git -C ~/.claude/projects/<project-id>/memory $CM add <file>.md &&
git -C ~/.claude/projects/<project-id>/memory $CM commit -q -m 'sync: upload <file>.md from <local-hostname>' -m '<one-line why>'"
```

**Host-specific:**

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "mkdir -p ~/.claude/projects/<project-id>/memory/hosts/<local-hostname>"
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h <local-memory>/<file>.md homie:~/.claude/projects/<project-id>/memory/hosts/<local-hostname>/<file>.md
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "
git -C ~/.claude/projects/<project-id>/memory $CM add hosts/<local-hostname>/<file>.md &&
git -C ~/.claude/projects/<project-id>/memory $CM commit -q -m 'sync: upload host-specific <file>.md from <local-hostname>' -m '<why this is host-specific>'"
```

Also commit locally on this machine to record that the file was uploaded (no content change, just a marker commit if the file was already committed — otherwise commit the file itself):

```bash
git -C <local-memory> $CM add <file>.md
git -C <local-memory> $CM commit -q -m 'sync: upload <file>.md to homie' -m '<why>' --allow-empty
```

#### 4b. Download from homie

```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie:~/.claude/projects/<project-id>/memory/<file>.md <local-memory>/<file>.md
git -C <local-memory> $CM add <file>.md
git -C <local-memory> $CM commit -q -m 'sync: download <file>.md from homie' -m '<why this is relevant here>'
```

For host-specific memories from **other** hosts, prefix with the source hostname:

```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie:~/.claude/projects/<project-id>/memory/hosts/<other-host>/<file>.md <local-memory>/<other-host>_<file>.md
git -C <local-memory> $CM add <other-host>_<file>.md
git -C <local-memory> $CM commit -q -m 'sync: download <other-host>_<file>.md (host-specific from <other-host>)' -m '<why relevant>'
```

#### 4c. Apply merges

For memories the user chose to merge:

1. Write the merged content to the surviving filename locally.
2. Upload to homie.
3. Remove the retired filename on both sides.

Commit each side with a single merge commit that references both retired sources:

```bash
git -C <local-memory> $CM add -A
git -C <local-memory> $CM commit -q -m 'sync: merge <old-a>.md + <old-b>.md -> <new>.md' -m '<why merged, what was kept from each>'

ssh ... homie "git -C ~/.claude/projects/<project-id>/memory $CM add -A && git -C ~/.claude/projects/<project-id>/memory $CM commit -q -m 'sync: merge <old-a>.md + <old-b>.md -> <new>.md' -m '<same body>'"
```

#### 4d. Apply conflict resolutions

Overwrite the losing side. Commit it with a message naming the winning side and why:

```
sync: resolve conflict on <file>.md (keep <winner>)

Homie version was outdated — <reason from user or inferred from git log>.
```

#### 4e. Apply deletions

Remove the file, commit with reason:

```bash
rm <local-memory>/<file>.md
git -C <local-memory> $CM add -A
git -C <local-memory> $CM commit -q -m 'sync: remove <file>.md (<short reason>)' -m '<full reason>'
```

Do the same on homie.

### Step 5: Update indices

After content changes for a project settle, update its `MEMORY.md` files and commit them as a separate "chore: update index" commit so the index update is visually distinct in `git log`:

- **Main `MEMORY.md`** (per project on homie, and per project locally): add entries for new global memories, remove entries for deletions/merges. Do not list host-specific memories here.
- **`hosts/<local-hostname>/MEMORY.md`** (on homie only): list host-specific memories uploaded from this machine.

Commit per side:

```bash
git -C <local-memory> $CM add MEMORY.md
git -C <local-memory> $CM commit -q -m 'chore: update MEMORY.md index' -m 'Reflect additions/removals from this sync session.'
```

### Step 6: Relevance audit

After syncing, audit **all local memories across all projects** for relevance. Goal: identify memories wasting context or actively harmful.

#### 6a. Read and evaluate

For each memory file, check for:

**Stale / outdated:**
- References files, functions, options, or packages that no longer exist (grep/glob to verify)
- Describes project state that has clearly changed
- Dates/deadlines that have passed (today is the current date — see context)
- References decommissioned tools/services

**Redundant / already in code:**
- Duplicates CLAUDE.md
- Describes patterns derivable from reading code
- Restates git history / commit messages

**Too vague:**
- Generic common-sense advice
- No actionable content ("user mentioned X once")

**Contradictory / poisonous:**
- Conflicts with current CLAUDE.md instructions
- Advice correct at the time but now wrong due to code/tooling changes
- Recommends approaches that have been explicitly rejected

`git log` on each file is a powerful staleness signal — a memory that hasn't been touched in a long time and references recent-looking code is a prime candidate for re-evaluation.

#### 6b. Present removal suggestions

Group via AskUserQuestion:

- **Recommend removal** (high confidence harmful/useless) — with specific reason
- **Consider removal** (possibly stale) — with what seems off and what would need to be true for it to still be valid
- **Suggest update** (still valid but details outdated) — with what needs changing

Apply selections on both sides. Each removal/update is its own commit with a descriptive message explaining why it was retired or updated. Update `MEMORY.md` indices too, in a separate index commit.

### Step 7: Cleanup and report

Close the SSH control connection:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h -O exit homie 2>/dev/null
```

Print a summary grouped by project:

- **Merged**: pairs combined, resulting filename
- **Uploaded to homie (global)**: files
- **Uploaded to homie (host-specific)**: files
- **Downloaded from homie**: files with source (main or which host)
- **Conflict resolutions**: files with winner
- **Deletions propagated**: files and direction
- **Skipped (not relevant)**: files with reason
- **Already in sync**: count
- **Removed (stale/poisonous)**: files with reasons
- **Updated**: files with what changed

Then print the new commit count per side (e.g. `git -C <dir> rev-list --count HEAD` compared to the pre-sync count if you captured it) so the user can see at a glance how much was recorded to git this session.
