# Style Profile：治愈系独居日常 Vlog

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/治愈系日常系独居生活风格Vlog.md`  
> **源文件 SHA-256**：`14E3E30895ABCA548EE0E711D06CCF477194A1A8667DC14DEF43D662FF5C95DA`  
> **内部风格 ID**：`healing_solo_daily_vlog`  
> **库状态**：`pending_review`  
> **重要判断**：该文档完整定义了题材、节奏、连续性和声音方式，但没有锁定唯一美术媒介；`art_style` 必须由当前项目或系列设定提供。

---

## 0. 解析结论

这是一份**治愈独居生活的叙事样式 + 连续剧规则 + 生产手册**，而不是一份完整、独立的纯视觉风格。最稳定的 Style Core 是：

- 用具体、低强度的生活动作讲故事，不使用解释性旁白；
- 固定机位或极缓慢推拉，镜头舒缓，避免快切和抖动；
- 低饱和、暖色、柔和漫反射，单画面主色系不宜过多；
- 角色、换装、场景布局、光源和道具位置跨镜锁定；
- 咖啡、烹饪、整理、阅读、洗衣、植物、雨天和夜灯等日常细节承担情绪表达；
- 自然环境声保留，背景音乐低密度、无人声，不压过生活拟音；
- 连续剧以同一角色和场景资产复用维持系列统一。

源文档将“吉卜力上色、赛璐璐、水彩绘本”等只作为可选示例，不能据此认定默认美术风格。标准化结果因此保留 `visual_medium: runtime_required`。

---

## 1. 文档分类

```yaml
classification:
  primary: narrative_style_bible
  secondary:
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: partial

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_character_canon: false
    has_visual_system: partial
    has_performance_system: true
    has_sound_system: true
    has_voice_system: true
    has_music_system: true
    has_continuity_system: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 独居生活、晨间和夜间例行活动
- 咖啡、烹饪、阅读、收纳、手作、植物照料
- 轻情绪 Vlog、无旁白生活片段
- 同一角色的多集日常系列

### 中等适配

- 双人或宠物陪伴的低冲突日常
- 轻产品植入、家居和生活方式内容
- 季节、天气和节日氛围短片

### 弱适配

- 高冲突剧情、追逐、打斗、恐怖
- 高频知识口播、强销售信息密度
- 依赖写实证据或复杂现场纪实的内容

---

## 3. 权威与缺口

```yaml
authority:
  topic_direction: medium
  story_direction: high
  visual_medium: runtime_required
  color: high
  lighting: high
  character_continuity: hard
  environment_continuity: hard
  cinematography: hard
  performance: high
  editing_rhythm: hard
  sound_design: high
  narration: hard_none
  music_direction: high
  production_model: none
```

本 Profile 可以单独约束“怎样拍、怎样演、怎样剪、怎样听”，但不能单独回答“画面是二维手绘、水彩、赛璐璐、三维还是其他媒介”。在进入 LookDev 前必须补充一个兼容的视觉媒介 Profile 或当前项目覆盖值。

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: high
    preferred:
      - 独居日常
      - 低冲突生活片段
      - 自我照料
      - 温柔期待与满足
    avoid:
      - 激烈对抗
      - 快速信息堆叠
      - 恐怖与强刺激

  topic_direction:
    authority: medium
    value:
      - 清晨准备
      - 一人料理
      - 雨天居家
      - 夜间阅读
      - 整理与照料

  story_direction:
    authority: high
    value: 一个具体生活目标 → 缓慢准备 → 细节完成 → 安静满足

  theme_expression_rules:
    authority: high
    value: 通过动作、环境变化和物件状态表达，不使用旁白解释
```

---

## 5. 视觉身份与待补参数

### 已定义

- 低饱和暖色基调。
- 柔和漫反射和明确的窗光或室内灯方向。
- 一个画面不超过约两个主色系。
- 画面整洁、留有角色活动空间，道具数量受控。
- 避免强烈对比、高饱和撞色、赛博朋克和机械科幻。

### 未定义

- 固定的画种或渲染媒介。
- 固定线条、笔触、材质和角色比例。
- 固定时代、建筑地域或家具风格。

```yaml
visual_identity:
  visual_medium: runtime_required
  palette: 低饱和暖色
  main_color_count: 建议不超过2个主色系
  lighting: 柔和漫反射，光源方向明确
  composition: 主体清楚，空间留有生活动作区域
  avoid:
    - 高饱和撞色
    - 强烈冷暖冲突
    - 赛博朋克
    - 机械科幻
```

源文档负面词中包含“写实摄影风”，说明原始流程倾向非写实画风；但它没有指定唯一替代媒介，因此不能推断为某一种具体动画风格。

---

## 6. 角色与换装系统

- 锁定发型、发色、瞳色、肤色、脸型和体型。
- 每套服装作为独立 Look 记录，服装款式与配色不能在单镜中临时改写。
- 同一集与跨集复用相同角色 Canon；换装只切换已批准 Look。
- 角色元素图是生产手段，永久规则是“外观唯一权威来源”和“镜头不重复定义外观”。

```yaml
character_visual:
  identity_lock:
    - 发型发色
    - 瞳色与肤色
    - 脸型
    - 体型
  wardrobe_system:
    look_variants: explicit_only
    shot_override: forbidden
  series_reuse: required
```

---

## 7. 场景与道具系统

- 每个场景单独锁定空间布局、家具位置、光源位置与色温。
- 同一场景跨镜复用时，床、桌、窗、灯、盆栽、蜡烛等不能随机换位。
- 跨场景复用的串灯、盆栽、杯具等可建立独立道具 Canon。
- 所有道具必须与已选视觉媒介一致，不能在手绘环境中突然出现写实摄影道具。

```yaml
environment:
  locks:
    - 空间布局
    - 家具与道具位置
    - 光源方向
    - 色温
    - 主色关系
  requirement: 留出人物自然站立、坐立和操作物件的区域
```

---

## 8. 镜头与表演

### 镜头

- 固定机位、极缓慢推进、极缓慢拉远、轻微摇摄和平移。
- 常用全景交代空间，中近景观察动作，特写表现蒸汽、液体、手部和小物件状态。
- 一个镜头对应一个场景内的完整生活片段，源文档建议约 6–10 秒。

### 表演

- 动作具体、微小、连续：搅动、擦拭、折叠、浇水、翻页、抬眼、轻笑。
- 用肢体和微表情表达感受，不写空泛的“很治愈、很幸福”。
- 动作与道具必须有接触、反馈和完成状态。

```yaml
performance:
  baseline: 低强度、生活化、动作完整
  sequence:
    - 接近或准备
    - 接触物件
    - 物件反馈
    - 微表情变化
    - 安静完成
  avoid:
    - 夸张表演
    - 快速多动作堆叠
```

---

## 9. 叙事与剪辑节奏

```yaml
editing_rhythm:
  baseline: 舒缓
  shot_duration_reference: 6-10秒，通常不超过15秒
  transition:
    default: 柔和淡入淡出
    duration_reference: 0.5-1秒
  series_transition: 集与集之间可使用更长淡出淡入
  avoid:
    - 快切
    - 抖动
    - 闪烁转场

episode_emotion_arc:
  example: 安静 → 期待 → 满足
  authority: soft
```

情绪弧线示例不是固定剧情；每集仍应由当前脚本明确具体行动和状态变化。

---

## 10. 声音与音乐

```yaml
sound_design:
  preserve:
    - 咖啡机
    - 雨声
    - 杯具轻碰
    - 翻页
    - 烹饪细响
    - 室内环境底噪
  behavior: 与动作同步，保留小尺度触感

voice_system:
  narration: false
  dialogue: 默认极少或无
  storytelling: 依靠画面、拟音与音乐

music_direction:
  required: true
  vocal: false
  mood:
    - 治愈
    - 温暖
    - 安静
  density: low
  low_frequency: soft
  mix: 不压过生活环境声
```

---

## 11. 连续剧 Canon

```yaml
series_bible:
  reusable:
    - 主角身份
    - 已批准换装
    - 场景布局
    - 道具位置
    - 视觉媒介字符串
    - 色彩与光照规则
  per_episode_variable:
    - 具体生活目标
    - 时间与天气
    - 当前Look
    - 情绪线
    - 背景音乐段落
  forbidden:
    - 每集重做主角身份
    - 单镜重写角色外观
    - 相同场景随机换布局
```

---

## 12. 负面约束

- 不要高饱和度、强撞色、恐怖、赛博朋克或机械科幻。
- 不要快切、手持抖动或多种复杂运镜叠加。
- 不要用旁白解释画面已经能表达的内容。
- 不要跨镜改变发色、服装、光源、家具和道具位置。
- 不要在单镜 Prompt 中重复定义已锁定外观。
- 若选择非写实媒介，不要混入写实摄影道具或皮肤。

---

## 13. Production Adapter Reference

```yaml
production_modules:
  model_adapter_reference:
    image:
      - Nano Banana Pro
    video:
      - Kling 3.0 Omni
    music:
      - Suno 5
      - Mureka 8
  source_output_reference:
    default_aspect_ratio: 9:16
    video_resolution: 720p
  asset_reference:
    character: 头肩特写与全身双联图
    scene: 无人物场景全景图
  replaceable: true
```

画幅、模型、元素图布局和具体秒数属于生产适配器；永久 Style Core 不锁死为 9:16。

---

## 14. 冲突与缺失项

```yaml
conflicts:
  - id: VLOG-VISUAL-01
    issue: 文档要求固定 art_style，但没有给出唯一 art_style
    resolution: 进入 LookDev 前必须由当前项目或另一个视觉 Profile 补充
  - id: VLOG-REALISM-01
    issue: 负面词排除写实摄影，但视觉媒介仍未定义
    resolution: 保留为原流程倾向，不推断具体动画画种

missing_or_partial:
  visual_medium: 缺失，运行时必填
  line_and_texture_system: 缺失
  fixed_character_canon: 缺失
  exact_music_instrumentation: 部分
  dialogue_policy: 部分
```

---

## 15. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/治愈系日常系独居生活风格Vlog.md

style_profile:
  style_id: healing_solo_daily_vlog
  version: 1.0-zh
  classification: narrative_style_bible

  pre_content_modules:
    compatibility:
      authority: high
      preferred:
        - 独居日常
        - 自我照料
        - 低冲突生活片段
    topic_direction:
      authority: medium
      value:
        - 清晨准备
        - 一人料理
        - 雨天居家
        - 夜间阅读
        - 整理与照料
    story_direction:
      authority: high
      value: 具体生活目标 → 缓慢准备 → 细节完成 → 安静满足
    theme_expression_rules:
      authority: high
      value: 依靠动作、物件状态和环境变化，不使用旁白解释

  audiovisual_modules:
    visual_identity:
      authority: partial
      visual_medium: runtime_required
      value: 低饱和暖色、柔和漫反射、主体清楚、生活空间整洁
    character_visual:
      authority: hard
      value: 身份与Look分离锁定，镜头不得重定义外观
    environment:
      authority: hard
      value: 空间布局、光源、色温和道具位置跨镜稳定
    cinematography:
      authority: hard
      value: 固定机位或极缓推拉，使用全景、中近景和生活细节特写
    performance:
      authority: high
      value: 微小、具体、连续的生活动作与物件反馈
    editing_rhythm:
      authority: hard
      value: 舒缓，避免快切，默认柔和淡入淡出
    sound_design:
      authority: high
      value: 保留生活环境和小尺度拟音
    voice_system:
      authority: hard
      value: 默认无旁白，以画面和声音叙事
    music_direction:
      authority: high
      value: 无人声、低密度、温暖治愈，不压过自然声
    continuity_schema:
      authority: hard
      track:
        - 角色身份
        - Look
        - 场景布局
        - 道具位置
        - 光源方向与色温

  production_modules:
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable
    generation_workflow: ignored_in_style_core

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/治愈系日常系独居生活风格Vlog.md
        version: attached-2026-08-24
        sha256: 14E3E30895ABCA548EE0E711D06CCF477194A1A8667DC14DEF43D662FF5C95DA
    extracted_modules:
      - field: pre_content_modules
        source_section: planner + storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer + write_the_prompt + video_assembler
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator
        extraction_type: direct
```
