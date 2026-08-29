# Style Profile：乐高积木人仔电影动画

> **版本**：v1.0-zh  
> **源文档**：\`D:\AI 视频\Flova技能\乐高风格短片.md\`  
> **源文档标题**：\`乐高风格短片\`  
> **内部风格 ID**：\`lego_minifigure_cinematic_animation\`  
> **对齐规范**：\`Skill 3 — Unified Style Profile Schema v1.0\`  
> **库状态**：\`pending_review\`  
> **解析原则**：将乐高积木人仔的造型、积木化场景、可视化动作和镜头规则提炼为可复用的 Style Core；模型、分辨率、占位符、工具调用和阶段流程保留在可替换的 \`production_modules\`。

---

## 0. 解析结论

这份资料不是纯粹的美术风格说明，而是 **乐高积木人仔视听风格档案 + 短片生产流程手册**。它最有价值的可复用核心是：

> **角色必须保持 LEGO Minifigure 的比例、塑料材质和印刷细节；环境必须遵循积木搭建逻辑；叙事动作必须能被画面直接验证；镜头、音效和角色连续性共同服务于一个可执行的短片目标。**

本次解析将以下内容提升为 Style Core：

- LEGO Minifigure 比例与官方积木人仔视觉语法
- ABS 塑料质感、清晰的角色印刷细节和稳定的外观锁定
- 建筑、道路、家具、车辆、树木、水体等环境的积木几何结构
- 角色与场景作为独立 \`key element\` 管理，并在镜头间保持一致
- 只描述可视化动作，不把心理活动直接写成画面动作
- 按 \`Sequence → Shot Group → Shot\` 组织叙事镜头
- 景别、运镜、动作、对白和音效形成一条可执行的镜头记录
- 字幕不进入 Shot 画面设计，统一留给后期合成
- BGM、环境音、动作音和旁白作为独立音频层管理

以下内容不属于永久风格核心：GPT Image 2、Seedance 2.5、MiniMax Speech 2.8 HD、Suno 5、2K、480p、30 秒上限、具体提示词占位符及源文档中的工具调用名称。这些内容只作为当前源文档的 \`production_adapter_reference\`。

## 1. 文档分类

\`\`\`yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: false
  flags:
    has_topic_direction: partial
    has_story_direction: partial
    has_worldview: true
    has_character_canon: partial
    has_visual_system: true
    has_sound_system: partial
    has_voice_system: partial
    has_bgm_system: partial
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
\`\`\`

**分类判断**：源文档既定义了画面和声音如何呈现，也规定了从创意分析到最终合成的生产顺序，因此不能只当作纯视觉风格。它没有提供某个具体故事、角色 Canon 或系列世界观；其中“主题、角色、场景、冲突、情绪、目标受众”是输入分析项，不是固定内容事实。

## 2. 权威与路由

\`\`\`yaml
authority:
  character_identity: hard
  scene_geometry: hard
  lego_material_language: hard
  shot_structure: hard
  visible_action: hard
  dialogue_and_audio_fields: medium
  music_direction: medium
  story_direction: soft
  production_model: none
  output_resolution: none

routing:
  pre_content_modules:
    load:
      - story_input_analysis
      - character_scene_conflict_extraction
      - audience_and_emotion_input
  audiovisual_modules:
    load:
      - lego_minifigure_identity
      - brick_built_scene_geometry
      - key_element_continuity
      - sequence_shot_group_shot_structure
      - visible_action_performance
      - cinematic_shot_language
      - dialogue_and_sound_cues
      - independent_audio_layers
      - postproduction_caption_boundary
  production_modules:
    load:
      - milestone_confirmation_workflow
      - reference_asset_generation
      - multimodal_video_generation
      - narration_and_bgm_adapters
      - prompt_template_reference
      - final_assembly_reference
\`\`\`

### 路由边界

- \`pre_content_modules\` 只负责接收和整理用户提供的故事输入，不替用户补写主题、角色事实或剧情结论。
- \`audiovisual_modules\` 定义永久可复用的画面、表演、镜头和声音规则。
- \`production_modules\` 记录源文档的执行方法，但必须由当前项目、适配器和审批状态重新验证。
- 源文档中的“等待确认”属于流程建议；在当前项目中是否采用，服从项目现行的 staged approval gate，不由本 Profile 单独授权。

## 3. 视觉身份：乐高积木人仔世界

### 3.1 角色规则

- 所有角色采用 LEGO Minifigure 比例与风格，不使用真人比例、写实人体比例或 Anime 比例。
- 角色应呈现硬质塑料或 ABS 塑料的干净表面、明确轮廓和可识别的印刷细节。
- 每个角色至少记录：发型颜色与款式、服装配色与图案、配件、面部印刷细节。
- 角色跨镜头必须保持头部、发型、服装、配件和面部印刷的一致性。
- 若剧情包含变装或时间跨度，应把每个造型作为独立身份状态记录，不得在镜头之间隐式切换。
- 参考图未能确认的细节保持 \`null\` 或标记为待确认，不得为了生成方便擅自补全为 Canon。

### 3.2 场景规则

- 建筑、道路、家具、车辆、树木和水体等场景元素遵循积木搭建逻辑。
- 优先使用积木几何结构、可辨认的连接关系和明确的模块边界。
- 避免把场景处理成无来源的有机曲面或脱离积木结构的写实建筑。
- 场景参考必须标注关键道具、角色站位和动作发生区域之间的位置关系。
- 具体建筑样式、地理地点、道具品牌和故事时代不由本 Profile 固定，须来自当前项目输入。

### 3.3 质感与呈现

- 角色与场景共同维持官方 LEGO 风格的积木化观感。
- 适合使用电影化照明和高细节渲染，但“电影质量”只表示呈现目标，不锁定某个模型或渲染器。
- 具体色板、光比、天气、时段和背景复杂度由当前项目导演方案定义；源文档没有提供足够细节时保持未指定。

## 4. 镜头与叙事组织

### 4.1 三层结构

镜头应按以下层级组织：

\`Sequence（序列） → Shot Group（镜头组） → Shot（单镜头）\`

源文档建议每个 \`Shot Group\` 服务一个剧情目标，并以 8–30 秒、6–16 个镜头作为参考范围。这个范围属于生产估算，不是永久风格硬限制；实际时长应服从当前项目的内容密度、生成能力和成本预算。

### 4.2 Shot 最小字段

每个 \`Shot\` 至少应能回答以下问题：

- 景别：\`ECU / CU / MCU / MS / MLS / LS / ELS\`
- 运镜：\`Static / Push In / Pull Out / Pan / Tilt / Tracking / Orbit / Handheld\`
- 角色正在做什么，以及动作涉及的身体部位和空间关系
- 完整对白（若有）
- 环境音、动作音和转场音
- 该镜头与前后镜头的连续性关系

景别和运镜应服务剧情，不为炫技而添加没有叙事目的的运动。心理状态、抽象意图和不可验证的内心活动不能替代可视化动作。

### 4.3 文字与字幕边界

- Shot 层级不设计画面内字幕、浮现文字或后期标题。
- 字幕、标题和其他文字图形统一在后期合成阶段处理。
- 除非当前项目另有经过确认的文字资产，角色参考图和场景参考图不应出现无关文字、品牌标识或随机字样。

## 5. 表演与连续性

### 5.1 可视化表演

- 用“拿起咖啡杯”“转头看向电脑”这类可观察动作描述表演。
- 不用“陷入思考”“感到痛苦”等只能由心理推断得到的描述替代动作。
- 动作应与 LEGO 人仔的关节、比例和道具尺度相容；不要求超出角色结构能力的真人式细节动作。
- 动作设计应保留清晰的起始状态、动作变化和结束状态，便于镜头连续性检查。

### 5.2 连续性锁定

跨镜头至少锁定：

- 角色数量、身份和造型状态
- 发型、服装、配件与面部印刷
- 场景积木结构、关键道具和空间方位
- 角色与道具的持握关系
- 角色进入、离开和站位关系
- 前一镜头的结束状态与后一镜头的开始状态

不能从源文档推断出的连续性字段保持 \`null\`，由当前项目的 Series Canon、Director Package 或 LookDev 基线补充。

## 6. 声音与音乐

### 6.1 独立音频层

- \`BGM\`：记录音乐风格、情绪、节奏和起止区间；是否分段由当前故事的情绪转折决定。
- 环境音：记录城市、室内、自然环境或其他空间底噪。
- 动作音效：与积木碰撞、脚步、道具操作和环境反馈等可视动作对应。
- \`VO\`：如叙事依赖旁白，应作为独立音频层记录说话者声音特征、完整脚本和镜头区间。
- 对白应直接写入对应 Shot 的对白字段，不能只写“有对白”。

### 6.2 声音边界

源文档确认了音频分层方法，但没有给出固定音乐风格、音色、响度或混音标准。具体音乐与声音选择保持为项目级决定；生成在视频内还是独立生成，属于当前适配器决定。

## 7. 参考资产与提示词语法

以下内容来自源文档，可作为生产适配器参考，不是永久 Style Core：

- 角色参考图可采用横版拼排的 turnaround sheet，包含正面、侧面、背面和表情视图。
- 场景参考图可按剧情需要制作白天、夜晚和关键动作版本。
- 视频镜头可同时绑定相关角色与场景参考图；前一镜头视频仅在连续性确实需要时作为可选参考。
- 视频提示词建议按“主体 → 动作节拍 → 场景环境 → 景别与运镜 → 光效 → LEGO 风格锚定”组织。
- 源文档使用 \`<<<image_1>>>\` 形式的图像占位符、\`{对白}\` 和 \`<音效>\` 标记；这些语法只有在当前生产适配器明确支持时才可采用。
- 源文档建议固定加入 \`no subtitles\`；只有当前镜头确实存在独立旁白轨时，才考虑 \`no music\`。这属于适配器负面提示词，不是 Style Core。

## 8. 生产流程参考与审批边界

源文档给出以下生产顺序：输入分析 → 剧本 → Final Video Spec → 故事板 → 参考资产 → 逐镜头视频 → 音频 → 最终合成。它还要求主要阶段完成后暂停并等待确认。

本次解析将其记录为流程参考，不能直接替当前项目授权以下动作：

- 生成角色、场景、视频、旁白、BGM 或音效
- 调用具体模型或外部工具
- 消耗付费额度
- 自动越过人类确认节点
- 最终剪辑、发布或形成 Final Master

当前项目如要执行，应重新确认目标资产、适配器、规格、成本上限、QA 标准和停止条件；每个付费资产仍需要独立的生成门槛。

## 9. 来源冲突、缺失字段与风险

\`\`\`yaml
known_source_conflicts:
  - source_skill_scope_and_visual_style_are_mixed: true
  - planner_order_and_dependency_notation_are_ambiguous: true
  - shot_group_duration_and_shot_count_are_recommendations_not_style_locks: true
  - source_models_and_resolutions_are_adapter_specific: true
  - source_requires_milestone_confirmation_but_does_not_define_current_project_gate: true

missing_fields:
  - fixed_color_palette
  - fixed_lighting_system
  - fixed_music_genre_or_tempo
  - continuity_schema_for_scene_state
  - voice_identity_canon
  - final_assembly_specification

risk_notes:
  - LEGO、官方 LEGO 风格及相关图形标识可能涉及商标或内容权利，使用时需由项目方确认授权边界。
  - “电影质量”“高细节”等目标较宽泛，不能替代明确的画幅、镜头、材质和 QA 标准。
  - 角色参考图的三视图并不自动证明所有侧面和背面细节已被用户确认。
  - 一次生成完整角色、场景和连续动作存在身份漂移、道具错位和动作泄漏风险。
  - 源文档没有定义失败重试策略；不得从该文档推导自动重试或无限生成。
\`\`\`

## 10. 机器可读摘要

\`\`\`yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:\\AI 视频\\Flova技能\\乐高风格短片.md
style_profile:
  style_id: lego_minifigure_cinematic_animation
  version: 1.0-zh
  classification: hybrid_style_profile
  pre_content_modules:
    input_analysis: theme_character_scene_conflict_emotion_audience
    story_canon: null
  audiovisual_modules:
    visual_identity: lego_minifigure_and_brick_built_world
    material_language: abs_plastic_like_clean_printed_details
    scene_geometry: brick_based_geometric_construction
    shot_structure: sequence_shot_group_shot
    performance: visible_actions_only
    cinematography: story_serving_shot_size_and_camera_motion
    audio_layers: bgm_environment_action_vo
    caption_boundary: postproduction_only
    continuity: character_scene_prop_and_state_lock
  production_modules:
    workflow: milestone_confirmation_reference
    character_reference: turnaround_sheet_reference
    scene_reference: day_night_action_variants_reference
    video_generation: multimodal_reference_video_adapter
    voice_generation: narration_adapter_reference
    music_generation: instrumental_adapter_reference
    final_assembly: unspecified
    model_and_resolution: replaceable_runtime_adapter
  provenance:
    source_documents:
      - file: D:\\AI 视频\\Flova技能\\乐高风格短片.md
        sha256: 4dd560d3b3d8db064766cbd54bfafdbbe319a40516af4158d1e2821505e610f2
        extraction: direct_and_normalized
    extracted_modules:
      - module: lego_visual_identity
        method: normalized
      - module: character_and_scene_rules
        method: direct_and_normalized
      - module: shot_and_audio_schema
        method: direct
      - module: production_workflow_and_prompt_templates
        method: direct
      - module: conflicts_missing_fields_and_risks
        method: inferred_structure_only
\`\`\`

## 11. 使用状态

本文件是对指定源文档的中文 Style Profile 解析结果。它已保留源文档来源、哈希和模块路由，但尚未经过独立的权威冲突复核，因此保持 \`pending_review\`。在明确接受前，不应把它当作 \`ready\` Profile，也不应让其中的模型、分辨率、提示词语法或生成流程覆盖当前项目的 Series Canon、导演方案和生产门槛。

