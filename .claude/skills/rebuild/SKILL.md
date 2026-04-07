---
description: Rebuild and switch to new NixOS configuration
allowed-tools: Bash(nh:*), Bash(darwin-rebuild:*), Bash(sudo darwin-rebuild:*), Bash(uname:*), Bash(hostname:*), AskUserQuestion
---

## Your task

Rebuild the system by running the following steps:

### Step 0: Detect platform

Determine the config directory and platform:
```bash
CONFIG_DIR="${NIXOS_CONFIG_DIR:-/etc/nixos}"
```

Check if this is macOS or Linux:
```bash
uname -s
```

- **Linux**: use `nh os switch` commands (below)
- **Darwin/macOS**: use `darwin-rebuild` with `--flake $CONFIG_DIR` (see Darwin section)

---

### Linux (NixOS)

#### Step 1: Dry run to preview changes

Run:
```
nh os switch --dry --no-nom $CONFIG_DIR
```

Show the user a summary of what will change (new/updated/removed packages).

#### Step 2: Ask for confirmation

**Use AskUserQuestion** to ask the user if they want to proceed with the switch.

#### Step 3: Apply the rebuild

If confirmed, run:
```
nh os switch --no-nom $CONFIG_DIR
```

---

### Darwin (macOS)

#### Step 1: Dry build to preview changes

Run:
```
darwin-rebuild build --flake $CONFIG_DIR
```

Show the user a summary of what will change.

#### Step 2: Ask for confirmation

**Use AskUserQuestion** to ask the user if they want to proceed with the switch.

#### Step 3: Apply the rebuild

If confirmed, run:
```
sudo darwin-rebuild switch --flake $CONFIG_DIR
```
