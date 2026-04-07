---
description: Sync Claude memories between current machine and homie via SSH
allowed-tools: Bash(ssh:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(hostname:*), Bash(scp:*), Bash(rm:*), Bash(md5sum:*), Bash(for:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-memory/SKILL.md -->

## Your task

Synchronize Claude Code memories between this machine and homie. Memories are merged bidirectionally — local memories are uploaded to homie, and relevant remote memories are downloaded here. After syncing, audit all memories for relevance and suggest cleanup.

**Important: This is an interactive process.** Present findings and proposed actions to the user for approval before making changes. Never silently merge, overwrite, or skip memories.

### Directory structure

On homie, the canonical memory directory is `~/.claude/projects/-etc-nixos/memory/`. Host-specific memories from other machines are stored in subdirectories:

```
memory/
├── MEMORY.md                  # Main index (global + local memories)
├── *.md                       # Global and local memory files
└── hosts/
    └── <hostname>/
        ├── MEMORY.md           # Index for that host's specific memories
        └── *.md                # Host-specific memory files
```

### Step 1: Gather state

#### 1a. Discover paths

The local memory directory path varies by machine — it encodes the absolute path to the repo with `-` separators. **Do not hardcode it.** Discover it dynamically:

```bash
hostname
ls -d ~/.claude/projects/*/memory/ 2>/dev/null
```

Identify which local project directory corresponds to the NixOS config (look for the one containing this repo's memories — it may be `-etc-nixos`, `-home-martin-GitHub-martin-nixos`, or another path depending on where the repo is cloned/symlinked).

The remote path on homie is always `~/.claude/projects/-etc-nixos/memory/`.

#### 1b. Set up SSH multiplexing

To avoid repeated SSH handshakes (and noisy host key fingerprint output), start a persistent SSH control connection at the beginning:

```bash
ssh -o ControlMaster=yes -o ControlPath=/tmp/ssh-homie-sync-%r@%h -o ControlPersist=120 -fN homie
```

Then use `-o ControlPath=/tmp/ssh-homie-sync-%r@%h` on all subsequent `ssh` and `scp` commands. Clean up at the end:

```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h -O exit homie 2>/dev/null
```

#### 1c. Read all memory files

Read all local memory files (every `.md` in the memory directory, excluding `MEMORY.md`) and all remote memory files on homie.

**Local files:**
```bash
ls <local-memory-dir>/*.md | grep -v MEMORY.md
```

Read each local file with the Read tool.

**Remote files** — batch-read everything in a single SSH command to avoid N round-trips:
```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie 'shopt -s nullglob; for f in ~/.claude/projects/-etc-nixos/memory/*.md ~/.claude/projects/-etc-nixos/memory/hosts/*/*.md; do [ "$(basename "$f")" = "MEMORY.md" ] && continue; echo "===FILE:$(basename "$f")===" && cat "$f"; done'
```

**Important:** `shopt -s nullglob` prevents failed globs (e.g., when `hosts/` doesn't exist) from producing literal strings. The MEMORY.md filter is inside the loop — do NOT pipe through `grep -v` externally, as this can silently swallow all output. Only basenames are emitted to simplify parsing.

Parse each `===FILE:<basename>===` block into filename and content.

### Step 2: Detect duplicates and conflicts

Before syncing anything, analyze all memories from both sides together. Build a unified view.

#### 2pre. Checksum comparison (fast path)

Before reading full file contents, use checksums to quickly identify which files with matching names are identical vs different:

```bash
# Local checksums
md5sum <local-memory-dir>/*.md | grep -v MEMORY.md

# Remote checksums
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie 'md5sum ~/.claude/projects/-etc-nixos/memory/*.md' | grep -v MEMORY.md
```

Files with matching checksums are already in sync — skip reading their full content. Only read full content for files that differ or exist on only one side. This saves significant context window space as the memory set grows.

#### 2a. Exact filename matches (conflicts)

Files with the **same filename** on both sides — compare content:
- **Identical content**: already in sync, no action needed
- **Different content**: this is a conflict — present both versions to the user (see Step 3)

**Also compare local files against `hosts/<local-hostname>/` on homie.** These are your own previously-uploaded host-specific memories. If content matches, they're in sync. If content differs, treat as a conflict.

#### 2b. Semantic duplicates (different filenames, same topic)

Scan for memories that cover the **same topic** but have different filenames. Common patterns:
- Same `name` or `description` in frontmatter
- Same core advice/rule with different wording or examples
- One is a subset of the other (e.g., a short version vs a detailed version)

For each potential duplicate pair found, flag it for user review (see Step 3).

#### 2c. Classify new memories

For memories that exist on only one side and have no duplicates, classify as:

**Global** — relevant to all machines working on this NixOS config. Use the `type` frontmatter field as the primary signal:
- `user` and `feedback` types are almost always global
- `project` and `reference` types are usually global unless they reference hardware or local-only services
- Fall back to content analysis when the type is ambiguous

Content signals for global:
- User preferences, role, workflow habits
- Project-wide decisions, architecture notes, conventions
- External references
- Feedback about Claude behavior, code style, commit style

**Host-specific** — relevant only to the originating machine:
- Hardware-specific details (GPU model, disk layout, peripherals)
- Services running only on this host
- Local network config or IP addresses specific to this machine
- Machine-specific debugging history

#### 2d. Detect deletions

If a memory exists on one side but is referenced in the other side's `MEMORY.md` index without a corresponding file, it was likely deleted since the last sync. Flag these as potential deletions rather than treating them as "new on the other side". Ask the user whether to:
- **Delete from both sides** — the deletion was intentional
- **Restore** — the deletion was accidental, re-sync the surviving copy

### Step 3: Present sync plan to user

**Use AskUserQuestion for every decision that involves merging, overwriting, or skipping.** Present the full sync plan before executing anything.

#### 3a. Conflicts (same filename, different content)

For each conflict, show a diff summary and ask:

- **Keep local** — overwrite remote with local version
- **Keep remote** — overwrite local with remote version
- **Merge** — combine the best parts (you'll draft the merged version for approval)

#### 3b. Semantic duplicates

For each duplicate pair, show both memories side by side and ask:

- **Merge into one** — combine into a single memory, delete the other. You draft the merged content and a filename, user approves. The merged file replaces both originals on both machines.
- **Keep both** — sync both to both sides as-is
- **Keep only local / Keep only remote** — delete the other from its origin

When merging, prefer the more detailed/specific version as the base, and incorporate any unique details from the other. Use the more descriptive filename.

#### 3c. Deletions

For each detected deletion, show what was deleted and where the surviving copy is. Ask whether to propagate the deletion or restore.

#### 3d. New memories (no conflicts or duplicates)

Present the list of new memories to sync in each direction, grouped by classification:

- **Will upload to homie (global)**: list with one-line descriptions
- **Will upload to homie (host-specific)**: list with one-line descriptions
- **Will download from homie**: list with one-line descriptions — prefix downloaded host-specific files with `<hostname>_` to avoid filename collisions
- **Will skip (not relevant to this machine)**: list with reasons

Ask user to confirm, or let them override any classification.

### Step 4: Execute sync

Only after user approval, execute the sync plan:

#### 4a. Upload to homie

**Global memories** — upload to homie's main memory directory:
```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h <local-memory-dir>/<file>.md homie:~/.claude/projects/-etc-nixos/memory/<file>.md
```

**Host-specific memories** — upload to the host-specific subdirectory:
```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "mkdir -p ~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>"
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h <local-memory-dir>/<file>.md homie:~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>/<file>.md
```

#### 4b. Download from homie

For global memories:
```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie:~/.claude/projects/-etc-nixos/memory/<file>.md <local-memory-dir>/<file>.md
```

For host-specific memories from other hosts — **prefix with source hostname** to avoid collisions:
```bash
scp -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie:~/.claude/projects/-etc-nixos/memory/hosts/<other-host>/<file>.md <local-memory-dir>/<other-host>_<file>.md
```

#### 4c. Apply merges

For any memories the user chose to merge:
1. Write the merged content to the surviving filename on the local side
2. Upload to homie
3. Delete the retired filename from both sides:
```bash
rm <local-memory-dir>/<retired-file>.md
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "rm ~/.claude/projects/-etc-nixos/memory/<retired-file>.md 2>/dev/null"
```

#### 4d. Apply conflict resolutions

Overwrite the losing side with the winning version.

#### 4e. Apply deletions

For deletions the user confirmed, remove from the surviving side:
```bash
# If deleting from remote
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h homie "rm ~/.claude/projects/-etc-nixos/memory/<file>.md 2>/dev/null"
# If deleting from local
rm <local-memory-dir>/<file>.md
```

### Step 5: Update indices

**Update homie's main MEMORY.md** to include any newly uploaded global memories:
- Keep all existing entries
- Add new entries for uploaded global memories: `- [Descriptive title](file.md) — one-line description`
- Remove entries for any deleted/merged files
- Do NOT add host-specific memories to the main index

**Update/create homie's host-specific MEMORY.md** at `hosts/<local-hostname>/MEMORY.md`:
- List all host-specific memories uploaded from this machine
- One line per entry: `- [Descriptive title](file.md) — one-line description`

**Update local MEMORY.md** to include any newly downloaded memories:
- Keep all existing entries
- Add new entries for pulled memories: `- [Descriptive title](file.md) — one-line description`
- Remove entries for any deleted/merged files

### Step 6: Relevance audit

After syncing is complete, audit **all local memories** (both pre-existing and newly synced) for relevance. The goal is to identify memories that are wasting context window space or actively harmful.

#### 6a. Read and evaluate every memory

For each memory file, check for these problems:

**Stale / outdated:**
- References files, functions, options, or packages that no longer exist in the repo (grep/glob to verify)
- Describes project state that has clearly changed (e.g., "we're migrating to X" when X is already done)
- Contains dates or deadlines that have passed (relative to today's date)
- References tools, services, or infrastructure that have been decommissioned

**Redundant / already in code:**
- Duplicates information that's in CLAUDE.md files
- Describes code patterns or architecture that can be derived by reading the code
- Restates git history or commit messages

**Too vague to be useful:**
- Generic advice that doesn't add context beyond common sense
- Memories with no actionable content ("user mentioned X once")

**Contradictory / poisonous:**
- Conflicts with current CLAUDE.md instructions
- Contains advice that was correct at the time but is now wrong due to code/tooling changes
- Recommends patterns or approaches that have since been explicitly rejected

#### 6b. Present removal suggestions

Group problematic memories by severity and present via AskUserQuestion:

**Recommend removal** (high confidence these are harmful or useless):
- List each with the specific reason (e.g., "references `foo.nix` which no longer exists", "contradicts CLAUDE.md rule about X")

**Consider removal** (potentially stale, user should decide):
- List each with what seems off and what would need to be true for it to still be relevant

**Suggest update** (core info is still valid but details are outdated):
- List each with what needs changing

Let the user select which to remove, update, or keep. Apply removals and updates to both local and remote (homie), and update both MEMORY.md indices.

### Step 7: Cleanup and report

Close the SSH control connection:
```bash
ssh -o ControlPath=/tmp/ssh-homie-sync-%r@%h -O exit homie 2>/dev/null
```

Print a summary:
- **Merged**: list pairs that were combined, with resulting filename
- **Uploaded to homie (global)**: list files
- **Uploaded to homie (host-specific)**: list files
- **Downloaded from homie**: list files with source (main or which host)
- **Conflict resolutions**: list files with which side won
- **Deletions propagated**: list files and direction
- **Skipped (not relevant)**: list files with brief reason
- **Already in sync**: count of files that needed no changes
- **Removed (stale/poisonous)**: list files with reasons
- **Updated**: list files with what changed
