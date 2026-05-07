---
description: Craft a short, portable prompt to run in a fresh LLM session — different chat, different model, no shared history. Use whenever the user wants to develop, curate, write, or build a prompt to hand off elsewhere ("make a prompt for X", "craft a prompt", "something I can paste into ChatGPT/Gemini/Claude"). Trigger even if the user doesn't say "skill".
allowed-tools: AskUserQuestion, Read
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/prompt-craft/SKILL.md -->

## Task

Build a **standalone prompt** the user can paste into a fresh session. Keep it as short as the task allows — expand only when the goal genuinely needs it. The user will read and rewrite it.

The fresh session has none of this conversation. If you don't write it in, it doesn't exist.

## Step 1 — Ask, in one AskUserQuestion batch

1. **Target** (single): *agentic* (has tools, reads paths) vs *plain chat* (no tools, inline everything).
2. **Include** (multi): conversation recap · file paths · inlined file contents · speculative/hallucinated details · few-shot examples · output format · role.
3. **Goal in one sentence.**

## Step 2 — Confirm before adding

For every checked item, confirm the actual content. Do not fabricate.

- **Speculative details:** list each invented thing and ask per-item approval.
- **Files on plain-chat target:** paths alone are dead — push for inlined excerpts.
- **Recap / examples:** draft, let the user edit.

## Step 3 — Assemble

Plain-prose prompt with light markdown headings if structure helps. Goal first, then any context/examples, then the ask. Tell-not-don't. Explain *why* for non-obvious rules. Permit "I don't know" for fact tasks. Skip cargo-cult preambles. Match prompt style to desired output style. Avoid XML scaffolding — it makes prompts harder to read and rewrite.

## Step 4 — Deliver

Single fenced code block with the prompt. Below it, 2–3 lines: what's in, what's deliberately out, one thin spot if any. Nothing else.
