# Style Profile：创作工艺过程短片

> **版本**：v1.0-zh  
> **源文档**：`工艺品制作过程短片.md`  
> **内部风格 ID**：`creative_process_craft_short`  
> **文档分类**：`production_playbook`（主）+ `hybrid_style_profile`（次）  
> **解析原则**：源文档中的工具调用、模型名称、暂停步骤与时长枚举仅作生产参考；本 Profile 只固化可复用的叙事、视听、连续性与声音规则。

---

## 0. 解析结论

这不是单一画风，而是一套面向书法、水彩、手绘、板绘和手工制作的**过程型短片视听语法**。稳定核心是：用“起—承—转—合”表现作品从空白到完成；以成品画面作为视觉锚点反推前序状态；让手、工具、载体和材料变化成为叙事主体；通过阶段化构图、光色、运镜与音乐推进沉浸感。

最重要的边界：示例色值、指定模型、固定镜头数、支持时长和后期参数不是永久风格。创作类型不同，材质和色彩必须随题材切换；用户参考素材优先于默认值。

## 1. 适配范围

### 强适配

- 书法、水彩、素描、板绘
- 手工、雕刻、缝制、陶艺等从无到有的制作过程
- 以手部操作、材料变化和成品揭晓为主要吸引力的短片
- 15–60 秒、单一创作任务、少角色或无角色内容

### 弱适配

- 以人物对白为主的剧情片
- 多地点、多时间线或复杂群像叙事
- 无可见制作过程的抽象知识内容
- 需要严格工业安全或工艺事实验证、但缺少来源材料的内容

## 2. 权威与路由

```yaml
authority:
  topic_direction: soft
  story_structure: medium
  visual_identity: medium
  material_continuity: hard
  cinematography: hard
  performance: hard
  sound_design: medium
  music_direction: medium
  production_model: none

routing:
  pre_content_modules:
    load:
      - creation_type_compatibility
      - rise_develop_turn_resolve_structure
      - visible_process_requirement
  audiovisual_modules:
    load:
      - material_and_tool_identity
      - stage_composition
      - stage_lighting
      - camera_progression
      - hand_performance
      - audio_visual_alignment
      - music_arc
      - continuity
  production_modules:
    load:
      - anchor_frame_workflow_reference
      - model_adapter_reference
      - duration_reference
      - assembly_reference
```

## 3. Pre-Content 规则

- 内容必须具有可观察的初态、加工过程和完成态。
- 推荐四段式：期待建立 → 沉浸推进 → 视觉突变 → 成品释放。
- “转”应来自真实的材料、画面或剪辑变化，不能凭空添加与创作无关的奇观。
- 若创作过程涉及真实技法、安全规范或历史信息，必须由用户资料或可靠来源提供；Style Profile 不补造步骤。
- 示例题材、示例工具和示例色值均不是 Canon。

## 4. 叙事与节奏

| 阶段 | 建议占比 | 叙事任务 | 画面重心 |
|---|---:|---|---|
| 起 | 约 15% | 建立期待与空白 | 载体、工具、待完成区域 |
| 承 | 约 60% | 展示制作推进 | 轮廓、上色、加工、材料形变 |
| 转 | 约 10% | 制造一次明确变化 | 快速切换、揭晓前的视觉冲击 |
| 合 | 约 15% | 释放满足感 | 完整成品与材质细节 |

占比是结构建议，不是固定时间码。镜头数量应按目标时长、动作复杂度和当前模型能力重新计算。

## 5. 视觉身份

### 核心对象

- 创作载体：纸张、画布、屏幕、工作台或材料基底
- 创作者双手：肤色、指甲、袖口、惯用手和入画方向保持一致
- 工具：笔、颜料、刻刀、针线、剪刀或雕刻工具
- 成品：作为视觉与色彩的最终参照

### 三层色彩体系

- 底色：载体或工作台的主体色
- 主色：线条、颜料或主要材料色
- 点缀色：最亮、最饱和或最具识别度的小面积色

原文的 60/30/10 仅作构图参考，不作为硬性像素占比。用户素材的真实色彩优先。

### 材质方向

- 书法：宣纸纤维、墨色浓淡、枯笔与朱砂印记
- 水彩：纸纹、水痕、晕染、透明叠色与颜料扩散
- 板绘：屏幕反光、触控笔、笔刷层叠与适度界面边缘
- 素描：纸张颗粒、炭粉或石墨、擦拭痕迹与高光
- 手工：木纹、织物、陶土、金属、碎屑与工具接触痕迹

## 6. 构图与镜头语言

- 起：中心留白，固定或极缓推近。
- 承—勾勒：固定机位，清楚呈现手和工具的动作因果。
- 承—上色或加工：三分法或偏左构图，允许轻微横移跟随动作。
- 承—细节：缓慢推近，突出材料、纹理和完成度变化。
- 转：一次短促、明确的视觉突变；不把整片做成连续炫技。
- 合：居中对称展示成品，缓慢拉远或留出静止阅读时间。
- 相邻镜头尽量避免景别和运镜完全相同。
- 一镜优先承载一个主要动作，动作描述到具体手指、工具、方向和材料反馈。

## 7. 光影系统

- 起：暖色侧顺光、低对比，保留期待感。
- 承—结构建立：中性顶光或侧顶光，让工具和轮廓可读。
- 承—颜色或材料高潮：略暖、对比增强，突出材料反应。
- 合：均匀柔光、低到中对比，真实还原成品颜色。

原文色温与明暗比属于生产参考，运行时可按实际场景校准。

## 8. 表演与连续性

```yaml
continuity:
  required: true
  lock:
    - 载体材质与尺寸
    - 创作者手部外观与惯用手
    - 袖口与配饰
    - 工具造型与颜色
    - 作品已完成区域
    - 三层色彩关系
    - 光线方向
```

- 每个后续镜头只能在前一状态基础上增加合理进度，不能让已完成部分倒退或跳变。
- 成品锚点适合作为全片一致性基准，但反推早期状态时必须减少真实进度，不能把成品痕迹泄露到起始阶段。
- 用户上传素材优先绑定，不应为同一对象无必要地重新生成。

## 9. 声音与音乐

- 声音焦点包括笔触、纸张、颜料、水、剪切、敲击、布料与工具摩擦。
- 动作声音与可见接触点同步；“转”可使用一次短促的掠过或冲击声。
- 音乐从轻柔铺垫逐步增强，在“转”附近短暂停顿或抽空，随后以更柔和的收束段托住成品展示。
- 背景音乐应作为独立音轨，不写入视频画面提示词。
- 60 秒左右内容可分成铺垫、推进、收束三段，但段数不锁死。

## 10. 负面约束

- 不让手指、工具或作品结构跨镜漂移
- 不让创作进度倒退或凭空完成
- 不把纸张、织物、陶土等材质生成成塑料表面
- 不用无意义快速运镜遮掩制作动作
- 不连续两镜重复同一景别和同一运动
- 不在画面中自动加入文字、水印或无关界面
- 不把默认模型、分辨率或时长枚举视为风格本体

## 11. 来源冲突与降级项

```yaml
known_source_conflicts:
  - 四段比例与模型离散生成时长不能天然严丝合缝，需由后期裁剪重新对齐总时长
  - 15 秒 3 镜、30 秒 5 镜、60 秒 7 镜只是参考数量，不能同时作为所有创作类型的硬规则
  - 原文固定“右手执笔、从画面右侧进入”，遇到左利手创作者或参考素材相反时必须由素材覆盖
  - 固定生成时长受具体模型能力约束，不能成为永久风格规则
  - 锚点图反推顺序属于生产方法，不等于叙事必须倒序呈现

production_adapter_reference:
  replaceable: true
  source_mentions:
    - Final_Video_Spec.md
    - Google Veo3.1 Fast
    - Seedance 2.5
    - Nano Banana Pro
    - Mureka 8
    - Suno 5
```

## 12. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 工艺品制作过程短片.md
style_profile:
  style_id: creative_process_craft_short
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: process_creation
    story_direction: rise_develop_turn_resolve
  audiovisual_modules:
    visual_identity: material_process_documentation
    cinematography: stage_based_progression
    performance: hand_tool_material_interaction
    sound: synchronized_craft_foley
    continuity: anchor_final_state_with_progress_lock
  production_modules:
    anchor_frame_workflow: reference_only
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 工艺品制作过程短片.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: narrative_and_audiovisual
        method: normalized
      - module: production_workflow
        method: direct
      - module: missing_fields
        method: inferred_structure_only
```
