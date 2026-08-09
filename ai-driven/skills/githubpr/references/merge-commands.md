# Merge Commands

The merge method depends on whether the target is a **feature branch** (deleted after merge) or a **long-lived integration branch** (`dev`, `main`).

## A. Feature branch → `dev` (or `main` if no `dev` exists)

Use the GitHub UI / `gh` CLI with **rebase and merge**. The feature branch is deleted after, so commit-hash rewriting is harmless.

```bash
gh pr merge <PR_NUMBER> --rebase --delete-branch
```

## B. `dev` → `main` (long-lived branch → long-lived branch)

**NEVER use the GitHub merge button** (`--rebase`, `--squash`, or `--merge`).
All three rewrite commit hashes, which breaks `dev`: it is no longer an
ancestor of `main`, causing conflicts and requiring force-pushes on the
next `dev → main` cycle.

Instead, merge in CLI with a **true fast-forward**:

```bash
git fetch origin main dev
git checkout main
git pull --ff-only origin main
git merge --ff-only dev
git push origin main
```

This advances `main` to `dev`'s commit **without rewriting hashes**.
`dev` remains an exact ancestor of `main` → zero conflicts, zero
force-push, on every subsequent cycle.

> The PR `dev → main` is created for CI + review, but **merged via CLI**.
> Once `main` is pushed, the PR closes automatically. Do not
> `--delete-branch` — `dev` is long-lived.

If `dev` is not a strict ancestor of `main` (someone committed directly
to `main`), `--ff-only` will refuse. Fix by rebasing `dev` onto `main`
first, then retry the fast-forward.

After merge, both branches point to the same commit — no resync needed.