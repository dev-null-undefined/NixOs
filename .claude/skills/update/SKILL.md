---
description: Smart NixOS update with automatic package pinning and unpinning
allowed-tools: Bash(nh:*), Bash(darwin-rebuild:*), Bash(sudo darwin-rebuild:*), Bash(nix:*), Bash(git:*), Bash(alejandra:*), Bash(python3:*), Bash(uname:*), Bash(hostname:*), Read, Edit, AskUserQuestion
---

## Your task

Perform a smart flake update that automatically handles broken packages by pinning them to the stable channel, and afterwards attempts to unpin packages that are no longer broken on unstable.

### Step 0: Detect platform

Determine the config directory and platform:
```bash
CONFIG_DIR="${NIXOS_CONFIG_DIR:-/etc/nixos}"
```

Check if this is macOS or Linux:
```bash
uname -s
```

- **Linux**: use `nh os switch --no-nom $CONFIG_DIR` as the rebuild command throughout
- **Darwin/macOS**: use `darwin-rebuild switch --flake $CONFIG_DIR` as the rebuild command throughout

Use the appropriate rebuild command wherever this document says "rebuild command".

---

The overlay file is at `$CONFIG_DIR/overlays/default.nix`. The `stable-pkgs` overlay has this structure:

```nix
stable-pkgs = super: final: {
  inherit
    (super.stable)
    package1
    package2
    ...
    ;
  inherit (super.dev-null) ...;  # DO NOT TOUCH
};
```

Only modify packages in the `inherit (super.stable) ...;` block. Never touch `inherit (super.dev-null)`, `master-pkgs`, or any other overlay.

---

### Phase 1: Update flake inputs and attempt build

1. Update flake inputs, **excluding any inputs whose URL contains `git.cdn77.eu`** (these are private work inputs that should be updated separately).

   First, identify which top-level inputs to update (excluding cdn77 ones):
   ```bash
   nix flake metadata --json $CONFIG_DIR | python3 -c "
   import json, sys
   meta = json.load(sys.stdin)
   locks = meta['locks']
   root_inputs = locks['nodes'][locks['root']]['inputs']
   to_update = []
   for name, target in root_inputs.items():
       node_name = target if isinstance(target, str) else target[-1]
       node = locks['nodes'].get(node_name, {})
       locked = node.get('locked', {}) or node.get('original', {})
       url = locked.get('url', '')
       if 'git.cdn77.eu' not in url:
           to_update.append(name)
   print(' '.join(sorted(to_update)))
   "
   ```

   Then update only those inputs by passing them as positional arguments:
   ```bash
   nix flake update --flake $CONFIG_DIR <input1> <input2> ...
   ```
   If no inputs need to be skipped, you can simply run `nix flake update --flake $CONFIG_DIR` with no arguments.
2. Attempt a dry build first using `nix build $CONFIG_DIR#nixosConfigurations.$(hostname).config.system.build.toplevel --print-out-paths` to check for errors without switching. Capture the output path.
3. If the dry build succeeds, show the user which main packages were updated by running:
   ```bash
   nix store diff-closures /run/current-system <built-path>
   ```
   This prints lines like `package-name: 1.0 → 1.1, +2.3 MiB`. After showing the full output, summarize highlights for the user:
   - **Major version bumps** (e.g., 1.x → 2.x) — call these out explicitly as they may have breaking changes
   - **Notable packages** — flag updates to kernel, mesa, systemd, glibc, firefox, chromium, python, node, rust, go, gcc, and desktop environments (gnome, plasma, hyprland)
   - **New or removed packages** in the closure
4. **Use AskUserQuestion to ask the user for confirmation before switching.** Then run the rebuild command to activate.
5. If the dry build fails, capture the full error output and proceed to Phase 2. After fixing issues in Phase 2, run the diff-closures step above before the final confirmation and switch.

---

### Phase 2: Identify and pin broken packages

When the build fails, you need to identify which package(s) are broken and pin them to stable.

#### How to identify broken packages from error output

Look for these patterns in the error output (check all of them):

1. **Build failure**: `error: builder for '/nix/store/...-PACKAGENAME-VERSION.drv' failed`
   - Extract PACKAGENAME from the derivation path (the part between the hash-dash and the version)
2. **Marked broken**: `error: Package 'PACKAGENAME-VERSION' ... is marked as broken`
3. **Removed package**: `error: Package 'PACKAGENAME' ... has been removed`
4. **Evaluation error**: `error: attribute 'PACKAGENAME' missing`
5. **Insecure**: `error: Package 'PACKAGENAME' ... is marked as insecure`
6. **Failed dependency**: If the error says a derivation failed and the build log references a dependency, the broken package might be the dependency, not the top-level package. Look at `nix log /nix/store/...drv` output for clues.

**Important**: The package name in the nix store derivation path (e.g., `/nix/store/abc123-firefox-130.0.drv`) uses the format `HASH-NAME-VERSION.drv`. Extract just the name part. Package names can contain hyphens (e.g., `bitwarden-desktop`, `gimp-with-plugins`, `bat-extras`), so split on the last sequence of hyphen-followed-by-a-digit to separate name from version.

#### How to determine if a broken package is pinnable

Before pinning, verify the package exists in nixpkgs-stable:
```bash
nix eval --inputs-from $CONFIG_DIR 'nixpkgs-stable#PACKAGENAME.name' 2>&1
```
If this succeeds, the package can be pinned to stable.

If the package does not exist in stable either, report it to the user and stop — this is not a problem auto-pinning can solve.

#### How to pin a package

1. Read the current `$CONFIG_DIR/overlays/default.nix`
2. Add the broken package name to the `inherit (super.stable)` block using the Edit tool. Maintain alphabetical order within the existing list.
3. Format the file: `alejandra $CONFIG_DIR/overlays/default.nix`
4. Retry the build using the rebuild command
5. If it fails again with a **different** package, repeat from the identification step
6. If it fails again with the **same** package or a non-package error, report to the user and stop

Keep a running list of all packages you auto-pinned in this session.

**Maximum retry limit**: Do not retry more than 10 times. If you've pinned 10 packages and it still fails, stop and report.

#### Recognizing non-pinnable errors

Do NOT attempt to pin packages when the error is clearly not a package build issue. Stop and report these to the user:
- `error: The option .* does not exist`
- `error: syntax error`
- `error: infinite recursion`
- `error: while evaluating the module argument`
- Errors referencing local config files (hosts/, modules/, home/)

---

### Phase 3: Attempt to unpin stable packages

After a successful build (from Phase 1 or Phase 2), attempt to unpin packages from the stable channel.

Run the test script to check all stable-pinned packages against unstable in parallel:

```bash
python3 $CONFIG_DIR/scripts/test-overlay-packages.py --json --jobs 4
```

This outputs JSON with three lists: `can_unpin`, `must_keep`, `timed_out`.

If there are packages in `can_unpin`:

1. Read the current `$CONFIG_DIR/overlays/default.nix`
2. Remove the unpin-candidate package names from the `inherit (super.stable) ...;` block using the Edit tool
3. Format: `alejandra $CONFIG_DIR/overlays/default.nix`
4. Rebuild the system to verify using the rebuild command
5. If the rebuild fails, identify which unpinned package caused the failure from the error output, re-pin it (add it back), format with `alejandra`, and retry. Repeat until the build succeeds.

If `can_unpin` is empty, skip this phase — all packages still need stable.

---

### Phase 4: Build other hosts (homie only)

If the current hostname is `homie`, build configurations for the other main machines so they are cached in the nix store (and served by Harmonia to the network automatically).

1. Check the hostname:
   ```bash
   hostname
   ```

2. If the hostname is `homie`, build these host configurations (run all three in parallel if possible):
   ```bash
   nix build $CONFIG_DIR#nixosConfigurations.x1.config.system.build.toplevel --no-link
   nix build $CONFIG_DIR#nixosConfigurations.xps.config.system.build.toplevel --no-link
   nix build $CONFIG_DIR#nixosConfigurations.honey.config.system.build.toplevel --no-link
   ```

3. If any host build fails, investigate and fix the issue before proceeding. These builds are **blocking** — all hosts must build successfully. Apply the same error analysis techniques from Phase 2 (check error output, identify broken packages, pin if needed). If the error is not package-related (e.g., missing flake input dependency, overlay mismatch), fix the root cause directly. After fixing, re-run all failed host builds to confirm they pass.

If the hostname is NOT `homie`, skip this phase entirely.

---

### Phase 5: Finalize

1. Stage all changed files (flake.lock, overlays, and any config files modified during the update):
   ```bash
   git -C $CONFIG_DIR add flake.lock overlays/default.nix
   ```
   Also stage any other files that were modified to fix build issues (e.g., module renames, overlay changes).

2. Report a summary to the user:
   - Which flake inputs were updated
   - Packages auto-pinned to stable in this session (if any)
   - Packages unpinned from stable (if any)
   - Packages that remain pinned to stable
   - Final build status
