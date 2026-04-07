---
description: Sync Claude memories between current machine and homie via SSH
allowed-tools: Bash(ssh:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(hostname:*), Bash(scp:*), Read, Write, Glob, Grep, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-memory/SKILL.md -->

## Your task

Synchronize Claude Code memories between this machine and homie. Memories are merged bidirectionally — local memories are uploaded to homie, and relevant remote memories are downloaded here.

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

Read all local memory files (every `.md` in the memory directory) and all remote memory files on homie:

```bash
# Local
ls <local-memory-dir>/*.md

# Remote (main dir + host subdirectories)
ssh homie "ls ~/.claude/projects/-etc-nixos/memory/*.md 2>/dev/null"
ssh homie "ls -d ~/.claude/projects/-etc-nixos/memory/hosts/*/ 2>/dev/null"
```

Read the **full content** of every memory file on both sides (excluding MEMORY.md indices). You need the content for duplicate detection and conflict resolution.

### Step 2: Detect duplicates and conflicts

Before syncing anything, analyze all memories from both sides together. Build a unified view:

#### 2a. Exact filename matches (conflicts)

Files with the **same filename** on both sides — compare content:
- **Identical content**: already in sync, no action needed
- **Different content**: this is a conflict — present both versions to the user (see Step 3)

#### 2b. Semantic duplicates (different filenames, same topic)

Scan for memories that cover the **same topic** but have different filenames. Common patterns:
- Same `name` or `description` in frontmatter
- Same core advice/rule with different wording or examples
- One is a subset of the other (e.g., a short version vs a detailed version)

For each potential duplicate pair found, flag it for user review (see Step 3).

#### 2c. Classify new memories

For memories that exist on only one side and have no duplicates, classify as:

**Global** — relevant to all machines working on this NixOS config:
- User preferences, role, workflow habits (type: user, feedback)
- Project-wide decisions, architecture notes, conventions (type: project)
- External references (type: reference)
- Feedback about Claude behavior, code style, commit style

**Host-specific** — relevant only to the originating machine:
- Hardware-specific details (GPU model, disk layout, peripherals)
- Services running only on this host
- Local network config or IP addresses specific to this machine
- Machine-specific debugging history

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

#### 3c. New memories (no conflicts or duplicates)

Present the list of new memories to sync in each direction, grouped by classification:

- **Will upload to homie (global)**: list with one-line descriptions
- **Will upload to homie (host-specific)**: list with one-line descriptions
- **Will download from homie**: list with one-line descriptions
- **Will skip (not relevant to this machine)**: list with reasons

Ask user to confirm, or let them override any classification.

### Step 4: Execute sync

Only after user approval, execute the sync plan:

#### 4a. Upload to homie

**Global memories** — upload to homie's main memory directory:
```bash
scp <local-memory-dir>/<file>.md homie:~/.claude/projects/-etc-nixos/memory/<file>.md
```

**Host-specific memories** — upload to the host-specific subdirectory:
```bash
ssh homie "mkdir -p ~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>"
scp <local-memory-dir>/<file>.md homie:~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>/<file>.md
```

#### 4b. Download from homie

```bash
scp homie:~/.claude/projects/-etc-nixos/memory/<file>.md <local-memory-dir>/<file>.md
```

Or from a host-specific dir:
```bash
scp homie:~/.claude/projects/-etc-nixos/memory/hosts/<other-host>/<file>.md <local-memory-dir>/<file>.md
```

#### 4c. Apply merges

For any memories the user chose to merge:
1. Write the merged content to the surviving filename on the local side
2. Upload to homie
3. Delete the retired filename from both sides:
```bash
rm <local-memory-dir>/<retired-file>.md
ssh homie "rm ~/.claude/projects/-etc-nixos/memory/<retired-file>.md 2>/dev/null"
```

#### 4d. Apply conflict resolutions

Overwrite the losing side with the winning version.

### Step 5: Update indices

**Update homie's main MEMORY.md** to include any newly uploaded global memories:
- Keep all existing entries
- Add new entries for uploaded global memories
- Remove entries for any deleted/merged files
- Do NOT add host-specific memories to the main index

**Update/create homie's host-specific MEMORY.md** at `hosts/<local-hostname>/MEMORY.md`:
- List all host-specific memories uploaded from this machine
- One line per entry: `- [Title](file.md) — one-line description`

**Update local MEMORY.md** to include any newly downloaded memories:
- Keep all existing entries
- Add new entries for pulled memories
- Remove entries for any deleted/merged files

Index format for all MEMORY.md files:
```markdown
# Memory Index

- [filename.md](filename.md) — short description
```

### Step 6: Cleanup and report

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
- **Skipped (not relevant)**: list files with brief reason
- **Already in sync**: count of files that needed no changes
