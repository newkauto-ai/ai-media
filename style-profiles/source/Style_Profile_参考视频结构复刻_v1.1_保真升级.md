# Style Profile：参考视频结构复刻保真升级

> **版本**：v1.1-zh
> **继承**：`Style_Profile_参考视频结构复刻_v1.0_中文解析.md`
> **内部风格 ID**：`reference_video_structural_remake`
> **文档分类**：`production_playbook`
> **状态语义**：`ready` 只表示来源、路由和契约已经验证，不表示真实成片保真通过。

## 1. 本次复刻目标

每次运行复用 `current_user_overrides`、`pre_content_style_constraints` 和 `source_evidence`，形成一个可选的 `reference_fidelity_context`：

- `primary_goal`：本次以结构、内容、视听机制或仅画风中的哪一项为主；
- `must_preserve`：必须保留的顺序、Hook、功能、关键动作、构图、声音落点等；
- `allowed_changes`：允许替换或重新设计的主体、产品、台词、场景、画风等；
- `conflict_priority`：当前用户明确指令 > 权利与真实性边界 > 冻结语义 > 已验证参考约束 > 默认建议；
- `source_evidence_refs`：只引用一份权威证据记录，不在下游重复抄写观察数据。

用户已明确的信息直接提取，不要求重填表。未明确时默认目标是“迁移结构与视听机制、替换主题内容”，并把 `goal_source` 标为 `profile_default`；默认不是永久硬规则。只借鉴画风且允许原创内容时，`content_structure_lock=false`，不得套用内容保真锁。

## 2. 冻结前结构保护

当 `content_structure_lock=true`：

- 已确定主题或 Hook 时不重新海选，不强制生成五个新 Hook；
- Stage 0 使用 `reference_structure_mapping`，按参考原顺序列出参考单元、目标改编和保留功能；无戏剧项标为 `not_applicable`；
- 不强制 H-C-E-R-M、三轮压缩、8–12 个 Beat，也不把普通动作改写成心理转折；
- 非剧情参考不得补造冲突、反转、对白或说理结尾；
- `reference_unit` 是参考/剪辑单位，不等于生成 Clip；Clip 仍由当前 Adapter 能力和生产规划决定。

Stage 0 的人工批准语义保持不变。冻结后若保留约束与内容发生冲突，返回既有上游或 `human_review`，不得静默改写。

## 3. 权威参考证据

权威 `reference_evidence_record` 至少可选记录：

- `reference_asset`: 文件身份、SHA-256、可读性和授权/真实性状态；
- `selected_scope`: 选定时间段或帧范围；
- `observations`: `evidence_id`、来源位置、可观察特征、媒体维度、解释、置信度；
- `preservation_requirements`: `requirement_id`、来源证据、功能、目标位置、必须保留项、允许变化和理由；
- `constraint_hash`: 对本次目标、保留要求、允许变化和关键证据引用计算的版本绑定哈希。

观察事实、作用解释和目标制作方案必须分开。截图只能支持构图、主体、可见状态等静态观察；运动、节奏、声音或音画同步保持 `UNKNOWN`。媒体不可读时只阻塞依赖该证据的结论。参考中的人脸、商标、台词和事实不得自动进入替换主体或事实锁。

## 4. 下游对应与动态关系

每项关键保留要求沿既有链路引用：

`reference evidence + function -> target script/ADP position -> production binding -> production_qa evidence`

ADP 仅对关键段落记录动作起步/加速/停止、镜头相对主体运动、构图与遮挡、字幕/图形出现与保持、声音落点。无需逐帧报告或固定四层拆解。

参考绑定保持一项参考一个职责：身份、动作/摄影、场景光线、声音、前序端点不得混用。时间必须区分：

- `source_timing`：参考证据中的时点；
- `target_timing`：目标台词、事件、音乐或动作计划中的时点；
- `observed_timing`：真实输出媒体中实测时点。

语义揭晓默认绑定目标台词或事件；音乐卡点、动作接触和用户锁定节拍按证据定位。规划时间不等于模型精确执行证据；没有真实媒体时不得填写 `observed_timing` 或声称同步完成。

## 5. 生产 QA

在现有 `production_qa` 中用可选 `reference_fidelity_assessment` 检查关键 `requirement_id`：参考目标、目标媒体证据、批准差异、功能是否保持，以及当前 `constraint_hash` 和媒体哈希是否仍匹配。任何相关哈希改变都使旧结果 `stale`，不消耗重试。

- 缺失或过期媒体证据：受影响项 `UNKNOWN`，沿既有证据阻塞路径；
- 字幕、图形或声音的局部缺陷：优先 `edit_or_reuse_failed_unit`，不得自动重生成无关视频；
- 关键功能满足且只剩可选差异：`accept_current_stop_optimizing`；
- 不制作无依据的总相似度分数，不增加新的失败枚举、Gate 或重试计数器。

## 6. 模块路由

```yaml
pre_content_modules:
  reference_compatibility: script_engine
  preservation_constraints: script_engine
  replacement_mapping: script_engine
  rights_and_identity_gate: existing_rights_checks
audiovisual_modules:
  reference_evidence_record: audiovisual_director
  reference_structure_mapping: audiovisual_director
  dynamic_relationship_plan: audiovisual_director
  sound_timing_basis: audiovisual_director
production_modules:
  reference_asset_binding: video_production
  reference_fidelity_trace: video_production
  reference_fidelity_assessment: production_qa
```

这些名称必须由实际 Router/契约接收；不能以 `reference_transferred` 标签替代证据、传递或验收。

## 7. 负面约束

- 不接入 Hypit，不新增 Clone Skill、总控制器、数据库、独立 Beat Map、Review Core、Gate、重试账本或通用语义时间引擎。
- 不把固定生成时长当成最终每镜时长，不把逐秒 Prompt 当成实测执行。
- 不因复刻而跳过现有人工审批、权利真实性检查、费用边界或真实媒体 QA。
- 不以 `ready`、fixture PASS、源码/缓存一致性代替真实媒体保真验证。
