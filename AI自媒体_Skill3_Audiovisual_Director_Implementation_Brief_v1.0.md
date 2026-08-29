# Skill 3：Audiovisual Director（视听导演）Implementation Brief v1.0

> 项目：个人 AI 自媒体  
> 状态：**Design Frozen / Implementation Gated**  
> 目的：冻结 Skill 3 的职责、接口、Router、Style Profile 接入方式、标准输出与验收标准，为后续 Codex / Work 实施提供单一规格。  
> 关联文档：
> - `AI自媒体_Topic_Hunter_Script_Engine_Implementation_Brief_v1.2.md`
> - `Skill3_Unified_Style_Profile_Schema_v1.0.md`
> - `Style_Profile_软萌3D治愈动画_v1.0.md`
> - `Style_Profile_宫崎骏动画大师_v1.0.md`

---

# 1. 执行摘要

Skill 3 正式从原来的：

> `Visual Director`

升级为：

> **`Audiovisual Director（视听导演）`**

其职责不是重新创作选题或剧本，也不是直接调用图片 / 视频模型完成生成，而是：

> **把冻结后的 Topic Thesis + Final Script + Production Handoff Manifest，结合可选的 Series Bible / Style Profile，翻译成统一、可执行、可交给 Skill 4 的视听导演方案。**

最终四层职责冻结为：

```text
Skill 1：Topic Hunter
WHAT — 选什么、用户为什么在乎

↓ Topic Thesis Card

Skill 2：Script Engine
SAY — 讲什么、按什么信息顺序讲

↓ Final Script
↓ Production Handoff Manifest

Skill 3：Audiovisual Director
SEE + HEAR + PERFORM — 怎么看、怎么听、怎么演、怎么拍

↓ Audiovisual Direction Package

Skill 4：Video Production
MAKE — 用当前模型实际生成、合成、返工和交付

↓ Assets + Final Video
```

Skill 3 是**内容语义层与模型生产层之间的翻译层**。

---

# 2. 实施闸门

本 Brief 冻结的是 Skill 3 的设计，不代表立刻全面实施。

`Topic Hunter + Script Engine v1.2` 已明确要求先完成真实内容压力测试，确认：

- Topic Hunter 能选出更好的题；
- Script Engine 能明显提升剧本质量和留存；
- Production Handoff Manifest 足够支撑制作侧。

因此 Skill 3 的实施顺序冻结为：

```text
先完成 Topic Hunter + Script Engine 真实测试
        ↓
确认 Production Handoff Manifest 可用
        ↓
实现 Skill 3 MVP
        ↓
用 1 条真实剧本跑完整视听导演流程
        ↓
确认确实减少重复决策和返工
        ↓
再考虑 Skill 4 自动化
```

禁止因为本 Brief 已完成，就立即扩展成完整 AI 视频生产平台。

---

# 3. Skill 3 的核心目标

Skill 3 只解决五个高价值问题：

1. **风格统一**：把散落在风格文档中的视觉、运镜、声音、Voice、BGM、资产约束变成统一导演语言。
2. **风格路由**：区分哪些规则应该提前送 Topic Hunter / Script Engine，哪些只应在 Skill 3 生效。
3. **视听翻译**：把文字剧本转换为 Audiovisual Beats，而不是让视频生产阶段临时猜镜头。
4. **一致性控制**：提前锁定角色、场景、道具、声音、空间和跨 Beat 连续性。
5. **生产降本**：在不改核心命题的前提下减少场景、角色、动作和重复资产。

---

# 4. 非目标（Non-Goals）

Skill 3 v1.0 **不负责**：

- 重新找选题；
- 改写 Content Thesis；
- 重写 Final Script 的核心语义；
- 验证事实真伪；
- 自动生成图片；
- 自动生成视频；
- 自动执行 TTS；
- 自动调用 Suno；
- 自动剪辑；
- 自动发布；
- 自动根据平台重新制作第二套视频；
- 把 GPT Image / Seedance / Suno 的当前语法写死成永久架构；
- 新增多个独立 Agent。

如果实现过程中出现以上功能扩张，应停止并回到本 Brief。

---

# 5. 输入合同（Input Contract）

Skill 3 的标准输入分为 **必需输入** 与 **可选输入**。

## 5.1 必需输入

### Input A — Topic Thesis Card

至少包含：

```yaml
topic_thesis:
  topic:
  core_thesis:
  user_desire_or_need:
  concrete_scenario:
  intended_state_change:
  propagation_motive:
  unique_supply:
```

Skill 3 读取该卡片的目的：

- 理解内容真正要让观众感受到什么；
- 防止视觉奇观压过内容命题；
- 判断哪些 Beat 必须成为视觉重点。

Skill 3 **无权修改** Topic Thesis。

---

### Input B — Final Script

必须是 Script Engine 已冻结的最终母剧本。

Skill 3 可以：

- 将文字拆成视听表达；
- 将信息映射到画面 / 声音 / 表演；
- 标记某句需要旁白、对白、视觉证据或静音；
- 建议合并视觉表现。

Skill 3 不可以静默：

- 删除 Hook；
- 改 Reveal；
- 改核心结论；
- 改事实；
- 改台词核心含义。

---

### Input C — Production Handoff Manifest

沿用 Script Engine v1.2 的接口。

至少包含：

```yaml
production_handoff_manifest:
  major_character_count:
  core_scene_count:
  visual_beat_count:
  consistency_risks:
  reusable_assets:
  production_complexity:
  over_budget_notes:
```

第一轮默认参考：

- 主要角色：1–3 个；
- 核心场景：3–6 个；
- Visual Beat：8–12 个；
- 复杂度：低 / 中 / 高。

Skill 3 必须把 Manifest 当作**制作边界输入**，而不是重新从零规划成本。

---

## 5.2 可选输入

### Input D — Style Profile

任何风格文档在进入运行时前，优先转换为：

> `Unified Style Profile Schema v1.0`

Skill 3 不应长期直接依赖原始 Markdown 的自由文本结构。

---

### Input E — Series Bible

若存在长期系列设定，可包括：

- 固定内容范围；
- 世界观规则；
- 固定角色；
- 固定服装与道具；
- 固定 Voice；
- 固定视觉体系；
- 固定音乐身份；
- 禁止项。

Series Bible 的权威级高于普通 Style Profile。

---

### Input F — User Current Override

用户当前任务中明确提出的覆盖指令。

例如：

```text
“这一集孙悟空穿破损铠甲”
“这一条不要 BGM”
“这一条改成 9:16”
“主角声音更年轻”
```

当轮明确 override 高于存量 Style Profile / Series Bible 的同领域默认值。

---

# 6. Style Document Ingestion

任何新“风格文档”进入系统时，先执行一次：

```text
Raw Style Document
↓
Document Classifier
↓
Module Extractor
↓
Authority Assigner
↓
Conflict Detector
↓
Style Profile Normalizer
↓
Profile Validator
↓
Unified Style Profile
```

如果该文档已经存在合法 `Style Profile`，后续运行直接加载 Profile，不重复全文解析。

---

# 7. 风格文档分类

必须支持至少以下分类：

```yaml
classification:
  - pure_visual_style
  - audiovisual_style_profile
  - hybrid_style_profile
  - narrative_style_bible
  - series_bible
  - production_playbook
  - mixed
```

参考：

### 软萌 3D 治愈动画

归类：

> `hybrid_style_profile`

因为它同时包含：

- 轻剧情和治愈故事方向；
- 强视觉与镜头规范；
- 声音 / BGM 分层；
- GPT Image / Seedance / Suno 生产规则。

---

### 宫崎骏动画大师

归类：

> `narrative_style_bible`

因为它不仅包含画面，还包含：

- 成长命题；
- 自然 / 人类 / 机械关系；
- 多方立场冲突；
- 主角原型；
- 对白表达；
- 世界观；
- 视听风格。

因此它必须有部分模块在 Topic Hunter / Script Engine 之前生效。

---

# 8. 两阶段 Router

Style Router 不采用“一份文档整体加载”的方式，而分成两个核心阶段。

## 8.1 Router A — Pre-Content Router

发生在 Topic Hunter / Script Engine 阶段。

只读取 Style Profile 中会影响内容的模块：

```yaml
pre_content_modules:
  - compatibility
  - topic_direction
  - themes
  - story_direction
  - worldview
  - character_archetypes
  - series_content_constraints
  - dialogue_style
  - narration_style
  - theme_expression_rules
```

Router A 的目标不是替代 Topic Hunter / Script Engine，而是提供：

> **内容兼容性与系列约束。**

---

## 8.2 Router B — Audiovisual Router

发生在 Final Script 冻结之后。

读取：

```yaml
audiovisual_modules:
  - visual_identity
  - character_visual
  - character_voice
  - environment
  - props
  - cinematography
  - performance
  - editing_rhythm
  - sound_design
  - voice_system
  - music_direction
  - continuity_schema
  - template_bindings
```

这些模块由 Skill 3 拥有执行权。

---

## 8.3 Production Router

属于 Skill 4，但 Skill 3 要为它准备接口。

读取：

```yaml
production_modules:
  - asset_prompt_templates
  - first_frame_templates
  - end_frame_templates
  - video_prompt_templates
  - negative_constraints
  - model_adapter_reference
  - asset_binding_rules
  - generation_workflow
```

---

# 9. 决策领域与权威

禁止使用单一全局优先级。

必须按领域判断权威。

| 决策领域 | Owner |
|---|---|
| 选什么题 | Topic Hunter |
| Content Thesis | Topic Hunter |
| 事实 / 观点 | Script Engine / 上游事实来源 |
| Hook / Reveal / Meaning | Script Engine |
| 最终台词核心语义 | Script Engine |
| 世界观长期 Canon | Series Bible |
| 角色固定 Canon | Series Bible |
| 角色外观实现 | Audiovisual Director |
| 角色 Voice Profile | Audiovisual Director / Series Bible |
| 场景美术 | Audiovisual Director |
| 运镜 | Audiovisual Director |
| 表演 | Audiovisual Director |
| 环境音 / Foley / SFX | Audiovisual Director |
| BGM Direction | Audiovisual Director |
| Suno Prompt | Audiovisual Director |
| 当前模型最终 Prompt | Video Production |
| 实际素材生成 | Video Production |
| 剪辑 / 混音 / 导出 | Video Production |

---

# 10. 冲突优先级

按领域使用以下规则。

## 10.1 Topic Thesis

```text
User Current Instruction
>
Explicit Series Bible
>
Topic Hunter
>
Style Profile Soft Constraint
```

---

## 10.2 Script Semantics

```text
User Current Instruction
>
Frozen Final Script
>
Script Engine
>
Narrative Style Constraint
```

---

## 10.3 Visual / Voice / BGM

```text
User Current Override
>
Series Canon
>
Selected Style Profile
>
Audiovisual Director Default
```

---

## 10.4 Final Model Prompt Syntax

```text
Skill 4 Current Model Adapter
>
Stored Prompt Template
>
Style Profile Reference
```

原因：

> 模型版本和语法会变化，不应成为永久视听身份。

---

# 11. 五条硬性冲突规则

## Rule 1 — No Silent Content Rewrite

风格要求与 Topic Thesis / Frozen Script 冲突时：

```text
FLAG CONFLICT
```

不得静默改写内容。

---

## Rule 2 — Canon Beats Style Preference

长期角色 / 世界观 Canon 高于普通风格偏好。

---

## Rule 3 — Current User Override Wins

当轮用户明确指定的同领域要求覆盖默认 Profile。

---

## Rule 4 — Content Semantics Beat Production Convenience

可以为了降本：

- 合并镜头；
- 合并场景；
- 减少次要角色；
- 复用资产；
- 用旁白承载次要信息；
- 降低动作复杂度。

不能为了降本首先：

- 删除 Content Thesis；
- 删除 Reveal；
- 改核心结论。

---

## Rule 5 — Style Compatibility Can Reject, Not Force-Fit

若某 Style Profile 与题材严重不兼容，应输出：

```text
STYLE-CONTENT MISMATCH
```

而不是强行把题材改造成该风格擅长的故事。

---

# 12. Skill 3 内部模块

MVP 不拆成多个 Agent。

建议一个 Skill 内部包含以下模块：

```text
audiovisual-director/
│
├── SKILL.md
│
├── contracts/
│   ├── input-contract.md
│   └── audiovisual-direction-package.md
│
├── router/
│   ├── style-ingestion.md
│   ├── pre-content-router.md
│   ├── audiovisual-router.md
│   └── conflict-resolver.md
│
├── references/
│   ├── style-profiles/
│   └── series-bibles/
│
├── modules/
│   ├── style-blueprint.md
│   ├── character-voice-bible.md
│   ├── asset-planner.md
│   ├── audiovisual-beat-director.md
│   ├── sound-director.md
│   ├── music-director.md
│   └── continuity-director.md
│
└── templates/
    └── output-package-template.md
```

目录名称可以在实现时做小幅适配，但**不得扩张成 6–8 个独立 Skill / Agent**。

---

# 13. Module 1 — Style Blueprint

输入：

- Frozen Script；
- Style Profile；
- Series Bible；
- User Override。

输出全片的视听总纲。

建议字段：

```yaml
style_blueprint:

  visual_identity:
    medium:
    palette:
    lighting:
    materials:
    atmosphere:
    geometry:
    depth:

  camera_language:
    baseline:
    climax:
    forbidden:

  performance_language:
    baseline:
    microacting:
    motion_limits:

  sound_identity:
    ambience:
    foley:
    transient_sfx:
    silence_strategy:

  voice_identity:
    narration:
    dialogue:

  music_identity:
    emotional_arc:
    instrumentation:
    density:
    silence:
```

---

# 14. Module 2 — Character & Voice Bible

角色一致性必须从“只锁脸和衣服”升级为：

> **Visual Identity + Voice Identity + Performance Identity**

每个角色至少输出：

```yaml
character:
  character_id:
  name:

  narrative_role:

  visual:
    apparent_age:
    body:
    face:
    hair:
    costume:
    palette:
    materials:
    accessories:
    silhouette:
    prohibited_changes:

  voice:
    gender_expression:
    apparent_age:
    pitch:
    timbre:
    resonance:
    tempo:
    articulation:
    emotional_baseline:
    emotional_range:
    accent:
    prohibited_traits:

  performance:
    posture:
    gesture_style:
    facial_behavior:
    motion_energy:
```

若源风格文档没有 Voice Profile 的具体字段：

> 保留 `null / unspecified`，由 Skill 3 根据角色与剧本生成建议，不伪造“源文档规定”。

若 Series Bible 已有固定 Voice Canon，则直接继承。

---

# 15. Module 3 — Asset Planner

Skill 3 输出资产需求，但不实际生成资产。

至少包括：

```yaml
asset_plan:

  characters:
    - asset_id_candidate:
      reuse: true/false
      required_views:
      consistency_risk:

  scenes:
    - scene_id:
      reuse: true/false
      spatial_requirements:
      lighting_state:

  props:
    - prop_id:
      owner:
      state_changes:
      reuse:

  special_assets:
    - type:
      reason:
```

资产规划必须优先复用 Script Engine Manifest 中已有的 `reusable_assets`。

---

# 16. Module 4 — Audiovisual Beat Director

Script Engine 的 `Visual Beat` 在 Skill 3 中正式升级为：

> **Audiovisual Beat**

它不是最终 Seedance 镜头 Prompt，而是模型无关的导演中间层。

建议结构：

```yaml
audiovisual_beat:

  beat_id:
  script_reference:

  story_function:
    one_of:
      - hook
      - conflict
      - escalation
      - evidence
      - reveal
      - meaning
      - transition

  narration_or_dialogue:

  visual:
    subject:
    action:
    environment:
    composition:
    shot_size:
    camera:
    lighting:
    color:
    material:
    physical_motion:

  performance:
    expression:
    gesture:
    interaction:

  audio:
    dialogue:
    voice_profile_id:
    ambience:
    foley:
    sfx:
    silence:

  music:
    state:
      one_of:
        - none
        - bed
        - build
        - duck
        - drop
        - climax
        - release

    intensity:

  assets:
    character_ids:
    scene_id:
    prop_ids:

  continuity:
    inherited_state:
    expected_end_state:

  production:
    complexity:
    risk:
    template_binding:
```

---

# 17. Audiovisual Beat 数量规则

沿用 Script Engine 的第一轮建议：

> **8–12 个 Beat**

但必须明确：

> Beat ≠ 最终镜头。

一个 Beat 可以在 Skill 4 中实现为：

- 1 个镜头；
- 2 个切镜；
- 1 个 30 秒自动多切片段；
- 静帧 + 动态镜头；
- 旁白 + 视觉证据。

Skill 3 不提前写死“每 Beat 必须一个视频生成单元”。

---

# 18. Module 5 — Sound Director

声音不是后期附属。

每个 Beat 必须区分：

```text
Dialogue
Narration
Ambience
Foley
Transient SFX
Silence
BGM State
```

声音规则优先描述：

1. 声源是什么；
2. 材质；
3. 距离；
4. 空间；
5. 动态阶段；
6. 与画面动作的同步点。

例如：

```text
石门缓慢压下
→ 低频石材摩擦
→ 近距离细碎砂粒落下
→ 大空间长混响
→ 门完全闭合时产生一次低频瞬态
```

禁止只写：

```text
“加震撼音效”
```

---

# 19. Dialogue / Narration / Character Voice

Skill 3 不负责重新写长篇对白，但负责定义：

- 谁说；
- 在什么声场说；
- 怎么说；
- 声音是否应该克制；
- 语速；
- 音色；
- 呼吸；
- 是否受环境噪声影响；
- 是否需要旁白替代画面对白。

角色声音最终应通过 `voice_profile_id` 被 Skill 4 引用。

---

# 20. Module 6 — Music Director

BGM 必须完全独立于视频 Prompt。

固定架构：

```text
Audiovisual Director
↓
Music Direction
↓
Music Brief
↓
Suno Prompt
↓
Skill 4 调用 Suno / Instrumental Model
↓
BGM Asset
```

视频生成提示词默认不请求背景音乐。

---

# 21. Music Brief

每条视频至少输出一个统一 Music Brief。

```yaml
music_brief:

  narrative_function:
  emotional_arc:
  tempo:
    target_bpm:
  instrumentation:
    preferred:
    avoid:
  rhythm_density:
  melody_strength:
  climax_position:
  ducking_points:
  silence_points:
  duration:
  loopability:
  avoid:
```

---

# 22. Suno Prompt

Skill 3 **负责生成 Suno Prompt**。

原因：

> BGM 属于导演层的情绪与节奏决策，而不是 Skill 4 的模型技术决策。

但 Skill 3 不调用 Suno。

Suno Prompt 必须从 Music Brief 推导，并包含：

- 情绪功能；
- 速度；
- 乐器；
- 密度；
- 情绪弧；
- 高潮；
- 留白；
- 禁止项；
- 是否纯音乐。

不得使用“某知名音乐人风格”作为核心依赖。

---

# 23. Module 7 — Continuity Director

连续性至少包含四层：

```yaml
continuity_state:

  character_state:
    position:
    pose:
    expression:
    costume:
    hair:
    injury:
    wetness:

  prop_state:
    owner:
    position:
    open_closed:
    damaged_intact:

  environment_state:
    weather:
    wind_direction:
    light_direction:
    time_of_day:
    water_state:
    mechanical_state:

  emotional_state:
```

职责分工：

### Skill 3

负责：

- 设计 `expected_end_state`；
- 定义下一 Beat 必须继承什么。

### Skill 4

负责：

- 记录实际生成结果；
- 对比实际结果与 expected state；
- 发现漂移后局部返工。

---

# 24. Prompt Template 路由

风格文档可能包含：

- 角色资产提示词模板；
- 场景资产模板；
- 道具模板；
- 首帧模板；
- 尾帧模板；
- 视频模板；
- 负向提示词。

Skill 3 不直接把这些永久写死成当前模型 Prompt。

Skill 3 输出：

```yaml
template_bindings:

  character_asset:
    template_id:

  scene_asset:
    template_id:

  prop_asset:
    template_id:

  first_frame:
    template_id:

  end_frame:
    template_id:

  video:
    template_id:

  bindings:
    character_ids:
    scene_id:
    prop_ids:
    camera:
    action:
    sound:
    continuity_state:
```

Skill 4 再根据当前：

- GPT Image；
- Seedream；
- Nano Banana；
- Seedance；
- Veo；
- 其他模型

进行语法实例化。

---

# 25. Production Adapter Boundary

所有可能快速变化的技术细节统一放到：

> `production_adapter_reference`

例如：

```yaml
production_adapter_reference:
  image_models:
  video_models:
  audio_models:
  resolution:
  generation_path:
  prompt_syntax:
  asset_binding_syntax:
  workflow:
  pause_points:
```

Skill 3 可以读，但不拥有这些决策。

如果未来 Seedance 升级：

> 优先修改 Skill 4 Adapter，而不是修改 Style Profile 的核心视听定义。

---

# 26. 标准输出：Audiovisual Direction Package

Skill 3 的唯一主输出固定为：

> **Audiovisual Direction Package（ADP）**

建议结构：

```yaml
audiovisual_direction_package:

  meta:
    project_id:
    topic_id:
    script_version:
    selected_style_profiles:
    series_bible:
    current_overrides:

  style_resolution:
    classification:
    loaded_modules:
    ignored_modules:
    conflicts:
    resolved_by:

  style_blueprint:

  character_voice_bible:

  asset_plan:

  audiovisual_beats:

  sound_cue_plan:

  music:
    music_brief:
    suno_prompt:

  continuity_plan:

  template_bindings:

  production_handoff:
    complexity:
    highest_risk_beats:
    reusable_assets:
    generation_priority:
    recommended_validation_order:
```

---

# 27. ADP 的人类可读输出

除结构化数据外，同时输出简洁导演稿。

默认阅读顺序：

```text
1. 视听总纲
2. 角色与 Voice
3. 资产清单
4. Audiovisual Beat 表
5. 声音设计
6. BGM / Suno Prompt
7. 连续性与风险
8. Skill 4 交接
```

不要同时输出大量重复 prose + YAML。

结构化数据用于执行，人类可读稿用于审查。

---

# 28. Skill 3 → Skill 4 Handoff

Skill 4 接收的不是“请你自己看看剧本做视频”，而是：

```text
Frozen Script
+
Audiovisual Direction Package
+
Style Profile IDs
+
Series Bible
+
Template Bindings
```

Skill 4 应拥有：

```text
图片资产生成
↓
资产确认 / 锁定
↓
首帧 / 尾帧实例化
↓
视频 Prompt 实例化
↓
角色语音生成 / 绑定
↓
Suno BGM 实际生成
↓
视频生成
↓
连续性质检
↓
局部返工
↓
剪辑 / 混音
↓
Final Master
```

---

# 29. 生产复杂度降级规则

当 Skill 3 判断成本过高，按顺序降级：

```text
1. 合并 Audiovisual Beats
2. 合并场景
3. 减少次要角色
4. 复用角色 / 场景 / 道具资产
5. 用旁白替代次要表演
6. 降低动作复杂度
7. 降低特殊效果数量
```

不得优先：

```text
删除 Hook
删除核心 Evidence
删除 Reveal
修改 Content Thesis
```

---

# 30. 风格兼容性 Gate

在 Audiovisual Director 正式工作前增加：

> `Style Compatibility Gate`

输出：

```yaml
style_compatibility:
  result:
    one_of:
      - strong_fit
      - acceptable
      - weak_fit
      - mismatch

  reasons:
  risks:
  recommendation:
```

若 `mismatch`：

Skill 3 应推荐：

- 换 Style Profile；
- 或由用户明确批准强制套用。

禁止自动改剧本以迁就风格。

---

# 31. 缺失信息处理

Skill 3 不应为了完整 Schema 伪造信息。

例如风格文档只有视觉，没有声音：

```yaml
voice:
  pitch: null
  timbre: null
```

Skill 3 可以在当前视频层生成：

> `recommended_runtime_voice_profile`

但必须区分：

```text
SOURCE DEFINED
vs
RUNTIME RECOMMENDED
```

---

# 32. Provenance

所有 Style Profile 关键字段应保留来源。

```yaml
provenance:

  source_documents:
    - file:
      version:

  extracted_modules:
    - field:
      source_section:
      extraction_type:
        one_of:
          - direct
          - normalized
          - inferred_structure_only
```

禁止把示例角色或示例剧情误判为系列 Canon。

---

# 33. MVP 范围

Skill 3 v1.0 MVP 只实现：

1. 读取 Frozen Script + Production Handoff Manifest；
2. 读取一个已标准化 Style Profile；
3. 判断 Style Compatibility；
4. 处理基础 authority / conflict；
5. 输出 Style Blueprint；
6. 输出 Character & Voice Bible；
7. 输出 Asset Plan；
8. 输出 8–12 个 Audiovisual Beats；
9. 输出 Sound Cue Plan；
10. 输出 Music Brief + Suno Prompt；
11. 输出 Continuity Plan；
12. 输出 Skill 4 Handoff。

---

# 34. v1.0 暂不实现

暂不做：

- 自动扫描整个风格资料库并自主选风格；
- 多个 Style Profile 的复杂混合权重系统；
- Style Profile 自动学习；
- 发布数据反向训练视觉权重；
- 自动调用图片模型；
- 自动调用视频模型；
- 自动调用 Suno；
- 自动音色提取；
- 自动剪辑；
- 自动发布；
- 多 Agent 协作；
- 完整 GUI；
- 风格向量数据库。

原因：

> MVP 的目标只是证明“统一视听导演层”是否能减少制作过程中的重复决策、风格漂移和返工。

---

# 35. 第一轮实现建议

不要一开始写完整通用引擎。

建议只用两个已经完成解析的 Profile：

```text
Profile A：
soft_cute_3d_healing

Profile B：
hand_drawn_nature_growth_fantasy
```

做成首批 fixture。

这样可以同时验证：

- Hybrid Style Profile；
- Narrative Style Bible；
- Router A；
- Router B；
- authority；
- production adapter 分离。

---

# 36. 第一轮真实测试

建议选择：

> **1 条已经由 Topic Hunter + Script Engine 生成并冻结的真实 60–90 秒剧本**

运行：

```text
Final Script
+
Production Handoff Manifest
+
Style Profile
↓
Style Compatibility Gate
↓
Style Blueprint
↓
Character & Voice Bible
↓
Asset Plan
↓
Audiovisual Beats
↓
Sound Plan
↓
Music Brief + Suno Prompt
↓
Continuity Plan
↓
Audiovisual Direction Package
```

然后**不要马上自动生成视频**。

先人工拿 ADP 做一次实际制作，记录：

- 是否还需要大量临时补决策；
- 是否有重复描述；
- Style Router 是否误伤剧本；
- Character / Voice 是否够稳定；
- Audiovisual Beat 是否太细；
- 是否真的降低 Seedance Prompt 编写成本。

---

# 37. 验收标准

Skill 3 v1.0 至少满足以下标准。

## 37.1 Boundary

1. 不重写 Content Thesis；
2. 不重写 Frozen Script 核心语义；
3. 不调用生产模型；
4. 不把当前模型语法当作永久风格规则。

---

## 37.2 Router

5. 能区分纯视听模块与内容模块；
6. 能把 Narrative Style Bible 的内容约束路由给 Topic / Script；
7. 能把生产模板留给 Skill 4；
8. 能识别 authority 冲突；
9. 冲突时不静默覆盖。

---

## 37.3 Audiovisual Output

10. 输出明确 Style Blueprint；
11. 角色外观与 Voice 同时定义；
12. 资产可复用关系明确；
13. 每个 Beat 有明确 story function；
14. 每个 Beat 有视觉、表演、声音与 BGM state；
15. 每个 Beat 有连续性起止状态；
16. 复杂度和高风险 Beat 明确。

---

## 37.4 Music

17. BGM 不混入视频 Prompt；
18. 输出独立 Music Brief；
19. 输出可直接交给 Suno 的 Prompt；
20. 音乐不会默认遮盖对白。

---

## 37.5 Production Value

21. 人工进入 Skill 4 制作时，不需要重新从头决定画风；
22. 不需要重新决定角色 Voice；
23. 不需要重新决定每段主要声音；
24. 不需要重新推断哪些资产可复用；
25. 实际返工点比“只拿 Script 做视频”明显减少。

---

# 38. 失败条件

出现以下任一情况，判定 v1.0 设计 / 实现失败：

- Style Profile 能直接覆盖 Topic Thesis；
- Style Router 需要每次重新全文阅读所有 Markdown；
- 一个风格文件被整体送入所有 Skill；
- Skill 3 生成后仍需要生产端重新决定大部分镜头；
- Skill 3 输出大量当前模型专属语法；
- Suno BGM 又被塞回视频 Prompt；
- 每增加一种风格就需要新增一个独立 Agent；
- Skill 3 本身比实际视频制作更复杂、更耗时。

---

# 39. 实施阶段

建议按 4 Phase 实施。

## Phase 1 — Contracts

实现：

- Input Contract；
- Unified Style Profile loader；
- ADP output schema；
- authority / conflict rules。

先不写复杂模块。

---

## Phase 2 — Router + Core Direction

实现：

- Style Compatibility Gate；
- Router A；
- Router B；
- Style Blueprint；
- Character & Voice Bible。

用两个现有 Style Profile 测试。

---

## Phase 3 — Beat + Audio + Music

实现：

- Audiovisual Beat；
- Sound Cue Plan；
- Music Brief；
- Suno Prompt；
- Continuity Plan。

---

## Phase 4 — Real Script Validation

拿真实 Script Engine 输出跑一次。

仅根据真实失败修正 v1.1。

---

# 40. 实施优先级

```text
P0
Input Contract
ADP Contract
Authority
Conflict Resolver
Router

P1
Style Blueprint
Character & Voice Bible
Audiovisual Beat

P1
Sound Plan
Music Brief
Suno Prompt
Continuity

P2
Prompt Template Binding

P3
复杂多风格混合
自动风格发现
学习系统
```

---

# 41. 预计实现时间

仅实现 Skill 3 MVP：

| 阶段 | 建议时间预算 |
|---|---:|
| Contracts + Schema | 1–2 小时 |
| Router + Conflict | 2–3 小时 |
| Core Direction Modules | 2–3 小时 |
| Beat / Sound / Music / Continuity | 2–3 小时 |
| Fixture 测试 + 真实剧本测试 | 2–3 小时 |
| 合计 | **约 9–14 小时** |

这是开发预算，不是要求一次做完。

如果实现明显超过该范围，应优先删除低价值抽象层，而不是继续增加框架。

---

# 42. 测试 Fixture

首版至少保留两个 Fixture：

## Fixture A

```yaml
style_id: soft_cute_3d_healing
classification: hybrid_style_profile
```

重点验证：

- story direction = medium；
- visual / camera / SFX / BGM = hard；
- model-specific 部分能正确进入 Production Router。

---

## Fixture B

```yaml
style_id: hand_drawn_nature_growth_fantasy
classification: narrative_style_bible
```

重点验证：

- Router A 能提前生效；
- 不覆盖 Topic Hunter 的 Content Thesis；
- Script Engine 能获得成长 / 世界观 / 对白约束；
- Audiovisual Router 能单独加载手绘、自然运动、Voice、BGM。

---

# 43. Completion Report

Skill 3 实施完成后必须输出：

```markdown
# Completion Report

## Result
PASS / PARTIAL / BLOCKED

## Files Created
- ...

## Files Modified
- ...

## Contracts
- Input Contract:
- Style Profile:
- ADP:

## Router
- Pre-Content:
- Audiovisual:
- Conflict resolution:

## Modules
- Style Blueprint:
- Character & Voice:
- Audiovisual Beats:
- Sound:
- Music:
- Continuity:

## Verification
- Fixture A:
- Fixture B:
- Real Script:

## Boundary Check
- No topic rewrite:
- No script semantic rewrite:
- No production execution:

## Known Limitations
- ...

## Next Action
- ...
```

---

# 44. 冻结决策

v1.0 冻结以下原则：

1. `Visual Director` 正式更名为 **Audiovisual Director**。
2. Skill 3 管 **SEE + HEAR + PERFORM**，不管选题，不拥有剧本核心语义，也不实际生产。
3. 所有风格文档先标准化成 **Unified Style Profile**。
4. Router 按**决策领域**拆分，不按文件名路由。
5. 风格文档可以包含内容模块，但内容模块必须提前送 Topic Hunter / Script Engine，而不是在 Skill 3 阶段反向覆盖。
6. Series Bible 高于普通 Style Profile。
7. BGM 永远作为独立音轨规划。
8. Skill 3 输出 **Music Brief + Suno Prompt**，Skill 4 实际生成 BGM。
9. 图片 / 首帧 / 视频 Prompt Template 可以来自 Style Profile，但 Skill 3 只做模板选择和参数绑定。
10. 当前模型语法由 Skill 4 Adapter 管理。
11. `Visual Beat` 在 Skill 3 中升级为 **Audiovisual Beat**。
12. Skill 3 的唯一主交付物为 **Audiovisual Direction Package**。
13. v1.0 不拆多个 Agent。
14. 首版只用两个已经解析完成的 Style Profile 做 fixture。
15. 完成 MVP 后立刻拿真实 Script 做测试，不继续理论扩张。

---

# 45. 下一步唯一动作

在 Topic Hunter + Script Engine 完成首轮真实压力测试后：

> **将本 Brief 交给 Codex / Work，实现 Skill 3 MVP。**

在此之前，不再继续设计 Skill 3 v1.1，也不继续增加 Schema 字段。

