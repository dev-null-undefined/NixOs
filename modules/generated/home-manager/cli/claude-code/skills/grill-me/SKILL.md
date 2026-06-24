---
description: Interview the user relentlessly about every aspect of a plan or design, walking down each branch of the design tree and resolving dependencies between decisions one-by-one, recommending an answer for each question. Use when the user wants to be grilled / interviewed / pressure-tested on a plan or design before implementing.
allowed-tools: AskUserQuestion, Read, Grep, Glob, Bash, WebSearch, WebFetch
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/grill-me/SKILL.md -->

## Task

Interview the user relentlessly about every aspect of this plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions **one at a time**.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

> Note: when a question hinges on external facts (APIs, library behaviour, current best practice), do a quick online search to verify before recommending.
