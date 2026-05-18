---
name: gh-repo-bootstrap
description: Recipe for /git-push to initialize a git repo and create a private GitHub repo when none exists. Handles gh auth precheck, repo name from cwd basename, name collision fallback, and the private-by-default rule.
---

# GitHub Repo Bootstrap

## Precheck

```bash
gh auth status 2>&1 | head -1
```

If output contains `not logged in` → abort and tell the user to run `gh auth login`. Do not attempt to create a repo without auth.

## Step-by-step

```bash
# 1. determine repo name
REPO_NAME=$(basename "$(pwd)")

# 2. init local repo if needed
if [ ! -d .git ]; then
  git init
  git branch -M main
fi

# 3. ensure something to commit
if [ -z "$(git status --porcelain)" ] && [ -z "$(git log -1 2>/dev/null)" ]; then
  echo "Nothing to commit. Aborting." >&2
  exit 1
fi

# 4. stage and commit if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "Initial commit"
fi

# 5. check if origin already exists
if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin main
else
  # 6. create private repo on GitHub and push
  gh repo create "$REPO_NAME" --private --source=. --remote=origin --push
fi

# 7. print URL
gh repo view --json url --jq .url
```

## Name collision handling

Before `gh repo create`, check existence:

```bash
GH_USER=$(gh api user --jq .login)
if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  REPO_NAME="${REPO_NAME}-$(date +%Y%m%d)"
fi
```

If still colliding, ask user for a manual name. Don't silently overwrite.

## Hard rules

- **Private by default.** Never pass `--public` unless user explicitly typed it after `/git-push`.
- **Never `git push --force`** in this command.
- **Never delete the local `.git`** even if creation fails.
- **Always the basename of cwd** as initial repo name suggestion. Never use a parent path.
- **Refuse to push if `.env` is staged** — security-reviewer should catch this earlier, but double-check here:
  ```bash
  if git diff --cached --name-only | grep -E '^\.env$|/\.env$|^\.env\.[^.]+$' | grep -v '\.env\.example'; then
    echo "Refusing to push: .env files are staged" >&2
    exit 1
  fi
  ```

## After success

Print:
- repo URL (clickable)
- branch pushed
- next-step suggestion (e.g., "to add a deploy: `/decide-stack` again or edit `specs/60-devops.md`")
