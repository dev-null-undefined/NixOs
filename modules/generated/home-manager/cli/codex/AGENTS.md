<!-- This file is NixOS-managed via home-manager. Source: modules/generated/home-manager/cli/codex/AGENTS.md -->
<!-- Deployed to ~/.codex/AGENTS.md — do NOT edit the deployed copy directly -->

## General Rules

Never make autonomous changes beyond what was explicitly requested. Do not move, remove, or refactor code that wasn't part of the ask. If you think something should change, ask first.

## Git Operations

When making git commits, always verify the staging area first with `git status` and `git diff --cached` to ensure only intended files are included. Never include previously staged files accidentally.

## Code Review Workflow

For code review sessions: present the review, wait for user to select which fixes to apply, then apply only those. After fixing, squash fixes into original commits using interactive rebase.

## System Context

- NixOS with flakes, sops-nix for secrets
- Filesystem: btrfs
- GPUs: NVIDIA + AMD, Hyprland compositor
- Always check for existing module definitions before adding new ones to avoid conflicts
