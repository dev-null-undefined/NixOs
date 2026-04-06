---
description: Sync Claude memories between current machine and homie via SSH
allowed-tools: Bash(ssh:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(hostname:*), Bash(scp:*), Read, Write, Glob, Grep
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-memory/SKILL.md -->

## Your task

Synchronize Claude Code memories between this machine and homie. Memories are merged bidirectionally — local memories are uploaded to homie, and relevant remote memories are downloaded here.

### Directory structure

Memories live in `~/.claude/projects/-etc-nixos/memory/`. On homie, host-specific memories from other machines are stored separately:

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

Determine the local hostname:
```bash
hostname
```

Define paths:
- **Local memory dir**: `~/.claude/projects/-etc-nixos/memory/`
- **Remote memory dir**: `~/.claude/projects/-etc-nixos/memory/` (on homie via SSH)
- **Remote host-specific dir**: `~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>/` (on homie)

Read all local memory files (MEMORY.md + all .md files):
```bash
ls ~/.claude/projects/-etc-nixos/memory/*.md
```
Then read each file's content.

Read all remote memory files on homie:
```bash
ssh homie "ls ~/.claude/projects/-etc-nixos/memory/*.md 2>/dev/null"
ssh homie "ls -d ~/.claude/projects/-etc-nixos/memory/hosts/*/ 2>/dev/null"
```
For each remote host directory found, also read its MEMORY.md and files.

Read the content of each remote memory file (excluding MEMORY.md indices) to understand what's already stored.

### Step 2: Analyze and classify local memories

For each local memory file (excluding MEMORY.md), determine if it already exists on homie (by filename match in either the main dir or `hosts/<local-hostname>/` dir).

For memories that are **new or updated locally**, classify each as:

**Global** — relevant to all machines working on this NixOS config:
- User preferences, role, workflow habits (type: user, feedback)
- Project-wide decisions, architecture notes, conventions (type: project)
- External references (type: reference)
- Feedback about Claude behavior, code style, commit style

**Host-specific** — relevant only to the originating machine:
- Hardware-specific details (GPU, disk, peripherals)
- Services running only on this host
- Local network config or IP addresses specific to this machine
- Machine-specific debugging history

### Step 3: Upload to homie

For each new/updated local memory:

**If global**, upload to homie's main memory directory:
```bash
scp ~/.claude/projects/-etc-nixos/memory/<file>.md homie:~/.claude/projects/-etc-nixos/memory/<file>.md
```

**If host-specific**, upload to the host-specific subdirectory:
```bash
ssh homie "mkdir -p ~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>"
scp ~/.claude/projects/-etc-nixos/memory/<file>.md homie:~/.claude/projects/-etc-nixos/memory/hosts/<local-hostname>/<file>.md
```

### Step 4: Pull relevant memories from homie

For each memory on homie (both main dir and all `hosts/<other-hostname>/` dirs) that does NOT exist locally:

1. Read its content
2. Decide if it's relevant to this machine:
   - **Always pull**: user preferences, feedback about Claude behavior, workflow habits, project-wide decisions, external references
   - **Pull if relevant**: monitoring/infra knowledge that applies here too, security guidelines, naming conventions
   - **Skip**: host-specific hardware details for another machine, services not running here, debugging history for other hosts
3. If pulling, download to the local memory directory:
```bash
scp homie:~/.claude/projects/-etc-nixos/memory/<file>.md ~/.claude/projects/-etc-nixos/memory/<file>.md
```
   Or from a host-specific dir:
```bash
scp homie:~/.claude/projects/-etc-nixos/memory/hosts/<other-host>/<file>.md ~/.claude/projects/-etc-nixos/memory/<file>.md
```

For memories that exist on both sides, compare content. If the remote version is newer or has more information, pull it (overwriting local). If the local version is newer, it was already pushed in Step 3.

### Step 5: Update indices

**Update homie's main MEMORY.md** to include any newly uploaded global memories. SSH in and rewrite it:
- Keep all existing entries
- Add new entries for uploaded global memories
- Do NOT add host-specific memories to the main index

**Update/create homie's host-specific MEMORY.md** at `hosts/<local-hostname>/MEMORY.md`:
- List all host-specific memories uploaded from this machine
- One line per entry: `- [Title](file.md) — one-line description`

**Update local MEMORY.md** to include any newly downloaded memories:
- Keep all existing entries
- Add new entries for pulled memories

Index format for all MEMORY.md files:
```markdown
# Memory Index

- [filename.md](filename.md) — short description
```

### Step 6: Report

Print a summary:
- **Uploaded to homie (global)**: list files
- **Uploaded to homie (host-specific)**: list files
- **Downloaded from homie**: list files with source (main or which host)
- **Skipped (not relevant)**: list files with brief reason
- **Already in sync**: count of files that needed no changes
