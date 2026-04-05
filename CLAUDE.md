# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Multi-host NixOS configuration flake managing 10+ machines (desktops, laptops, servers, WSL instances, installers). Uses a custom module generator as the central abstraction.

## Key Commands

```bash
# Rebuild current system
sudo nixos-rebuild switch

# Update all flake inputs
nix flake update

# Update a single input
nix flake lock --update-input <input>

# Remote deployment (via deploy-rs)
# deploy-rs nodes are auto-generated from hosts/ directory

# Format nix files (formatter is alejandra)
nix fmt
```

## Architecture

### Module Generator (`modules/generated/generator.nix`)

The heart of the config. Automatically generates NixOS module options from file/folder structure:

- Each `.nix` file under `modules/generated/nixos/` gets a `generated.<path>.enable` option
- Each `.nix` file under `modules/generated/home-manager/` gets a `generated.home.<path>.enable` option
- Enabling a **folder** enables all children recursively, **unless** `default.nix` exists in the folder — then only `default.nix` is enabled
- When `default.nix` exists, a virtual `.all.enable` option is generated to override and enable everything in that folder
- Files prefixed with `_` are ignored everywhere in the path
- Module files can export an `options` attribute to add custom sub-options alongside `enable`

To add a new module: create a `.nix` file in the appropriate `modules/generated/{nixos,home-manager}/` subdirectory. The generator auto-discovers it — no imports needed.

### Host Configuration

- `hosts/{hostname}/default.nix` — main NixOS config; enables generated modules here
- `hosts/{hostname}/hardware-configuration.nix` — hardware config (from `nixos-generate-config`)
- `hosts/{hostname}/overrides.nix` — optional; overrides for mkHost (e.g. `{system = "aarch64-linux";}`)
- `hosts/shared/` — configs included in all hosts
- Hosts are auto-detected from `hosts/` directory names (excluding `shared/`)

### Home-Manager Integration

Two modes: standalone (`home-manager switch --flake .#user@host`) and as NixOS module (via `lib'.internal.mkHomeNixOsUser`).

File loading order:
1. `home/default.nix` — all users, always
2. `home/{username}/default.nix` — per-user, always
3. `home/{username}/nixos.nix` — only as NixOS module
4. `home/{username}/{hostname}.nix` — host-specific
5. `home/nixosDefaults.nix` — only as NixOS module

Users are auto-detected from `home/` directory names.

### Lib (`lib/`)

- `mkHost` — generates a full NixOS configuration for a host (imports host files, modules, overlays)
- `mkHomeNixOsUser` — generates home-manager user config when integrated as NixOS module
- `mkOverlay` — creates an overlay from a `nixpkgs-{name}` input
- `mkPkgsWithOverlays` — applies all overlays to nixpkgs for a given system

### Overlays (`overlays/default.nix`)

Pins specific packages from alternate channels when the primary `nixpkgs` (unstable) has broken or outdated versions. The overlay system uses `mkOverlay` to make each channel's packages available as `pkgs.stable`, `pkgs.master`, etc.

**How it works:**
- `stable-pkgs` overlay: `inherit (super.stable) package-name;` — replaces `pkgs.package-name` with the version from `nixpkgs-stable`
- `master-pkgs` overlay: `inherit (super.master) package-name;` — replaces with `nixpkgs-master` version
- Adding a package name to an overlay section transparently overrides it system-wide — no per-host changes needed

**When to pin a package to a different channel:**
- Package is broken/missing on unstable → pin to `stable` or `master`
- Package needs a newer version than unstable has → pin to `master`
- Package needs custom patches → pin to `dev-null` (fork)

### Secrets

Uses SOPS with age encryption (`.sops.yaml`). Encrypted files in `secrets/`. Keys are per-host.

### Custom Packages (`pkgs/`)

Small set of custom package derivations (plymouth theme, material-symbols, prometheus exporter).

## Nixpkgs Channels

- `nixpkgs` (primary): unstable
- `nixpkgs-stable`: 25.11
- `nixpkgs-master`: master branch
- `nixpkgs-dev-null`: fork with custom patches

## Environment & Shell Helpers

The repo is typically cloned in the user's home directory; `/etc/nixos` is a symlink to it.

Shell environment variables (set via zsh in `modules/generated/home-manager/shells/zsh/_extra/nix-functions.nix`):
- `$NIXOS_CONFIG_DIR` — resolved real path of `/etc/nixos` (the flake root)
- `$NIXOS_CURRENT_CONFIG` — nix store path of the flake source used to build the currently running system (useful for diffing running vs local config)

Key shell functions (available in zsh):
- `nix-rebuild` — `sudo nixos-rebuild switch` with nom (fancy build output) fallback
- `nix-update` — `nix flake update` + rebuild + auto-stage `flake.lock`
- `nix-rebuild-boot` — rebuild for next boot only
- `nix-eval <attr>` — evaluate a NixOS config attribute for the current host
- `home-rebuild` — build and switch home-manager config
- `home-eval <attr>` — evaluate a home-manager config attribute
- `nix-pkg <pkg> [-- cmd]` — `nix shell` with flake package, optional command
- `nix-find <pkg>` / `nix-path <pkg>` — print store path of a flake package
- `ngrep <pattern>` — grep the nixos config directory

## Networking

Nearly all machines run Tailscale and are connected via a Tailnet. Tailscale has firewall passthrough, so when connecting between machines (SSH, web UIs, etc.), prefer using Tailscale addresses — no firewall rules to worry about.

## Conventions

- Host-specific logic goes in `hosts/{hostname}/default.nix`; reusable logic goes in `modules/generated/`
- Generated module files return an attrset (or a function returning one) with the NixOS/home-manager config that gets wrapped in `mkIf <option>.enable`
- Formatter is `alejandra` (not `nixpkgs-fmt`)
