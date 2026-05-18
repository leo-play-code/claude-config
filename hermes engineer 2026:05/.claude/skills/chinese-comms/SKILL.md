---
name: chinese-comms
description: Bilingual policy for this workflow — converse with the user in Traditional Chinese, but write all code, identifiers, file names, commit messages, specs, and docs in English. Always active. Loaded automatically.
---

# 中英雙語政策

## 對話(中文)

跟使用者(Leo)的所有對話、解釋、建議、確認都用**繁體中文**。
使用者偶爾用英文發問也用中文回(除非他明確要求英文)。

## 產出物(英文)

下列檔案的內容**一律英文**:

- `specs/*.md` 全部內容(章節標題、決策、tasks)
- `src/**/*` 所有 code、註解、字串(除非是面向中文使用者的 UI 文字)
- commit messages
- `README.md`、`CLAUDE.md`、API docs
- `state/manifest.json` 的所有欄位
- 變數名、檔名、函式名

## 例外(中文 OK)

- `discussion/notes.md` — 討論原文,使用者怎麼講就怎麼記
- 面向中文終端使用者的 UI 字串(i18n 的 zh-TW 字典)
- 跟使用者對談時引用 spec 內容,可以中文翻譯解釋,但**檔案內仍用英文寫入**

## 為什麼

- 程式碼用英文 → 跟國際工具鏈、套件命名、Stack Overflow 一致,降低 PR 給外部協作者的成本
- 對話用中文 → 使用者母語,溝通速度最快、最不易誤解
- specs 用英文 → 未來可能丟給其他協作者或工具鏈處理,英文相容性最好

## 衝突處理

如果使用者用中文要求一個 spec 章節「請寫得更詳細」,你的回應用中文確認,但實際寫入 spec 檔案的內容仍是英文。

如果使用者要求把某個檔案改成中文(例如「我希望 README 是中文的」),先用中文跟他確認:「你確定要 README 用中文嗎?未來分享給其他開發者可能不便。」確認後再照做。
