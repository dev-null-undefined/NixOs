---
description: Sync the NixOS config git repo with origin and homie — stash local changes, rebase-pull from both remotes, auto-resolve conflicts, restore changes, then suggest /commit + push
allowed-tools: Bash(git:*), Bash(timeout:*), Bash(nix:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- READ-ONLY: Managed by NixOS. Edit the source at:
     modules/generated/home-manager/cli/claude-code/skills/sync-config/SKILL.md -->

## Your task

Synchronize the NixOS config git repo with both remotes. The flow is:

1. **Stash** local (tracked) changes so the tree is clean.
2. **Rebase-pull** from `origin`, then from `homie`.
3. **Resolve conflicts autonomously** as they arise (rebase replay first, stash-pop second).
4. **Restore** the stashed changes.
5. **Report** and suggest the user run `/commit` then push.

The two remotes:

- `origin` → `git@github.com:dev-null-undefined/nixos` (GitHub, canonical upstream)
- `homie` → `martin@homie:/etc/nixos` (the homie machine, over SSH on the Tailnet)

Pull from **origin first, then homie**. Stashing happens *before* the pulls, popping *after* — so the rebase only reconciles committed history and the stash-pop only reconciles uncommitted working changes. These are two distinct conflict surfaces; handle both.

You commit nothing yourself — the final step hands off to `/commit`.

---

### Step 0: Setup & preflight

Resolve the repo path and current branch:

```bash
CONFIG_DIR="${NIXOS_CONFIG_DIR:-/etc/nixos}"
git -C "$CONFIG_DIR" symbolic-ref --short -q HEAD
```

- If that prints nothing, HEAD is **detached** — stop and tell the user to `git checkout` their branch (normally `master`) first. Use the printed branch as `$BRANCH` everywhere below.
- Refuse to stack on top of an in-progress operation. Check explicitly (more reliable than parsing `git status`):
  ```bash
  test -d "$(git -C "$CONFIG_DIR" rev-parse --git-path rebase-merge)" && echo REBASE
  test -d "$(git -C "$CONFIG_DIR" rev-parse --git-path rebase-apply)" && echo REBASE
  test -e "$(git -C "$CONFIG_DIR" rev-parse --git-path MERGE_HEAD)" && echo MERGE
  test -e "$(git -C "$CONFIG_DIR" rev-parse --git-path CHERRY_PICK_HEAD)" && echo CHERRY_PICK
  ```
  If any print, **stop** — let the user finish or abort that operation before re-running.

### Step 1: Stash local changes (tracked only)

Check for tracked, uncommitted changes (staged or unstaged), ignoring untracked files:

```bash
git -C "$CONFIG_DIR" status --porcelain --untracked-files=no
```

- **Empty output** → nothing to stash. Set `STASHED=0` and skip straight to Step 2 (do **not** create an empty stash).
- **Non-empty** → stash and confirm it took:
  ```bash
  git -C "$CONFIG_DIR" stash push -m "sync-config: WIP before remote sync"
  ```
  If that command **fails** (non-zero), stop and report — do not proceed with a tree that wasn't cleaned. On success set `STASHED=1`. This leaves untracked files (e.g. `.claude/scheduled_tasks.lock`) in place by design — tracked-only.

### Step 2: Rebase-pull from origin

Capture the pre-pull tip for the final report, then pull. Name the remote and branch **explicitly** — this skill pulls from two remotes, so never rely on the default upstream:

```bash
BEFORE_ORIGIN=$(git -C "$CONFIG_DIR" rev-parse HEAD)
git -C "$CONFIG_DIR" pull --rebase origin "$BRANCH"
```

Interpret the result with the **pull outcome rule** below: clean → go to Step 3; conflict → resolve per the policy and loop `git rebase --continue` until done; connection failure → that's unusual for origin, so report and stop.

### Step 3: Rebase-pull from homie

homie is on the Tailnet and is often offline. Probe first with a short timeout:

```bash
timeout 10 git -C "$CONFIG_DIR" ls-remote homie HEAD >/dev/null 2>&1
```

- **Unreachable** (non-zero) → **skip** this step; warn that the sync covered origin only. Continue to Step 4.
- **Reachable** → pull, bounded by a timeout so a mid-sync drop can't hang forever:
  ```bash
  BEFORE_HOMIE=$(git -C "$CONFIG_DIR" rev-parse HEAD)
  timeout 60 git -C "$CONFIG_DIR" pull --rebase homie "$BRANCH"
  ```
  Interpret with the **pull outcome rule**. A connection failure / timeout here is non-fatal: report "homie pull failed — skipped" and continue to Step 4.

#### Pull outcome rule

A non-zero `pull --rebase` exit is ambiguous — disambiguate by whether a rebase is now in progress:

```bash
test -d "$(git -C "$CONFIG_DIR" rev-parse --git-path rebase-merge)" && echo CONFLICT
```

- Prints `CONFLICT` → a real merge conflict; the rebase is paused. Resolve per the **Conflict resolution policy**.
- Prints nothing → the pull never started (remote unreachable, timed out, auth/SSH error). The tree is unchanged. For origin: stop and report. For homie: skip and continue.

If the pull aborts with **`untracked working tree files would be overwritten by ...`**, an incoming file collides with a local *untracked* file (commonly a new `.nix` module you created but never `git add`ed — see the flake/untracked gotcha). Inspect that file: if it's the change you intend, `git add` it (or move it aside), then retry the pull; otherwise escalate to the user.

### Step 4: Restore the stashed changes

Only if `STASHED=1`:

```bash
git -C "$CONFIG_DIR" stash pop
```

- Clean apply → the stash is auto-dropped; your working changes are back (unstaged). Done.
- Conflict → a stash-pop conflict does **not** auto-drop the stash. Resolve the conflicted files per the policy below (here the labels are *normal*: `HEAD` = freshly-pulled tree, incoming hunk = your stashed work), then mark them resolved and drop the now-applied stash:
  ```bash
  git -C "$CONFIG_DIR" add <resolved-files>
  git -C "$CONFIG_DIR" stash drop
  ```
  (Resolved files end up staged — that's fine, `/commit` handles staged and unstaged alike.)

> A stash-pop conflict is *not* a rebase. **Never** run `git rebase --continue` or `git checkout -- .` here — that would discard either the pulled history or your stashed work. Only edit, `git add`, `git stash drop`.

### Step 5: Report & next steps

Summarize using the captured SHAs:

- **origin**: `git -C "$CONFIG_DIR" log --oneline $BEFORE_ORIGIN..HEAD` (or "already up to date" if the tip is unchanged).
- **homie**: same with `$BEFORE_HOMIE`, or "skipped — unreachable / pull failed".
- **Conflicts resolved**: per file, which side won and why — and which were auto-resolved vs. escalated to you.
- **Stash restored**: yes / had conflicts (resolved) / nothing was stashed.

Then suggest the follow-ups (do **not** run them yourself — committing and pushing are the user's calls):

> Next: run `/commit` to commit the restored changes, then `! git push` to push to GitHub (`master` tracks `origin/master`).
> Optionally `! git push homie <branch>` to push back to homie too.

---

## Conflict resolution policy (Autonomous)

Resolve clear conflicts yourself; stop and ask only on genuinely ambiguous ones.

### ⚠️ Rebase reverses "ours" and "theirs"

During a **rebase**, your branch is replayed *on top of* the incoming commits, so the labels are flipped from a normal merge:

- `<<<<<<< HEAD` … `=======` = the **incoming** side (what you pulled from origin/homie).
- `=======` … `>>>>>>> <commit-sha>` = **your local commit** being replayed.

Read the commit subject after `>>>>>>>` to confirm which of *your* commits is in play. Do not assume HEAD is "yours" — in a rebase it is not. (In the Step-4 **stash pop**, the labels are normal: `HEAD` = the freshly-pulled tree, incoming hunk = your stashed work.)

### Tools for resolving

- See each side from the index: `git -C "$CONFIG_DIR" show :1:<file>` (merge base), `:2:<file>` (HEAD side), `:3:<file>` (other side).
- Take a whole side wholesale when correct: `git -C "$CONFIG_DIR" checkout --ours <file>` / `--theirs <file>` (apply the ours/theirs reversal note above when deciding which).
- Understand intent: `git -C "$CONFIG_DIR" log --oneline --all -- <file>` and `git -C "$CONFIG_DIR" show <commit-sha> -- <file>`.

### Auto-resolve (safe) when the intent is unambiguous

- **Non-overlapping additions** — both sides added different, independent lines in the same region. Keep **both** (union). Extremely common in this repo: two new `inherit (super.stable) …` entries, two new list items, two `home.file.".claude/skills/…"` lines, two module `enable`s. Preserve alphabetical/existing ordering where the file has it.
- **One side unchanged** — if one side equals the merge base (no real change) and the other modifies it, take the modifying side.
- **Pure formatting/whitespace** — keep the functional content; if a `.nix` file's formatting drifts, run `nix fmt` afterward.

After resolving each file: `git -C "$CONFIG_DIR" add <file>`.

#### Rebase continue loop

When every conflict in the current step is staged: `git -C "$CONFIG_DIR" rebase --continue`. Then re-check with the **pull outcome rule**'s `rebase-merge` test:

- still in progress → the rebase paused on a *later* commit; resolve that one and continue again. Use `git -C "$CONFIG_DIR" status` (and `git rebase --show-current-patch` if helpful) to see which commit and files are in play, and report progress as you go.
- not in progress → the rebase finished cleanly; move on.

If your own resolution introduced a fresh conflict or a broken file, fix and continue; if you cannot resolve a step after a couple of honest attempts, use the escape hatch rather than thrashing.

### Stop and ask (AskUserQuestion) when intent is unclear

Never silently discard a side's work in these cases — present a diff and offer **Keep incoming / Keep local (mine) / Merged draft (you write it)**:

- Both sides changed the **same line or value** to different content (e.g. the same option set to different values).
- **Delete vs. modify** — one side removed a file or block the other edited.
- **`flake.lock`** — a conflict means both machines ran `nix flake update`. Don't hand-merge JSON. Offer: keep one side's lock (`git checkout --ours`/`--theirs flake.lock` — mind the rebase reversal), then optionally `nix flake lock` to re-reconcile on the next rebuild. Flag input pins explicitly.
- **`secrets/` or sops-encrypted files** — never auto-merge ciphertext; always escalate.
- Anything where union-merging would change behavior rather than just combine independent additions.

### Escape hatches

- **Stuck mid-rebase / user rejects every option** → `git -C "$CONFIG_DIR" rebase --abort` restores the pre-pull state. **Then always**, if `STASHED=1`, `git -C "$CONFIG_DIR" stash pop` to put your working changes back — an abort does *not* touch the stash. Report that the sync was aborted and nothing was changed. (Note: if origin already rebased successfully and the abort happens during the *homie* pull, only the homie step is undone — origin's pulled commits remain.)
- **Stuck on stash-pop** → do not abort; the pulled history is already committed. Present the conflicted files to the user and resolve interactively. The stash stays in `git stash list` until you `git stash drop` it, so nothing is lost.
