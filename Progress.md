# Progress

## Current Goal

`Script Quality Review Policy Implementation Brief v1.1` 已完成 workspace、权威插件源码和独立 Plugin Deployment Gate。Script Engine 把 Review 放在有效 Stage 0 批准后的完整 Draft 与 Freeze 之间，并复用现有 `script_quality`、Evaluator Result、Execution State 和 Controller route。`ai-media@personal` 当前 installed/enabled 版本为 `0.1.0+codex.20260830091301`。

## Completed & Key Decisions

- Script Quality Review 是现有 Freeze Gate 的内部 policy，不是新 Skill、Review Core/Result、Controller stage、状态机、Beat Map、Manifest 字段、retry ledger 或 Rewrite Engine。
- Lite 只检查 Promise / Progression / Payoff；Full 额外检查功能性冲突、有效升级、悬念、支持充分的变化/揭示、高潮/释放，以及有因果的情绪变化、氛围功能和共鸣基础。
- Reviewer 只输出有具体证据的 finding 与 repair target；最多三个 Must Fix。Optional-only 必须 READY 并停止优化；Script Engine 是唯一修改者。
- `script_quality.max_retries` 固定为 1。一次局部修复后的 recheck 必须 READY 或转人工；结构性语义变化、低置信度或矛盾证据直接转人工。用户显式重开时一次请求只执行一轮，且不重置旧 retry history。
- `decide-next-action.ps1` 未修改；现有 pass → Audiovisual Director、局部 retry → Script Engine、语义/耗尽 → human review 路由已满足要求。
- 独立 Plugin Deployment Gate 已按“权威源码备份 → 官方 cachebuster → reinstall → installed-cache parity/validator/regression 回读”完成；完整回滚备份位于 `C:\Users\Roy\plugins\ai-media.backups\script-quality-deploy-20260830T091246Z`。
- 既有 Previsualization v1.1、Review Result v2.1、Manifest v1.7、Skill 5 v1.2.1 和用户确认的《雨停之前》状态保持不变。本轮未执行付费生成、Notion 写入、上传、发布、commit 或 push。

## Core Files

- `script-engine/SKILL.md`
- `script-engine/templates/script-package.md`
- `workflow-controller/contracts/execution-state.md`
- `tests/fixtures/script-engine-cases.json`
- `tests/fixtures/workflow-controller-scenarios.json`
- `tests/verify-contracts.ps1`
- `workflow-controller/scripts/decide-next-action.ps1`（复用，未修改）

## Verification

- workspace `tests/verify-contracts.ps1` PASS：3 个 Topic、3 个 Script handoff、8 个 Script Quality Review fixture 通过 Draft/Freeze 顺序、Lite/Full、Must Fix/Optional、结构性人工升级与一次 retry 边界检查。
- workspace `tests/verify-workflow-controller.ps1` PASS：`script_quality` 首次局部 retry 增至 1，`retry_count=1/max_retries=1` 时转人工且计数不变；既有 research、Storyboard、production routing 同时通过。
- 权威源码运行同两项测试均 PASS。workspace 与权威源码的五个共享修改文件 hash 一致；两边的 root/`skills/` Script policy、template、Execution State mirrors 均一致。
- 部署前备份为 806/806 文件、零缺失、零额外、零 SHA-256 mismatch。安装前 source/cache 都是 432 个非 Git 文件，仅 10 个本轮预期 mismatch；安装及测试后为 432/432、零缺失、零额外、零 mismatch。
- installed-cache plugin validator PASS；root 与 `skills/` 的 Script Engine quick validator 在 UTF-8 模式下 PASS；Script policy、template 和 Execution State mirrors hash 一致。
- installed cache 的全部 `tests/verify-*.ps1` 为 17/17 PASS，覆盖 Script Quality、Controller、Stage gates、ADP/Video、Storyboard、Review v2.1、Audio/BGM、Publishing 和 Notion dry run，且没有执行外部生成或写入。

## Known Issues

- Fixture 与合同回归证明 policy、结构和路由，不证明真实 LLM Review 质量、返工率或生产 ROI。
- 当前任务启动时加载的是部署前 Skill 上下文；磁盘回读证明新版本已安装，但应在新任务中验证实际调用新 Policy。
- installed cache 内的 `Progress.md` 是 reinstall 时的部署前快照，不是 runtime 输入；部署后的当前状态以 workspace 与权威源码的 `Progress.md` 为准。
- `codex plugin list` 仍报告 stale arg0 临时目录 ACL warning；由于 installed/enabled 状态、432/432 parity、validators 和 17/17 回归独立通过，该 warning 当前为非阻塞。
- 权威源码 Git worktree 仍包含本轮及此前未提交变更；本轮没有整理、commit 或 push 这些内容。

## Rejected / Failed Approaches

- 未采用 Brief v1.0 的独立 Script Preflight；现有 Script Engine 与 Controller 已能承担所有权和 bounded routing。
- 权威源码的整文件覆盖同步因可能覆盖既有未提交修改而被拒绝；改用逐 hunk 补丁，保留了前序 Previsualization/Publishing 变更。
- Skill quick validator 首次受 Windows GBK 默认编码影响而失败；以 `python -X utf8` 按相同文件重跑后 root/mirror 均 PASS，不应把编码启动错误误判为 Skill 内容失败。

## Next

1. 新建任务并调用 `@AI 自媒体`，用一个无付费生成的完整 Draft 验证新加载 Skill 的 Lite/Full 选择、READY/REVISE 投影和一次 retry 边界。
2. 只有后续另行授权真实生产时，才评估该 Review Policy 对返工与生成成本的实际 ROI。
3. 如需版本备份，再单独确认 Git commit/push 范围；本次部署不等于私有仓库已更新。
