---
description: Update NixOS flake inputs and switch to new configuration
allowed-tools: Bash(nh:*), Bash(git:*)
---

## Your task

Update NixOS by running the following steps:

### Step 1: Dry run to preview changes

Run:
```
nh os switch --dry --update --no-nom $NIXOS_CONFIG_DIR
```

Show the user a summary of what will change (new/updated/removed packages).

### Step 2: Ask for confirmation

Ask the user if they want to proceed with the switch.

### Step 3: Apply the update

If confirmed, run:
```
nh os switch --update --no-nom $NIXOS_CONFIG_DIR
```

### Step 4: Stage the lock file

If the switch was successful, stage the updated lock file:
```
git -C $NIXOS_CONFIG_DIR add flake.lock
```
