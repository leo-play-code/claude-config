---
description: Push the current feature/fix branch to GitHub and open a PR. Alternative to /git-push for non-main work. Auto-generates title and body from recent commits.
argument-hint: [--draft] [--title "..."] [--body "..."]
---

Push the current branch to GitHub and open a PR. Talk to Leo in **Traditional Chinese**; PR title/body in English.

## Args

$ARGUMENTS

Optional:
- `--draft` — open as draft PR
- `--title "..."` — override auto-generated title
- `--body "..."` — override auto-generated body

## Entry checklist

- [ ] `gh auth status` — logged in
- [ ] `git rev-parse --abbrev-ref HEAD` is NOT `main` (PRs are for non-main branches)
- [ ] No uncommitted changes (else commit them first via `/feature` or `/fix` flow, OR commit manually)
- [ ] Origin remote exists (else tell Leo to run `/git-push` first to bootstrap the repo)

If on `main`, tell Leo:
```
⚠️ 你在 main 分支上。/git-pr 是給 feature/fix 分支用的。
- 如果這是新專案第一次推 → 用 /git-push (建 repo + push main)
- 如果是想做 feature/fix → 先 git checkout -b feat/...
```

If origin doesn't exist:
```
還沒有 origin remote。先跑一次 /git-push 把 main 推上去建 GitHub repo,之後才能開 PR。
```

## Step 1 — Brief Leo in Chinese

```
準備推 <branch-name> 並開 PR:
- Commits in this branch vs main: <N>
- Files changed: <N>
- 推測類型: <feature / fix> (從分支前綴判斷)

確認嗎?
```

## Step 2 — Final security precheck

Dispatch `security-reviewer` to scan staged + branch diff for secrets:

```
You are running a /git-pr precheck.
Scan all files in this branch's diff vs main for: hardcoded tokens, API keys, .env files staged, suspicious credentials.
Output: BLOCKING / CLEAR.
```

If BLOCKING:
- Tell Leo what was found
- Refuse to push
- Suggest `git rm --cached <file>` + add to `.gitignore`

## Step 3 — Push branch

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push -u origin "$BRANCH"
```

If push is rejected because remote has changes (someone else pushed to this branch):
- Tell Leo
- Suggest `git pull --rebase origin "$BRANCH"` then re-run `/git-pr`
- Don't auto-rebase — could lose work

## Step 4 — Generate PR title and body (unless overridden)

Title: derive from branch name + most recent commit subject. Examples:
- Branch `feat/add-tags` + last commit `[frontend-engineer] [feat] Tag selector` → Title: `feat: add tags to todos`
- Branch `fix/auth-lowercase` + last commit `[backend-engineer] [fix] Lowercase email comparison` → Title: `fix: lowercase email comparison`

Keep title under 70 chars.

Body template:
```markdown
## Summary
<2-3 bullets distilled from commit messages>

## Changes
<file count> files changed across <N> commits:
<bullet list of commit subjects>

## Specs touched
<list of specs/*.md files modified, if any>

## Tasks
<list of manifest task ids completed in this branch, with kind>

## Test plan
- [ ] <derived from qa-* tasks in branch, if any>
- [ ] Manual: <suggest based on user-facing changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Step 5 — Open PR

```bash
gh pr create \
  --title "$TITLE" \
  $( [ "$DRAFT" = true ] && echo "--draft" ) \
  --body "$(cat <<'EOF'
<body content>
EOF
)"
```

## Step 6 — Print result

```bash
PR_URL=$(gh pr view --json url --jq .url)
```

Tell Leo in Chinese:
```
✅ PR opened: <URL>
- Branch: <branch> → main
- Commits: <N>
- Status: <Open / Draft>
- 你可以在 GitHub 上 review,要 merge 時點 "Merge pull request"

接下來建議:
- 開另一個 feature/fix → 先回 main: git checkout main && git pull
- 看 review 怎麼回事 → 在 GitHub 上看 / gh pr view
- 直接 merge → gh pr merge --squash (or --merge / --rebase)
```

## Three-tier rules

### ✅ Always do
- Refuse to PR from main (use `/git-push` instead)
- security-reviewer scan before push
- Push to origin with `-u` (set upstream)
- Auto-generate title/body from commits and manifest
- Default to non-draft (Leo can pass `--draft` if he wants)

### ⚠️ Ask first
- Push rejected (rebase needed) — let Leo decide rebase vs other strategy
- security-reviewer flags BLOCKING — let Leo decide unstage / fix / abort
- Commit message looks like a WIP / debug / TODO → ask if branch is really ready

### 🚫 Never do
- `git push --force` (use `/reset-task` if commits need rewriting)
- Open PR with secrets in diff
- Merge the PR automatically (Leo decides on GitHub)
- Squash commits without Leo's approval (each task = 1 commit is the spec)
