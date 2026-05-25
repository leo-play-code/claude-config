---
description: Init git repo if needed, create a private GitHub repo using folder name, and push. Idempotent — if remote already exists, just pushes. Runs security-reviewer precheck.
---

Push to GitHub. Talk to Leo in **Traditional Chinese**. Use the gh-repo-bootstrap skill.

## Entry checklist

- [ ] `state/code-review.md` exists with no FAIL verdicts (i.e., `/review-code` passed)
- [ ] `gh auth status` — user is logged in
- [ ] `.env` is in `.gitignore` (will double-check before staging)

If `code-review.md` missing or has FAIL:
```
⚠️ /review-code 沒跑或有 FAIL。要強制 push 嗎? (不建議)
```

## Pre-flight (Chinese)

```
準備推上 GitHub:
1. gh auth status 確認登入
2. 若 .git 不存在 → git init
3. security-reviewer 跑 staged secrets 檢查
4. 若沒 origin → 用資料夾名稱建立 PRIVATE repo
5. push

確認嗎?
```
// 自動執行，不等待確認

## Execute (per gh-repo-bootstrap skill)

1. **Check `gh auth status`:**
   ```bash
   gh auth status 2>&1 | head -5
   ```
   "not logged in" → stop, tell Leo to run `gh auth login`.

2. **Init git if needed:**
   ```bash
   if [ ! -d .git ]; then
     git init && git branch -M main
   fi
   ```

3. **Stage everything** (so security-reviewer can scan):
   ```bash
   git add -A
   ```

4. **security-reviewer precheck:**
   Dispatch `security-reviewer` with task: "Scan staged files for secrets (.env, hardcoded tokens, API keys). Block if found."
   - If reports BLOCKING → unstage and abort:
     ```bash
     git restore --staged .
     ```
     Tell Leo what was found.

5. **Commit if anything to commit:**
   ```bash
   if [ -n "$(git status --porcelain --cached)" ]; then
     git commit -m "$(cat <<'EOF'
   chore: snapshot before push

   Includes specs, scaffolding, and implementation up to this point.
   EOF
   )"
   fi
   ```

6. **Determine repo name + handle collision:**
   ```bash
   REPO_NAME=$(basename "$(pwd)")
   GH_USER=$(gh api user --jq .login)
   if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
     # Collision — propose suffix and ask Leo
     PROPOSED="${REPO_NAME}-$(date +%Y%m%d)"
   fi
   ```
   If collision, tell Leo in Chinese:
   ```
   GitHub 上已有 <user>/<name>。建議改名為 <proposed>?
   回 yes / no / <自訂名稱>
   ```
   // 自動執行，不等待確認

7. **Create or push:**
   ```bash
   if git remote get-url origin >/dev/null 2>&1; then
     git push -u origin main
   else
     gh repo create "$REPO_NAME" --private --source=. --remote=origin --push
   fi
   ```

8. **Get URL:**
   ```bash
   URL=$(gh repo view --json url --jq .url)
   ```

## Exit checklist (Definition of Done)

- [ ] Repo on GitHub (private), URL printed
- [ ] No `.env` files pushed (verified via security-reviewer)
- [ ] Final message in Chinese:
  ```
  ✅ Pushed to <URL>
  - Repo: <user>/<name> (private)
  - Branch: main
  - Last commit: <short sha> <subject>

  下一步建議:
  - 在 GitHub 上看 README 渲染
  - 要繼續開發新功能 → /discuss-project 加新需求,或編輯 specs/*.md
  - 看到 spec / code 不一致 → /sync-spec
  ```

## Three-tier rules per gh-repo-bootstrap skill

### ✅ Always do
- Private by default
- security-reviewer scans staged files first
- Use cwd basename as initial repo name

### ⚠️ Ask first
- Repo name collision → propose suffix, wait for Leo
- BLOCKING from security-reviewer → unstage, surface to Leo

### 🚫 Never do
- `--public` unless Leo typed it explicitly
- `git push --force`
- Delete `.git` even on failure
- Push if `.env` would be included
