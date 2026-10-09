# Development Workflow

## 原則

- 所有功能開發與 Bug 修復原則上要建立 Issue。
- 每個 Issue 應有明確的工作內容與驗收標準。
- 開發工作應於獨立 Branch 進行。
- 除了文檔錯字可以直接修改 main，其他請皆使用 Pull Request 合併。

## Github Issue 流程

工作流程：

Todo → In Progress → In Review → Done

每個 Issue 至少包含：

- Description
- Tasks
- Acceptance Criteria

開始開發前應先確認工作負責人。

## 分支（Branch） 命名

格式：

```text
<type>/<issue-number>-<description>
```

Types:

- feat: 新功能
- fix: Bug 修復
- refactor: 程式碼重構
- art: 美術與素材
- docs: 文件修改

Example:

feat/12-block-placement

## Commit 標題

格式：

```text
<type>: <description>
```

Examples:

feat: 實做建築物放置功能
fix: 修正建築對齊
docs: 更新工作流程
art: 增加銅錠

Commit 應清楚描述修改內容。

## Pull Request 流程

完成開發後：

1. 確認程式碼已提交至開發分支。
2. 確認 Godot 專案可以正常執行。
3. 建立 Pull Request。
4. 填寫 PR Template。
5. 指定至少一位 Reviewer。
6. 根據 Review 意見修改。
7. 通過審查後合併至 main。

## 6.合併規則

- PR 應通過基本功能測試。
- PR 原則上需要至少一位組員審查。
- 優先使用 Squash and Merge。
- Merge 後刪除開發分支。
- 完成的 Issue 應關閉。

## 7. Godot 特殊規則

- 不提交 Godot 自動產生且應被忽略的快取檔案。
- 新增素材時確認授權與來源（如果是自己畫那就是電神）。
- 大型資源依專案 Git LFS 規範管理。
