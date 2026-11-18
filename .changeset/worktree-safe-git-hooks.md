---
openbudget: chore
---

# Make git hooks work across linked worktrees

`devenv` now installs the prek hook shims with a config path relative to the
repository toplevel instead of an absolute path into whichever worktree
entered the shell last. Commits in any worktree run that worktree's own
`.pre-commit-config.yaml` and hook tools, and deleting one worktree no longer
breaks the hooks of the others. The commit-time analyze gate now runs the
exact command CI's `analyze` job uses.
