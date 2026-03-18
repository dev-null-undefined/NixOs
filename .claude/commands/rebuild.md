---
description: Rebuild and switch to new NixOS configuration
allowed-tools: Bash(nh:*)
---

## Your task

Rebuild NixOS by running the following steps:

### Step 1: Dry run to preview changes

Run:
```
nh os switch --dry --no-nom $NIXOS_CONFIG_DIR
```

Show the user a summary of what will change (new/updated/removed packages).

### Step 2: Ask for confirmation

Ask the user if they want to proceed with the switch.

### Step 3: Apply the rebuild

If confirmed, run:
```
nh os switch --no-nom $NIXOS_CONFIG_DIR
```
