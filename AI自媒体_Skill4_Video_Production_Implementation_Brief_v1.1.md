# Skill 4：Video Production Implementation Brief v1.1

> 项目：个人 AI 自媒体  
> 上游：Skill 1 Topic Hunter → Skill 2 Script Engine → Skill 3 Audiovisual Director  
> 当前 Skill：Skill 4 Video Production  
> 文档状态：**Design Frozen / Ready for Codex Implementation & Real Production Validation**  
> 版本：**v1.1**  
> 日期：2026-08-20  
> 基线版本：`AI自媒体_Skill4_Video_Production_Implementation_Brief_v1.0.md`

---

# 0. v1.1 执行摘要

Skill 4 的定位保持不变：

> **MAKE — 把 Skill 3 的 Audiovisual Direction Package（ADP）编译成当前模型可执行的生产单元，并完成真实生成、QA、局部返工、连续性管理与最终交付。**

核心职责：

```text
COMPILE
→ GENERATE
→ VERIFY
→ REPAIR
→ ASSEMBLE
```

v1.1 不推翻 v1.0 的 Clip-first、Asset Hierarchy、Continuity Ledger、Targeted Retry 等核心架构，而是在第一轮真实压力测试后修复四个关键缺口：

1. **新增 LookDev / Visual Calibration Gate（P0）**  
   在批量生成资产之前，先用 3–5 个代表性资产真实验证视觉风格，避免“文字风格正确、生成结果不满意”导致批量返工。

2. **新增 Domain-level Visual Baseline**  
   一个系列的全局风格通过，不代表所有世界域都通过。天庭、地府、灵山、龙宫等必须建立各自可区分的 Visual DNA，禁止“同构图只换冷暖色”。

3. **重构 Prompt Compiler 输出格式**  
   Executable Prompt 改为“少模块 + 分段换行 + 类型专用模板”，不再输出一整段，也不再暴露十几项 YAML 风字段。

4. **Video Prompt 时间轴统一精确到 0.1s**  
   所有 Clip 时间轴必须连续、无重叠、无空档，并精确到 0.1 秒。

因此 v1.1 的核心生产链路调整为：

```text
Audiovisual Direction Package
        ↓
Production Router
        ↓
Scene / Clip Planning
        ↓
LookDev Test Spec
        ↓
──────────────────────────────
Stage 0：LookDev / Visual Calibration
──────────────────────────────
        ↓
3–5 LookDev Anchors
        ↓
Anchor Prompt Compile
        ↓
Real Image Generation
        ↓
AI QA + Human Approval
        ↓
Approved Visual Baseline Pack
        ↓
STYLE LOCK
        ↓
──────────────────────────────
正式生产
──────────────────────────────
        ↓
Asset Prompt Compiler
        ↓
Asset Generation / QA
        ↓
Storyboard / Keyframe Planner
        ↓
Keyframe Prompt Compiler
        ↓
Keyframe Generation / QA
        ↓
Clip Video Prompt Compiler
        ↓
Video Generation
        ↓
Clip QA
        ↓
Continuity Ledger
        ↓
Targeted Retry
        ↓
Voice / SFX / BGM
        ↓
Assembly
        ↓
Final QC
```

---

# 1. Skill 4 的职责边界

## 1.1 Skill 3 负责

Skill 3：Audiovisual Director 负责：

- SEE：视觉风格、构图、镜头语言、场景方向；
- HEAR：对白、环境声、Foley、SFX、Music Brief；
- PERFORM：角色行为、情绪、表演设计；
- Audiovisual Beat；
- `expected_end_state`；
- Character & Voice Bible；
- Asset Plan；
- Style Blueprint；
- Global / Domain Visual DNA；
- LookDev Test Spec；
- 风格与视觉意图的模型无关描述。

Skill 3 输出：

> **Audiovisual Direction Package（ADP）**

Skill 3 不负责：

- 当前具体图片 / 视频模型语法；
- 实际图片或视频生成；
- 实际生成文件；
- `actual_end_state`；
- 实际 QA 与返工。

---

## 1.2 Skill 4 负责

Skill 4 接管：

```text
导演意图
↓
生产计划
↓
当前模型可执行 Prompt
↓
真实生成结果
↓
视觉与连续性 QA
↓
Targeted Retry
↓
最终素材
```

具体包括：

- Production Adapter；
- Scene / Clip Planning；
- LookDev Anchor Prompt 编译；
- LookDev 真实生成与 QA；
- Approved Visual Baseline 管理；
- Asset Prompt Compiler；
- Asset Reference Hierarchy；
- Storyboard / Keyframe Planning；
- Keyframe Prompt Compiler；
- Clip Video Prompt Compiler；
- 微表情编译；
- 真实生成；
- Continuity Ledger；
- Failure Taxonomy；
- Targeted Retry；
- Voice / Foley / SFX / BGM 落地；
- Assembly / Final QC。

---

# 2. 核心生产单位：Beat → Scene → Clip → Shot

定义保持 v1.0：

```text
Audiovisual Beat
= 叙事 / 视听功能单位
= Skill 3 的导演语言

Scene
= 相对稳定的时空环境
= 地点 / 时间 / 世界状态的稳定区间

Clip
= Skill 4 的核心 AI 视频生成单元
= 一次模型调用希望生成出的连续视频段落

Shot
= Clip 内部的镜头表现单位
= 不默认单独生成
```

因此：

```text
Beat ≠ Shot
Beat ≠ Clip
Clip ≠ 单 Shot
```

---

# 3. Clip-first 原则

继续冻结：

> **Skill 4 采用 Clip-first，而不是 Shot-first。**

逐 Shot 独立生成会增加：

- 身份漂移；
- 服装 / 道具漂移；
- 光线跳变；
- 动作无法衔接；
- 镜头碎片化；
- 生成调用数量；
- 后期剪辑成本。

因此优先让当前模型一次生成一个：

> **micro-sequence（微型连续段落）**

---

# 4. Clip 时长与 Shot Density

## 4.1 默认策略

v1.1 不把具体模型最大时长写死成永久架构。

```yaml
clip_policy:
  default_test_duration: 6-14s
  runtime_max_duration: adapter_capability
```

说明：

- 6–14 秒仍作为首轮验证和高可控性区间；
- 当前模型若支持更长连续生成，可由 Adapter 放宽；
- 是否延长由动作连续性、场景连续性、模型稳定性决定；
- 不为了减少调用次数强行拉长 Clip。

---

## 4.2 Shot Density

取消 `maximum_shots: 3` 全局硬限制。

```yaml
shot_density:
  calm: 1-2
  normal: 1-3
  energetic: 3-5
  hyper: 4-8
```

以上只是推荐区间，不是硬限制。

高能风格允许：

- Continuous Dynamic Clip；
- Multi-cut Montage Clip。

当前模型多切镜不稳定时：

> **拆成两个连续 Clip，而不是退化成大量 1–2 秒独立 Shot。**

---

# 5. Pace Router

```yaml
pace_profile:
  mode:
    - calm
    - normal
    - energetic
    - hyper

  avg_shot_duration:
  camera_energy:
  cut_frequency:
  action_density:
  transition_style:
  motion_complexity:
```

优先继承：

```text
Style Profile
→ Skill 3
→ Skill 4 Pace Router
```

---

# 6. Scene Router 与 Clip Packing

新 Scene 通常由以下变化触发：

- 地点；
- 时间；
- 日夜；
- 世界状态；
- 主角色组合；
- 服装 / 造型；
- 重大伤势 / 污渍 / 湿润状态；
- 光线逻辑。

同一 Scene 内相邻 Beats 满足以下条件时优先合并：

```text
角色连续
+
动作连续
+
情绪连续
+
空间连续
+
总时长处于当前模型稳定范围
```

---

# 7. Production Adapter

模型能力不得写死在 Style Profile。

Skill 4 维护：

```yaml
production_adapter:
  image_model:
  video_model:
  audio_model:
  bgm_model:

  capabilities:
  duration_options:
  reference_image_support:
  multi_reference_support:
  character_reference_support:
  first_frame_support:
  end_frame_support:
  transition_frame_support:
  native_multishot_support:
  native_audio_support:
  dialogue_support:
  sfx_support:

  prompt_structure:
  timing_syntax:
  asset_binding_syntax:
  resolution:
  known_failure_modes:
```

原则：

> **换模型 = 更新 Adapter，不修改 Series / Style Profile。**

---

# 8. v1.1 新增：LookDev / Visual Calibration Gate

## 8.1 为什么必须增加

真实测试证明：

> **Style Profile 在文字上正确，不等于图片模型真实生成后的视觉效果正确。**

常见风险包括：

- “电影写实”被模型解释成普通古装剧；
- “克制、少金光”被解释成没有神性；
- 不同世界域使用相同空间构图，只换色温；
- Scene Prompt 看似完整，但实际画面没有目标风格；
- 批量资产全部生成后才发现方向错误。

因此 LookDev 为 **P0 Gate**，发生在批量 Production Asset Prompt 编译之前。

---

## 8.2 Stage 0 流程

```text
Skill 3 LookDev Test Spec
        ↓
选择 3–5 个 LookDev Anchors
        ↓
只编译这些 Anchor Prompt
        ↓
真实图片生成
        ↓
AI QA
        ↓
Human Approval
        ↓
Approved Visual Baseline Pack
        ↓
STYLE LOCK
        ↓
才允许批量生产
```

---

## 8.3 LookDev Anchors

不是随机抽样，而选择最能暴露视觉问题的代表资产。

推荐组合：

```text
1. 主角色 / 神性角色
2. 阴性世界域
3. 阳性 / 神圣世界域
4. 普通人间域
5. 可选重要道具
```

通常控制在：

> **3–5 张以内完成第一轮校准。**

---

## 8.4 五项验收

LookDev 固定只检查：

### 1. Global Style

整个系列是不是目标视觉风格。

### 2. Domain Identity

不同世界域是否具有独立视觉语言。

禁止：

> 同样构图 + 同样建筑语法 + 只换冷暖 / 明暗。

### 3. Mythic / World Scale

该世界是否达到应有尺度和纵深。

### 4. Story Usability

角色、镜头、动作是否有可生产空间。

### 5. Reference Usability

图片是否足够稳定、明确，可作为后续 Keyframe / Clip 参考。

---

## 8.5 Human Approval

首次出现的：

- Style；
- 角色视觉方向；
- Domain；

必须：

> **AI QA + Human Approval**

已经 Approved 的 Visual Baseline：

> 后续项目可优先复用，不要求每次人工重复确认。

---

## 8.6 Domain-level Gate

某个 Domain 失败时：

> **只 Block 该 Domain 相关资产 / Clips。**

不得因为一个 Domain LookDev 失败而停止整个视频。

例如：

```text
Buddha Character Domain = PASS
Underworld Domain = PASS
Lingshan Domain = FAIL
```

则：

- 如来相关可继续；
- 地府相关可继续；
- 灵山相关暂时 Block；
- 其他项目流程不回滚。

---

# 9. Approved Visual Baseline Pack

LookDev 通过后不能只保存 Prompt。

必须保存：

```text
Style Profile
+
Approved Executable Prompt
+
Approved Generated Image
```

共同构成：

> **Approved Visual Baseline Pack**

以后生产优先参考真实批准图片，而不是每次让模型重新解释文字 Style Profile。

---

# 10. Mythic Grandeur Binding（条件模块）

对于：

- 天庭；
- 地府；
- 灵山；
- 龙宫；
- 其他神魔世界；

Prompt Compiler 必须检查五项：

1. **Monumental Scale**：超常尺度与尺度参照；
2. **Celestial / Abyssal Depth**：云海、深渊、圣山、悬空层级等纵深；
3. **Divine Light Field**：体积天光、云隙光、圣辉或阴性能量光场；
4. **Sacred Geometry**：轴线、圆相、莲瓣、八卦等结构化几何；
5. **Impossible-but-Coherent Architecture**：不可能空间，但保持中国神话建筑逻辑。

反向约束：

```text
克制 ≠ 普通古装剧
少金光 ≠ 无神性
少群像 ≠ 小尺度
材质写实 ≠ 世界写实
```

该模块是**按 Style / Domain 条件激活**，不是所有视频强制加载。

---

# 11. Asset 系统

保持三层核心：

```text
Identity Asset
Production Asset
Keyframe
```

扩展层级：

```text
Identity Asset
↓
Variant Asset（可选）
↓
Scene Production Asset（按需）
↓
Clip Production Asset（少量高风险）
↓
Keyframe
↓
Video Clip
```

---

# 12. Identity Asset

Identity Asset = Canonical Identity。

用于锁定：

- 面部；
- 身体比例；
- 发型；
- 服装；
- 道具；
- 基础材质；
- 固定视觉特征。

生命周期可以跨：

- Scene；
- Clip；
- 同系列多条视频。

---

# 13. Production Asset

Production Asset = Scene / Clip-specific 工作资产。

用于结合：

```text
Identity
+
当前 Scene
+
当前服装 / 污渍 / 湿润 / 战损
+
当前光线
+
当前道具
+
当前人物状态
```

---

# 14. Production Asset 不要求每 Scene 强制生成

继续采用：

> **Risk-based Generation**

满足任一情况时建议创建：

- 服装 / 发型变化；
- 特殊伤势 / 污渍 / 湿润；
- 特殊光线；
- 复杂道具；
- 多角色空间关系；
- 新世界域；
- 后续多个 Clip 共用状态；
- 当前模型仅靠 Identity Reference 不稳定。

简单 Scene 可直接：

```text
Identity Asset
+
Scene Asset
↓
Keyframe
```

---

# 15. Asset Reference Hierarchy

继续冻结：

```text
1. Clip Keyframe / Resume Keyframe
2. Scene / Clip Production Asset
3. Variant Asset
4. Identity Asset
5. Style Reference
```

即：

> **Nearest Useful Reference Principle（最近有效参考原则）**

多参考模型推荐职责拆分：

```text
Primary Visual Reference
= Keyframe / Production Asset

Identity Reference
= Identity Asset

Style Reference
= Approved Visual Baseline（按需）
```

---

# 16. v1.1 Prompt Compiler 总原则

## 16.1 Prompt 有两层

内部：

> **Prompt Spec**

外部：

> **Executable Prompt**

Prompt Spec 可以结构化、字段化。

Executable Prompt 必须：

> **少模块 + 自然语言 + 清晰换行 + 可直接复制执行**

---

## 16.2 Notion Prompt 字段的唯一含义

Notion 中：

```text
Prompt
Video Prompt
```

只能存：

> **最终 Executable Prompt**

不得存：

- Style Summary；
- ADP 摘要；
- Asset Description；
- 导演形容词摘要；
- Prompt Spec 的半成品。

---

## 16.3 Mandatory-by-Type

不使用一个 Universal Prompt Template 强制填满所有字段。

原则：

> **不同 Prompt 类型只保留真正影响生成质量的必要模块。**

---

# 17. Character Identity Prompt｜5 模块

固定格式：

```text
【用途与输出】
……

【角色设计】
……

【服装 / 材质 / 配色】
……

【视觉风格与光线】
……

【一致性与禁止项】
……
```

说明：

- 身份 / 年龄 / 面部 / 体型 / 发型 / 姿态合并到“角色设计”；
- Style / Background / Lighting 合并；
- Continuity + Negative 合并；
- 不加入当前 Scene 剧情动作。

---

# 18. Scene Production Prompt｜6 模块

```text
【用途】
……

【空间设计】
……

【材质与环境】
……

【镜头与光线】
……

【风格强化】
……

【生产约束】
……
```

核心权重：

> **空间设计 > 材质标签。**

“空间设计”必须回答：

- 前景是什么；
- 中景行动区在哪里；
- 后景是什么；
- 人物未来站在哪里；
- 镜头从哪里拍；
- 动作空间是否可用。

“风格强化”用于：

- Mythic Grandeur；
- 软萌 3D；
- 暗黑东方奇幻；
- 手绘自然；
- 其他特定风格。

---

# 19. Prop Prompt｜4 模块

```text
【用途】
……

【造型与结构】
……

【材质与视觉风格】
……

【一致性与禁止项】
……
```

不强制增加镜头、环境等无意义字段。

---

# 20. Graphic Prompt｜4 模块

```text
【信息目标】
……

【内容与版式】
……

【视觉风格】
……

【文字与禁止项】
……
```

如果图片模型无法稳定生成精确中文：

> **只生成视觉框架与文字占位区 → 后期排版精确文字。**

禁止反复抽卡修字。

---

# 21. Keyframe Prompt｜5 模块

```text
【参考资产】
……

【当前画面】
……

【镜头与构图】
……

【光线与氛围】
……

【连续性与禁止项】
……
```

Keyframe 原则：

> 已经由 Reference Asset 提供的信息，不重新在 Prompt 中大段复述。

Keyframe 负责：

```text
角色 + 场景 + 道具 + 当前精确状态
```

---

# 22. Clip Video Prompt｜6 模块

固定格式：

```text
【规格与参考】
……

【起始状态】
……

【时间轴】
……

【镜头与表演】
……

【结束状态】
……

【连续性与禁止项】
……
```

---

# 23. Video Prompt 时间轴规则｜v1.1 硬规则

所有 Video Clip Prompt：

> **时间轴统一精确到 0.1s。**

例如：

```text
【时间轴】
0.0–1.8s：……
1.8–4.6s：……
4.6–6.9s：……
6.9–8.0s：……
```

必须满足：

1. 覆盖整个 Clip；
2. 第一段从 `0.0s` 开始；
3. 最后一段精确结束于 Clip 总时长；
4. 时间段无空档；
5. 时间段无重叠；
6. 边界统一保留 1 位小数；
7. 每个阶段至少明确：
   - 主体动作；
   - 镜头变化；
   - 关键状态变化（如有）。

说明：

> 0.1s 精度用于生成计划与 Adapter 编译，不表示模型必然具有帧级严格执行能力。QA 应检查“节奏与阶段是否基本匹配”，而非把生成模型当确定性时间轴引擎。

---

# 24. Shot Sequence 与 Camera Beat 分离

```text
Shot
= 真正切镜

Camera Beat
= 同一 Shot 内的运镜阶段
```

高能 Clip 可以：

```text
Shot 1
├── Camera Beat A
├── Camera Beat B
└── Camera Beat C
```

不应机械增加 Shot 数量。

---

# 25. Storyboard 采用 Risk-based Storyboard

Storyboard 的职责：

> **Spatial & Action Validation**

而不是传统逐 Shot 全量分镜图。

```yaml
storyboard_policy:
  low_risk: optional
  medium_risk: recommended
  high_risk: required
```

High Risk 示例：

- 多角色走位；
- 高速动作；
- 复杂空间；
- 高能多 Shot；
- 重要连续转场。

---

# 26. Keyframe 类型

支持：

```text
First Frame
End Frame
Transition Frame
Continuity Resume Frame
```

尤其：

```text
Clip A
↓
actual_end_state
↓
Resume Keyframe
↓
Clip B
```

---

# 27. Micro-expression Renderer

只在：

```text
写实 / 半写实角色
+
中近景 / 近景 / 特写
+
存在明确情绪变化
```

时激活。

默认生理传导：

```text
眼周
↓
口唇
↓
下颌
↓
Residual State
```

最终外部 Prompt 不写机械毫米值，转译为自然语言：

- 极小幅度；
- 几乎不可察觉；
- 头部保持稳定；
- 眉额保持稳定；
- 轻微肌肉牵动。

---

# 28. Continuity Ledger

Skill 3 输出：

```text
expected_end_state
```

Skill 4 记录：

```text
actual_end_state
```

下一 Clip：

> 优先继承真实生成结束状态，而不是理想计划状态。

```yaml
clip_result:
  clip_id:
  selected_generation:
  actual_start_state:
  actual_end_state:
  character_state:
  costume_state:
  prop_state:
  scene_state:
  lighting_state:
  emotion_state:
  continuity_delta:
  usable:
```

---

# 29. Clip QA

每个 Clip 最少检查：

- Semantic Fidelity；
- Identity Consistency；
- Style Consistency；
- Domain Identity；
- Spatial Continuity；
- Action Accuracy；
- Camera Accuracy；
- Performance Accuracy；
- Artifact / Deformation；
- End-state Continuity。

---

# 30. Failure Taxonomy

```yaml
failure_type:
  identity_drift
  duplicate_or_extra_character
  false_visual_leak
  style_drift
  domain_identity_failure
  environment_drift
  prop_drift
  motion_failure
  camera_failure
  timing_failure
  multishot_failure
  expression_overacting
  expression_underacting
  continuity_mismatch
  text_render_failure
  artifact
```

---

# 31. Targeted Retry

原则：

> **识别失败层，只修改对应 Prompt Layer，只重跑失败资产 / Clip。**

```text
failure_type
↓
Prompt Layer
↓
局部修正
↓
Retry
```

例：

### `domain_identity_failure`

不是简单调色。

应检查：

- 建筑语法；
- 空间哲学；
- 构图；
- 光场；
- 尺度；
- Domain Visual DNA。

### `text_render_failure`

回退到：

> Graphic Asset + 后期排版。

### `multishot_failure`

先降低 Camera / Shot 复杂度。

仍失败：

> 拆成两个连续 Clip + Resume Keyframe。

---

# 32. 声音 / Voice / BGM

Skill 3：

```text
Voice Direction
Music Brief
Suno Prompt
SFX / Foley Direction
```

Skill 4：

```text
实际 Voice Asset
实际 BGM Asset
实际 Foley / SFX
混音
```

硬规则：

> **BGM 不写入 Video Prompt。**

是否使用模型原生 Dialogue / SFX：

> 由当前 Production Adapter 判断。

---

# 33. Machine Source of Truth

保持：

```text
production_manifest.yaml
```

或 JSON。

用于：

- 状态继承；
- Prompt 编译；
- QA；
- Retry；
- Automation；
- Adapter。

---

# 34. Human Review Layer

```text
Production_Package.md
```

用于：

- 人类 Review；
- Codex；
- Git；
- 版本管理；
- 生产交接；
- 存档。

---

# 35. Production UI｜Notion

Notion 定位：

> **Production UI，而不是 Machine Source of Truth。**

v1.1 已验证原则：

> **简洁字段 + 长内容进入 Page / Prompt Property。**

禁止为了“系统完整”不断增加数据库字段。

---

# 36. Notion 数据组织原则

建议：

```text
一个视频 = 一个 Project Page
```

核心关系：

```text
Project
├── Assets
├── Clips
├── Evidence
└── Publications
```

Notion 不要求 Scene 独立数据库；Scene 可以保持为资产 / Clip 的轻量字段或 manifest 内部结构。

---

# 37. Notion Prompt 展示规则

默认管理视图：

> 隐藏长 Prompt，只看状态与核心索引。

专用工作视图：

```text
🖼️ 资产生成提示词
🎞️ 视频生成提示词
```

Asset 推荐显示：

```text
Name
Status
层级
对象
Prompt
```

Clip 推荐显示：

```text
Name
Status
时长
Video Prompt
```

---

# 38. Notion Date / Time 原则

当前生产系统只保留真正有业务意义的 Date：

> **发布日期**

用于 7-Day Validation。

以下时间默认不创建 Property：

- Created；
- Updated；
- Asset Generated Time；
- Clip Generated Time；
- QA Time。

除非未来真实数据分析证明需要。

---

# 39. Notion Prompt 存储规则

`Prompt` / `Video Prompt`：

> **唯一 Executable Prompt 真相源。**

Asset / Clip Page 正文只保存：

- Prompt Spec；
- Source-Locked；
- Runtime Design；
- Continuity；
- QA；
- LookDev / Domain 状态。

不要在正文重复第二份 Executable Prompt。

---

# 40. Source-Locked vs Runtime Design

必须继续区分：

### Source-Locked

来自：

- Series Bible；
- Style Profile；
- 用户明确确认设定。

### Runtime Design

源资料没有定义，但为了当前生成必须补齐的：

- 面部；
- 服装细节；
- 空间布局；
- 某些材质；
- 某些视觉机制。

规则：

> Runtime Design 默认只属于当前项目，不自动升级为 Series Canon。

只有人工确认后才可晋升为长期 Canon / Visual Baseline。

---

# 41. Skill 4 内部结构｜v1.1

```text
video-production/
│
├── SKILL.md
├── contracts/
│   ├── input-contract.md
│   ├── production-manifest.md
│   └── lookdev-test-spec.md
│
├── adapters/
│   ├── image-adapter.md
│   ├── video-adapter.md
│   ├── audio-adapter.md
│   └── bgm-adapter.md
│
├── modules/
│   ├── production-router.md
│   ├── scene-clip-planner.md
│   ├── pace-router.md
│   ├── lookdev-calibration.md
│   ├── asset-prompt-compiler.md
│   ├── asset-reference-router.md
│   ├── storyboard-keyframe-planner.md
│   ├── keyframe-prompt-compiler.md
│   ├── clip-prompt-compiler.md
│   ├── micro-expression-renderer.md
│   ├── continuity-ledger.md
│   └── qa-retry.md
│
└── templates/
    ├── character-identity-prompt.md
    ├── scene-production-prompt.md
    ├── prop-prompt.md
    ├── graphic-prompt.md
    ├── keyframe-prompt.md
    ├── video-clip-prompt.md
    └── production-package.md
```

---

# 42. 不拆多 Agent

继续冻结：

> **一个 Skill + 内部模块化。**

V1.1 不新增：

- LookDev Agent；
- Asset Agent；
- Storyboard Agent；
- Video Agent；
- QA Agent。

只有真实运行证明模块需要独立：

- 生命周期；
- 权限；
- 上下文；
- 资源；

时才考虑拆分。

---

# 43. P0 / P1 / P2｜v1.1

## P0

必须实现：

1. Input Contract；
2. Production Manifest；
3. Production Adapter；
4. Scene → Clip Planner；
5. Pace Router；
6. **LookDev / Visual Calibration Gate**；
7. Approved Visual Baseline Binding；
8. Asset Prompt Compiler；
9. 六类 Prompt Template；
10. Asset Reference Hierarchy；
11. Keyframe Prompt Compiler；
12. Clip Video Prompt Compiler；
13. **0.1s Timeline Compiler / Validator**；
14. Continuity Ledger；
15. Basic QA；
16. Domain Identity QA；
17. Targeted Retry。

---

## P1

1. Risk-based Storyboard；
2. Micro-expression Renderer；
3. Variant Asset；
4. Suno 执行；
5. Voice / Foley / SFX；
6. Notion Production UI 自动同步；
7. Optional XLSX Export。

---

## P2

暂缓：

- 全自动剪辑；
- 自动字幕；
- 自动发布；
- 自动跨模型比价；
- Prompt 自学习；
- 成本优化器；
- 多视频并行队列；
- 自动营销发布；
- 自动审美决策替代人工 Style Approval。

---

# 44. 第一轮真实测试策略｜更新版

v1.0 原先：

```text
ADP
→ Scene / Clip Planning
→ 批量资产 Prompt
→ 资产生成
→ C01/C02
```

v1.1 修改为：

```text
ADP
↓
Scene / Clip Planning
↓
LookDev Test Spec
↓
3–5 Anchor Prompt
↓
真实 Anchor Generation
↓
AI QA + Human Approval
↓
STYLE LOCK
↓
只编译当前 Gate 真正需要的资产
↓
Identity / Production Asset
↓
Keyframe
↓
C01
↓
QA
↓
C02
↓
QA
↓
继续 Approved Domain
```

---

# 45. 当前 Fixture：《真假美猴王》

该项目已经验证出以下高价值问题：

### 已验证

- v1.0 Clip-first 规划可用；
- Asset / Clip 数据结构可用；
- Prompt 摘要不能直接作为 Executable Prompt；
- Prompt 需要类型专用模板；
- Style Profile 文字正确不等于生成效果正确；
- 神魔世界必须有 Mythic Grandeur Binding；
- Domain 必须视觉可区分；
- LookDev 必须发生在批量资产生成前；
- 失败 Domain 可以单独 Block；
- Notion 字段过多会降低生产效率；
- 长 Prompt 应隐藏在专用工作视图，不应缩成摘要。

### 当前视觉校准

```text
Global Mythic Style
= Provisional PASS

Buddha Character Domain / 如来
= PASS

Underworld Domain / 地府
= PASS

Lingshan Domain / 雷音寺
= FAIL / NOT LOCKED
```

雷音寺失败原因：

> 与地府的空间构图和建筑语法过于相似，主要靠冷暖 / 明暗区分，Domain Identity 不成立。

处理：

> 暂不继续修改雷音寺；只 Block Lingshan / C05，不阻塞其他已批准 Domain。

---

# 46. 当前 Production Gate

```text
LookDev
├── 如来 PASS
├── 地府 PASS
└── 灵山 FAIL / Block

并行继续：
孙悟空 Identity
↓
C01 First Keyframe
↓
C01 Video
↓
C01 QA
↓
C02
↓
C02 QA
```

只有已批准 Domain 可继续批量生产。

---

# 47. 验收指标｜v1.1

Skill 4 不按模块数量验收。

## LookDev

- 是否在 3–5 张内暴露视觉方向问题；
- 是否阻止错误 Style 批量扩散；
- Domain Identity 是否能明确区分；
- Approved Baseline 是否可复用。

## Prompt

- 是否可直接复制执行；
- 是否按类型简洁分段；
- 是否减少重复信息；
- 是否避免 Style Summary 冒充 Prompt；
- Video Timeline 是否 0.1s 连续覆盖整个 Clip。

## Production

- First-pass success rate；
- Identity drift；
- Continuity failure；
- Multi-shot failure；
- Targeted retry 成功率；
- 无意义短 Shot 是否下降；
- Generation Calls / Minute Video。

## Asset ROI

- Asset reuse rate；
- Production Asset usage rate；
- 是否避免每 Scene 无脑创建 Production Asset；
- Approved Visual Baseline 是否被实际复用。

---

# 48. 建议生产指标

```yaml
production_metrics:
  total_clips:
  total_generated_seconds:

  lookdev_anchor_count:
  lookdev_pass_rate:
  domain_reuse_rate:

  successful_first_pass_rate:
  avg_retry_per_clip:

  identity_drift_rate:
  continuity_failure_rate:
  multishot_failure_rate:
  domain_identity_failure_rate:

  avg_generation_calls_per_minute_video:

  asset_reuse_rate:
  production_asset_usage_rate:
```

不要求第一版全部自动采集。

---

# 49. 明确不采用的方案｜v1.1

继续不采用：

1. **每个 Shot 独立生成**；
2. **每 Clip 全局最多 3 Shot**；
3. **每个 Scene 强制生成 Production Asset**；
4. **所有视频只引用 Identity Asset**；
5. **完全弃用 Identity Asset**；
6. **XLSX 作为 Source of Truth**；
7. **第一版直接全自动剪辑 / 字幕 / 发布**；
8. **LookDev 通过前批量生成所有 Production Asset**；
9. **只保存 Prompt、不保存 Approved Image**；
10. **所有世界域共用一套空间设计，仅靠换色区分**；
11. **Executable Prompt 用十几项字段机械填表**；
12. **Executable Prompt 以一整段长文本输出**；
13. **为了界面简洁把 Prompt 压缩成摘要**；
14. **首次 Style / Domain 完全交给 AI 自动审美批准**。

---

# 50. v1.1 最终冻结决策

以下作为 Skill 4 v1.1 正式决策：

1. Skill 4 = **Video Production**。
2. 核心职责 = `COMPILE + GENERATE + VERIFY + REPAIR + ASSEMBLE`。
3. 核心生产单位继续采用 **Clip-first**。
4. Beat / Scene / Clip / Shot 继续严格区分。
5. Shot Density 动态决定，不使用 `maximum_shots: 3`。
6. 多切镜失败优先拆连续 Clip，不回到大量极短 Shot。
7. Identity / Variant / Production Asset / Keyframe 使用层级化引用。
8. Production Asset 继续采用 Risk-based Generation。
9. Reference 使用 Nearest Useful Reference Principle。
10. **LookDev / Visual Calibration Gate 升为 P0。**
11. 首次 Style / Domain 必须经过真实生成 + Human Approval。
12. LookDev Anchor 控制在 3–5 个代表性资产。
13. LookDev 通过前禁止批量编译全部 Production Asset Prompt。
14. Approved Prompt + Approved Image + Style Profile 共同构成 Visual Baseline。
15. Domain 失败只 Block 对应 Domain，不回滚整个项目。
16. 神魔世界按需激活 Mythic Grandeur Binding。
17. Prompt 内部保留 Prompt Spec，外部输出 Executable Prompt。
18. Executable Prompt 采用 **Mandatory-by-Type**，不使用 Universal-Mandatory。
19. 六类 Prompt Template 正式冻结：
    - Character Identity；
    - Scene Production；
    - Prop；
    - Graphic；
    - Keyframe；
    - Video Clip。
20. Executable Prompt 必须按模块换行，不允许一整段。
21. Character Identity = 5 模块。
22. Scene Production = 6 模块。
23. Prop = 4 模块。
24. Graphic = 4 模块。
25. Keyframe = 5 模块。
26. Video Clip = 6 模块。
27. **Video Clip 时间轴必须精确到 0.1s。**
28. Timeline 必须连续覆盖整个 Clip，无空档、无重叠。
29. 0.1s 为规划/编译精度，不将生成模型视为确定性帧级执行器。
30. Continuity 使用 `expected_end_state → actual_end_state`。
31. QA 使用 Failure Taxonomy + Targeted Retry。
32. 新增 `domain_identity_failure`。
33. BGM 保持独立，不写入 Video Prompt。
34. `production_manifest.yaml` 继续作为 Machine Source of Truth。
35. `Production_Package.md` 继续作为 Human Review Layer。
36. Notion 继续作为 Production UI。
37. Notion 数据库字段保持精简。
38. Prompt / Video Prompt 字段只允许保存 Executable Prompt。
39. Notion 默认管理视图隐藏长 Prompt；专用 Prompt 视图负责复制执行。
40. Date / Time 当前只保留业务必要的 `发布日期`。
41. XLSX 继续仅作为可选 Export Adapter。
42. Skill 4 v1.1 继续坚持一个 Skill + 内部模块化，不拆 Agent。
43. 当前最高优先级仍是**真实生产验证**，不是继续横向扩模块。

---

# 51. Codex 实施顺序｜v1.1

```text
Phase 1
Input Contract
+
Production Manifest Schema

Phase 2
Production Adapter
+
Scene / Clip Planner
+
Pace Router

Phase 3
LookDev Test Spec Contract
+
LookDev Calibration Module
+
Visual Baseline Binding

Phase 4
六类 Prompt Template
+
Asset Prompt Compiler
+
Asset Reference Router

Phase 5
Storyboard / Keyframe Planner
+
Keyframe Prompt Compiler

Phase 6
Clip Video Prompt Compiler
+
0.1s Timeline Validator
+
Multi-shot / Camera Beat Compiler

Phase 7
Continuity Ledger
+
QA
+
Domain Identity QA
+
Targeted Retry

Phase 8
使用《真假美猴王》继续真实压力测试

Phase 9
稳定后接 Notion 自动同步

Phase 10
再考虑 P1 音频 / Storyboard / XLSX 等扩展
```

---

# 52. 最小成功定义

Skill 4 v1.1 的最小成功不是：

> “自动做完一条视频”。

而是：

> **对一条真实 60–90 秒视频，能够先用少量 LookDev Anchor 锁定视觉基线，再稳定把 ADP 转成可执行的资产 / Keyframe / Clip Prompt，真实生成后完成 QA、连续性记录与局部 Retry，并避免视觉方向错误扩散成批量返工。**

成功必须同时满足：

1. LookDev Gate 真正减少视觉方向返工；
2. Prompt Compiler 输出可直接执行；
3. 六类 Prompt 模板足够简洁；
4. 0.1s Timeline 可稳定编译；
5. Clip-first 能覆盖普通与高能节奏；
6. Identity / Scene / Domain 一致性可控；
7. 失败可定位并局部重跑；
8. Notion 不成为复杂 ERP，而只是清晰的生产 UI。

---

# 53. 下一步

本 Brief 冻结后，不再继续扩充 Skill 4 理论模块。

下一步执行：

```text
更新 Codex 中 Skill 4 v1.0 实现
        ↓
加入 LookDev / Visual Calibration Gate
        ↓
加入 6 类 Prompt Template
        ↓
加入 0.1s Timeline Validator
        ↓
继续《真假美猴王》真实生产
        ↓
孙悟空 Identity
        ↓
C01 Keyframe
        ↓
C01 Video
        ↓
QA
        ↓
C02
```

雷音寺 / Lingshan Domain 保持 Block，暂不继续调 Prompt。

只有新的真实失败证据出现时，再升级 Skill 4 v1.2。

---

# 54. v1.0 → v1.1 变更摘要

| 领域 | v1.0 | v1.1 |
|---|---|---|
| Style 验证 | 文字 ADP 后直接生产 | 新增 LookDev P0 Gate |
| 批量资产 | 可较早批量编译 | LookDev 通过前禁止批量 |
| 视觉基线 | 主要靠 Prompt / Style | Approved Prompt + Approved Image |
| 世界域 | Style 内统一处理 | Domain-level Visual DNA / Gate |
| 神魔风格 | 无统一强制模块 | Mythic Grandeur Binding |
| Prompt 输出 | 结构完整但偏长 | 少模块、类型专用、换行排版 |
| Character Prompt | 多字段语义结构 | 5 模块 |
| Scene Prompt | 多字段语义结构 | 6 模块 |
| Prop Prompt | 多字段语义结构 | 4 模块 |
| Graphic Prompt | 多字段语义结构 | 4 模块 |
| Keyframe Prompt | 多字段语义结构 | 5 模块 |
| Video Prompt | 多字段语义结构 | 6 模块 |
| 时间轴 | 模型 Adapter 自由编译 | 统一 0.1s 规划精度 |
| QA | 通用一致性 / 动作 / 镜头 | 新增 Domain Identity QA |
| Notion | 建议较多生产字段 | 精简字段 + Prompt 专用视图 |
| Date/Time | 未明确 | 当前只保留发布日期 |
| 当前 Fixture | 等待生成验证 | 已进入 LookDev + Domain Gate |

---

> **最终判断：Skill 4 v1.1 已达到可交给 Codex 实施的冻结程度。下一阶段应以真实生成结果驱动修订，而不是继续扩展理论架构。**
