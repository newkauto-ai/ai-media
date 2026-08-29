# Style Profile：东方天宫云上古典幻想

> **版本**：v1.0-zh  
> **源文档**：\`C:\Users\Roy\Downloads\天宫画面&视频_Skill介绍.md\`  
> **源文档标题**：\`东方天宫\`  
> **内部风格 ID**：\`eastern_cloud_celestial_palace\`  
> **对齐规范**：\`Skill 3 — Unified Style Profile Schema v1.0\`  
> **库状态**：\`pending_review\`  
> **来源哈希**：\`11e72b578215a9566b811c283af5e67ff0158bb6f503c09f472d0d14567a5eef\`  
> **解析原则**：提取云上海天、东方古典建筑、极小人物尺度、冷中性色与局部暖光等可观察规则；模型、画幅、提示词、引用资料读取和工作流属于可替换的 \`production_modules\`。

---

## 0. 解析结论

这是一份以**环境主导的东方天宫幻想写实**为核心的视听风格档案，同时包含提示词写作和画面审阅流程。它的核心不是堆叠龙、灯笼、法阵等东方符号，而是用：

- 云海之上的宏大古典宫殿与楼阁
- 古松、白石、长阶、露台和山体形成的尺度系统
- 极小人物作为比例和叙事锚点
- 冷青灰天气与局部低角度琥珀光的冷暖关系
- 深层云海、空气透视和清晰剪影
- 缓慢、克制、仪式化的人物动作

共同建立一个庄严、宁静、沉思、超然的东方天庭世界。

它与已有的“幽暗中式仙宫”风格相邻，但不等同：本 Profile 以**云上远景和环境整体**为主，未要求幽暗宫殿前景框架，也未要求古代宇宙文明线索或静观雅事作为固定模块。

## 1. 文档分类

\`\`\`yaml
classification:
  primary: audiovisual_style_profile
  secondary:
    - environmental_style_profile
    - production_playbook
  full_series_canon: false
  flags:
    has_topic_direction: partial
    has_story_direction: false
    has_worldview: true
    has_character_canon: false
    has_visual_system: true
    has_sound_system: false
    has_voice_system: false
    has_bgm_system: false
    has_prompt_templates: true
    has_model_specific_rules: false
    has_production_workflow: true
\`\`\`

**分类判断**：源文档主要定义环境视觉、构图家族、变化方向、负面约束和审阅清单；它不提供具体故事、角色设定、对白、声音或音乐系统。工作流程属于生产参考，不是风格授权。

## 2. 权威与路由

\`\`\`yaml
authority:
  environment_visual_identity: hard
  scale_and_composition: hard
  architecture_and_material: hard
  color_and_light: hard
  character_scale_and_action: medium_high
  sound_and_music: none
  story_direction: soft
  production_model: none
  output_resolution: none

routing:
  pre_content_modules:
    load:
      - subject_and_use_selection
      - composition_family_selection
      - environment_dominance_check
      - story_character_compatibility
  audiovisual_modules:
    load:
      - cloud_celestial_environment
      - eastern_classical_architecture
      - tiny_scale_character_anchor
      - cool_neutral_palette_with_local_warm_light
      - atmospheric_perspective_and_silhouette
      - restrained_ritualized_action
      - clean_frame_and_reference_artifact_exclusion
      - architectural_and_material_continuity
  production_modules:
    load:
      - reference_material_dependency
      - prompt_recipe_adapter
      - image_generation_adapter
      - video_or_motion_adapter
      - composition_variant_review
      - delivery_checklist
\`\`\`

### 路由边界

- \`pre_content_modules\` 负责选择主体、用途、画幅、是否有人物和构图家族，不替当前项目生成故事。
- \`audiovisual_modules\` 定义环境、尺度、光色、动作和画面清洁度。
- \`production_modules\` 记录源文档的提示词和审阅工作流；具体模型、分辨率、调用工具和生成步骤由当前项目重新确认。
- 源文档要求读取 \`references/style-language.md\` 和 \`references/prompt-recipes.md\`，但本次未提供这两个引用资料，因此不把其未见内容补写为规则。

## 3. 视觉身份

### 3.1 环境主导

- 宫殿、露台、长阶、云海或云中山体是主要主体。
- 人物只承担尺度、方向和叙事锚点作用，不应与建筑和云海争夺视觉中心。
- 画面应完整呈现一个连贯的目的地或空间关系，而不是只截取服装特写、局部装饰或人物肖像。
- 氛围保持宏大、安静、沉思、超然；避免拥挤、喧闹、节庆化和战斗化。

### 3.2 东方建筑与自然

可使用但不应机械堆满：

- 东方木构宫殿、深色屋顶瓦顶和舒展飞檐
- 白色雕刻石材、长阶、露台、古松
- 云海、远山、云上古城、仙山楼阁和云中庭院
- 仙鹤、莲花、月洞门、云纹石柱、格栅屏风、低矮亭案
- 落入云层的瀑布、远方浮云、悬挂饰物和崖边庭院

风格的核心来自尺度、光线、构图和克制，不来自元素数量。每幅画只选择少量次要元素，避免成为“东方符号贴”。

### 3.3 建筑可读性

- 建筑结构应能读出屋顶、飞檐、柱廊、石材、阶梯和露台之间的关系。
- 长距离引导线、单点透视、对称轴或自然框景可用于加强建筑性。
- 结构保持稳定，避免屋檐数量、柱体、阶梯和楼阁在画面中融化、弯曲或无理由变化。
- 更写实时减少不可能的装饰密度，但保留宏大尺度和有方向的光线。
- 更幻想可增加悬浮地基、云雾支撑或落入虚空的瀑布，但必须保留材质、重力和空间层次线索。

## 4. 构图家族

正式项目应先选一个主构图家族，再做局部变化：

1. **宏大中轴登临**：以长阶、宫门或中轴线引向云上目的地。
2. **古松或建筑框住云海全景**：前景框景，中景结构，远景云海和山体。
3. **露台仪式或安静聚会**：建筑与人物动作形成尺度锚点，环境仍占主导。
4. **孤身临云远眺**：极小人物与辽阔云海形成距离和沉思感。
5. **室内通向室外的层叠揭示**：通过门、窗、廊柱或屏风逐层揭示外部天宫。

需要多个方案时，优先切换构图家族，而不是只替换小道具。每个画面应有一个主导构图法则，次要元素服务于该法则。

## 5. 色彩、光线与空间

### 5.1 主色关系

- 天气与大环境以 slate-blue、青灰、冷中性色和低饱和色相为主。
- 低角度琥珀色阳光作为局部照明，不能把整幅画套成统一橙色滤镜。
- 冷色承担空气、距离和宁静；暖光只强调屋檐、石材、云雾边缘或局部叙事区域。
- 云海、山体和建筑之间要有清晰的剪影层级，不能因浓雾而失去结构。

### 5.2 空间深度

画面至少应能读出三层关系：

- 前景：建筑边缘、古松、石柱、月洞门、屋檐或露台框景
- 中景：宫殿、楼阁、长阶、亭案或尺度人物
- 远景：深层云海、山体、云中城市、瀑布或天际空间

使用空气透视、云层厚度和远近对比建立宏大尺度，不使用单一平面背景或纯装饰性雾气。

### 5.3 材质

- 木材、瓦片、石材和古松应具有可追踪的纹理、受光和风霜痕迹。
- 白石与雕刻石材可以清洁但不能塑料化；古松应保留真实树皮与枝干结构。
- 云雾具有体积和层次，不能完全遮蔽宫殿和山体。
- 水体、石材和木材保持跨画面连续，不因变化方案而随意更换材质。

## 6. 人物与动作

### 6.1 人物尺度

- 默认人物占画面高度约 1%–4%；超广角或大远景优先控制在 1%–3%。
- 只有明确的露台叙事场景才允许接近 5%，且宫殿或云海仍然是主角。
- 人物接近剪影或远景轮廓，不能通过可辨认的脸部细节、服装特写或英雄姿态夺取主体地位。
- 默认使用超广角或广角，除非项目明确要求近景。

### 6.2 可视化动作

动作保持缓慢、克制、仪式化，可使用：

- 行走、乘舟、远眺
- 奉茶、低声交谈
- 在露台停留、缓慢转身或沿长阶登临

不要把战斗、追逐、发法术、奔跑、节庆表演或宏大群体动作写入默认风格。人物的故事功能来自位置、方向和尺度，而非复杂表演。

### 6.3 风与环境响应

若画面需要风：

- 衣袂、长袖、薄纱、古松枝叶、云雾和水面应对同一方向的低幅环境动力作出响应。
- 风应缓慢、克制，不形成暴风翻卷。
- 不新增与首帧无关的人物、道具、灵动生物或动作状态。

## 7. 可选微动态与画面连续性

视频或动态化阶段只对既有画面做低强度变化，可选择 1–3 项：

- 云层缓慢移动
- 薄雾穿过建筑或古松
- 瀑布稳定下落
- 松针轻摆
- 水面微波
- 悬挂饰物轻微摆动
- 人物衣袂低幅起伏
- 已存在的雅事或远眺动作发生一次克制变化

建筑、主奇观、人物位置和既有道具保持稳定；镜头结束前回到清晰、完整的空间构图。

## 8. 参考图痕迹与清洁画面

### 8.1 必须排除

- 文字、字幕、标题、印章、签名、Logo、水印
- 黑色侧边、截图边框、手机提示条
- 播放器控件、顶部叠层、界面残留和版式痕迹
- 源参考图中与当前画面无关的品牌或平台标记

### 8.2 负面约束

- 不变成服装特写或人物肖像主导画面。
- 不混入日式神社、东南亚寺庙、欧洲奇幻城堡或现代摩天楼。
- 不变成平面水墨、动漫、塑料感三维或手游角色渲染。
- 不堆满龙、灯笼、熊猫、法阵、书法和无关符号。
- 不使用游戏海报式构图、泛武侠打斗或发法术视觉。
- 不让浓雾遮蔽结构，也不让细节堆积却缺乏空气透视。

## 9. 生产层参考

以下内容属于源文档的生产适配参考，不是永久 Style Core：

- 根据主体、用途、画幅比例和是否需要人物建立项目规格。
- 先选构图家族，再按前景、中景、目的地和云海远景组织画面。
- 固定风格锚点后，每次只添加少量次要元素。
- 最终提示词加入无文字、无字幕、无标志、无水印、无签名、无黑边和无界面叠加约束。
- 需要多个方案时改变构图家族；生成或描述后按结构、尺度、色彩、光线和清洁度检查。
- 具体引用资料、模型、画幅、分辨率、提示词格式、生成流程和交付界面由当前适配器重新确认。

本轮没有读取源文档所指向但未提供的引用资料，也没有生成图像、视频或提示词执行包。

## 10. 缺失字段、冲突与风险

\`\`\`yaml
known_source_conflicts:
  - source_describes_both_visual_style_and_agent_skill_workflow: true
  - reference_material_paths_are_mentioned_but_not_supplied: true
  - person_scale_ranges_vary_by_composition_family: true
  - optional_elements_can_conflict_with_minimal_symbol_density: true

missing_fields:
  - story_or_topic_canon
  - character_identity
  - dialogue_and_voice_system
  - sound_design
  - music_direction
  - exact_lighting_measurements
  - model_and_output_specification
  - reference_style_language_document
  - reference_prompt_recipes_document

risk_notes:
  - 东方符号堆叠会削弱宏大尺度和宁静感，应优先控制构图、光线和空气透视。
  - 极小人物不应被错误生成成不可读的随机点；其位置、方向和剪影仍需可审计。
  - 结构性建筑必须保持连续，不能用浓雾或高光掩盖变形。
  - “东方天宫”属于可复用视觉方向，不自动代表真实宗教、历史建筑或特定文化事实。
\`\`\`

## 11. 机器可读摘要

\`\`\`yaml
fixture_only: false
library_status: pending_review
normalized_from_source: C:\\Users\\Roy\\Downloads\\天宫画面&视频_Skill介绍.md
style_profile:
  style_id: eastern_cloud_celestial_palace
  version: 1.0-zh
  classification: audiovisual_style_profile
  pre_content_modules:
    subject_use_and_aspect_ratio: runtime_selected
    composition_family: five_family_reference
    story_canon: null
    person_presence: optional
  audiovisual_modules:
    visual_identity: cloud_above_eastern_classical_celestial_palace
    environment_dominance: hard
    character_scale: tiny_scale_anchor
    color_system: low_saturation_cool_neutral_with_local_amber_light
    spatial_depth: foreground_midground_destination_cloud_sea
    atmosphere: volumetric_clouds_air_perspective_clear_silhouettes
    performance: slow_restrained_ritualized_actions
    sound_design: null
    music_direction: null
    clean_frame: no_text_no_logo_no_watermark_no_border_no_ui
    continuity: architecture_material_scale_light_and_cloud_layer
  production_modules:
    reference_dependency: references_not_supplied
    prompt_recipe: replaceable
    image_generation: replaceable
    video_or_motion_generation: replaceable
    variation_strategy: change_composition_family_first
    review_checklist: source_defined_visual_and_clean_frame_checks
    generation_authorized: false
  provenance:
    source_documents:
      - file: C:\\Users\\Roy\\Downloads\\天宫画面&视频_Skill介绍.md
        sha256: 11e72b578215a9566b811c283af5e67ff0158bb6f503c09f472d0d14567a5eef
        extraction: direct_and_normalized
    extracted_modules:
      - module: environmental_visual_identity
        method: direct_and_normalized
      - module: composition_and_scale_rules
        method: direct_and_normalized
      - module: clean_frame_constraints
        method: direct
      - module: workflow_and_prompt_reference
        method: direct
      - module: missing_fields_and_risks
        method: inferred_structure_only
\`\`\`

## 12. 使用状态

本文件是对指定 Skill 介绍文档的中文 Style Profile 解析结果。它与已有的“幽暗中式仙宫” Profile 保持独立，当前状态为 \`pending_review\`。在明确接受前，不应注册为 \`ready\`，也不应让源文档中的工作流、引用路径或任何运行时建议覆盖当前项目的 Series Canon、导演方案和生产审批门槛。

