---
description: Smart NixOS update with automatic package pinning and unpinning
allowed-tools: Bash(nh:*), Bash(nix:*), Bash(git:*), Bash(alejandra:*), Bash(python3:*), Read, Edit
---

## Your task

Perform a smart NixOS flake update that automatically handles broken packages by pinning them to the stable channel, and afterwards attempts to unpin packages that are no longer broken on unstable.

The overlay file is at `$NIXOS_CONFIG_DIR/overlays/default.nix`. The `stable-pkgs` overlay has this structure:

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

1. Run `nix flake update --flake $NIXOS_CONFIG_DIR`
2. Attempt the build: `nh os switch --no-nom $NIXOS_CONFIG_DIR`
3. If it succeeds, skip to Phase 3.
4. If it fails, capture the full error output and proceed to Phase 2.

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
nix eval --inputs-from $NIXOS_CONFIG_DIR 'nixpkgs-stable#PACKAGENAME.name' 2>&1
```
If this succeeds, the package can be pinned to stable.

If the package does not exist in stable either, report it to the user and stop — this is not a problem auto-pinning can solve.

#### How to pin a package

1. Read the current `$NIXOS_CONFIG_DIR/overlays/default.nix`
2. Add the broken package name to the `inherit (super.stable)` block using the Edit tool. Maintain alphabetical order within the existing list.
3. Format the file: `alejandra $NIXOS_CONFIG_DIR/overlays/default.nix`
4. Retry the build: `nh os switch --no-nom $NIXOS_CONFIG_DIR`
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
python3 $NIXOS_CONFIG_DIR/scripts/test-overlay-packages.py --json --jobs 4
```

This outputs JSON with three lists: `can_unpin`, `must_keep`, `timed_out`.

If there are packages in `can_unpin`:

1. Read the current `$NIXOS_CONFIG_DIR/overlays/default.nix`
2. Remove the unpin-candidate package names from the `inherit (super.stable) ...;` block using the Edit tool
3. Format: `alejandra $NIXOS_CONFIG_DIR/overlays/default.nix`
4. Rebuild the system to verify: `nh os switch --no-nom $NIXOS_CONFIG_DIR`
5. If the rebuild fails, identify which unpinned package caused the failure from the error output, re-pin it (add it back), format with `alejandra`, and retry. Repeat until the build succeeds.

If `can_unpin` is empty, skip this phase — all packages still need stable.

---

### Phase 4: Finalize

1. Stage changed files:
   ```bash
   git -C $NIXOS_CONFIG_DIR add flake.lock overlays/default.nix
   ```

2. Report a summary to the user:
   - Which flake inputs were updated
   - Packages auto-pinned to stable in this session (if any)
   - Packages unpinned from stable (if any)
   - Packages that remain pinned to stable
   - Final build status
