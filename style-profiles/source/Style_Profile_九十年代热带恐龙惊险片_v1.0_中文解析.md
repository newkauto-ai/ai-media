# Style Profile：九十年代热带恐龙惊险片

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/侏罗纪公园风格短片.md`  
> **源文件 SHA-256**：`67BAB904372A671A8B2C44D070340218AA4761DEAD90C1D41EBCAA1753FF94E8`  
> **内部风格 ID**：`nineties_tropical_dinosaur_thriller`  
> **库状态**：`pending_review`  
> **命名处理**：源文档中的影片、导演、作曲家和特效团队名称只保留为来源记录；标准化风格用可观察的胶片、调色、光影、悬疑、体量和声音规则表达。

---

## 0. 解析结论

这是一份**九十年代热带恐龙冒险惊险片视听风格 + 恐龙/场景模板 + 生产手册**。最稳定的 Style Core 是：

- 35mm 胶片感、低饱和复古绿、柔和电影色阶和轻微晕影；
- 自然物理光与实际光源驱动照明，不使用现代数字 HDR 和过度锐化；
- 以缓慢推进、前景遮挡、低角度仰拍和人物反应镜头积累悬疑；
- 恐龙强调粗糙鳞片、重量、步态惯性和与人物/建筑的尺度对比；
- 热带丛林、雨夜围栏和九十年代公共建筑形成典型空间域；
- 动作前允许较长等待，追逐段才收紧节拍；
- 环境声、脚步震动、雨声和生物声承担主要威胁感，音乐作为冒险与敬畏的底层。

源文档中的具体物种外观、无羽毛设定、访客中心和高压围栏等，是对特定虚构电影版本的再现模板，**不是现代古生物学事实，也不是所有恐龙题材的通用 Canon**。标准化时将其保留为可选 `source_templates`。

---

## 1. 文档分类

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - audiovisual_style_profile
    - narrative_style_bible
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: partial
    has_story_direction: true
    has_world_rule: true
    has_character_templates: true
    has_visual_system: true
    has_sound_system: true
    has_voice_system: partial
    has_music_system: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 热带岛屿恐龙冒险、逃生和发现
- 生物体量、未知威胁和技术失控题材
- 雨夜、丛林、围栏、遗弃设施等悬疑空间
- 九十年代好莱坞写实冒险质感

### 中等适配

- 其他大型史前生物或怪兽的写实惊险片
- 自然保护区、科研设施和灾难逃生故事
- 需要敬畏与恐惧并存的探索题材

### 弱适配

- 现代高饱和科幻、霓虹赛博朋克
- 卡通恐龙、儿童低幼科普
- 要求严格现代古生物复原的教育内容

---

## 3. 事实边界与权威

```yaml
factual_boundary:
  film_version_design: source_defined_fiction
  modern_paleontology: not_claimed
  species_measurements: source_template_only
  feather_rules: source_version_only

authority:
  topic_direction: soft
  story_direction: medium
  film_texture: hard
  color: hard
  lighting: hard
  suspense_cinematography: hard
  creature_weight_and_scale: hard
  source_species_templates: low_medium
  sound_design: high
  narration: low
  production_model: none
```

- 物种尺寸、外皮、羽毛和运动方式若用于科普，必须另行核实，不可直接引用本 Style Profile。
- “8K 修复感”属于输出/修复语义，不是九十年代摄影现场的视觉事实；Style Core 只保留可感知的胶片层次和不过度锐化。
- 具体影片场景和人物不能自动成为新项目的内容设定。

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: high
    preferred:
      - 探索未知
      - 技术失控
      - 生物威胁
      - 敬畏与逃生
    avoid:
      - 轻浮喜剧
      - 高饱和卡通冒险

  story_direction:
    authority: medium
    value: 安全表象 → 微小异常 → 生物揭示 → 追逐或对峙 → 暂时逃脱或敬畏收束

  theme_expression_rules:
    authority: soft
    value: 先用环境、声音和人物反应制造预期，再完整揭示生物

  restrictions:
    - 不把虚构电影版本当作科学事实
    - 不自动复写原影片剧情、角色或场景
```

---

## 5. 胶片、调色与光影

```yaml
visual_identity:
  capture_impression: 35mm复古胶片
  grain: 温厚、可见但不过量
  grading: 九十年代商业冒险片式柔和色阶
  dominant_hue: 低饱和复古绿
  contrast: 中等，暗部保留颗粒与层次
  vignette: 轻微可选
  avoid:
    - 现代HDR
    - 霓虹色
    - 高饱和热带明信片绿
    - 过度锐化
    - 数字塑料感

lighting:
  principle: 实体光源或自然光驱动
  sources:
    - 阳光
    - 阴天漫射
    - 手电筒
    - 钨丝灯
    - 天窗
    - 月光
  behavior: 光源方向、遮挡、反射和阴影必须物理可解释
```

---

## 6. 生物视觉与运动

### 永久规则

- 皮肤具有明确鳞片、皱褶、干湿区域和颜色分区，避免光滑玻璃面。
- 体型用人物、车辆、围栏和建筑作为尺度参照。
- 运动必须体现重量、重心、步态、尾部平衡、颈部惯性和落地冲击。
- 近景强调眼睛、鼻孔、皮肤与爪部细节；远景强调体量和环境关系。

```yaml
creature_visual:
  surface:
    - 鳞片排布
    - 皱褶分区
    - 干湿差异
    - 局部颜色分区
  scale_reference:
    - 成年人
    - 车辆
    - 围栏
    - 建筑檐口
  movement:
    - 重心转移
    - 步态节奏
    - 尾部平衡
    - 头颈惯性
    - 地面反馈
```

### 仅作源版本模板

霸王龙、迅猛龙和腕龙的具体尺寸、颜色、无羽毛规则与眼睛细节，保留在 `source_templates`，不得自动扩展到其他物种或科学内容。

---

## 7. 场景域

### 热带丛林

- 多层林冠、粗壮树干、板根、蕨类、苔藓湿土、落叶和藤蔓。
- 过滤式漫射光、叶隙光柱、潮湿雾气和前景叶片遮挡。
- 低饱和绿，暗部胶片颗粒更明显。

### 九十年代公共建筑

- 高挑中庭、石材地面、木质展示台、玻璃幕墙和室内植物。
- 天窗自然光与暖钨丝灯混合，避免现代冷白 LED。
- 建筑尺度用于反衬人物和生物体量。

### 围栏与林缘

- 金属网格、立柱、绝缘子、警示标识、泥泞积水和车辙。
- 晴天有规则几何阴影；暴雨时冷漫射；夜间依靠局部手电或微弱电弧。
- 金属应为哑光冷灰，避免镀铬数字高光。

这些空间域是强适配模板，不是每个项目必须全部出现的场景。

---

## 8. 悬疑摄影语言

- 稳定缓慢推进：让观众先察觉异常，再看到威胁。
- 低角度贴地跟拍：强调腿部冲击、足迹和地面震动。
- 前景遮挡：用叶片、门框、围栏或设备遮住部分生物。
- 先环境或人物反应，后切完整生物，控制揭示顺序。
- 长焦压缩纵深，使远处生物显得更近、更巨大。
- 航拍用于交代岛屿和雨林尺度，不承担过多动作。
- 手持只在追逐或惊吓段落增强，不作为全片基线。

```yaml
cinematography:
  preferred:
    - 稳定轨道缓慢推进
    - 低空贴地跟拍
    - 低角度仰拍
    - 前景遮挡
    - 反应镜头与生物镜头交叉
    - 长焦远景
    - 缓慢横移长镜
  conditional:
    - 航拍建立镜头
    - 追逐时快速手持
    - 关键冲击时升格
  avoid:
    - 全片高速手持
    - 无铺垫完整揭示
    - 现代短视频式高频快切
```

---

## 9. 剪辑节奏

```yaml
editing_rhythm:
  suspense: 延长等待、观察和反应镜头
  reveal: 在声音或视线提示后揭示生物
  action: 追逐段收紧，但保持空间方向可读
  default_transition: 直切
  optional_transition:
    - 淡入淡出
    - 溶叠
  forbidden: 花哨数字转场
```

源文档建议单镜 8–15 秒，是生产参考而非不可覆盖的风格常量。

---

## 10. 声音、旁白与音乐

```yaml
sound_design:
  priority:
    - 生物脚步与呼吸
    - 雨、风、虫鸣和植被
    - 围栏、电弧、车辆和建筑环境
    - 背景音乐
  suspense_method:
    - 先听后见
    - 低频震动先于完整揭示
    - 突然静默后进入威胁声

voice_system:
  narration: optional
  direction: 若使用，沉稳、克制、纪录式

music_direction:
  mood:
    - 冒险
    - 敬畏
    - 悬疑
  instrumentation:
    - 大编制管弦乐
    - 铜管与弦乐
    - 克制打击乐
  rule: 不使用具体作曲家姓名作为生成提示；不掩盖关键环境声和对白
```

---

## 11. 连续性锁

```yaml
continuity_schema:
  creature:
    - 体型比例
    - 皮肤纹理与颜色分区
    - 伤痕或湿润状态
    - 运动方向与步态
  environment:
    - 地貌与固定构件
    - 天气
    - 光源方向
    - 围栏通断状态
    - 车辆与人物位置
  suspense:
    - 威胁是否已被人物看见
    - 声音线索强度
    - 生物揭示程度
```

---

## 12. 负面约束

- 不要现代 HDR、霓虹色、过饱和绿和超锐数字质感。
- 不要光滑、玻璃质、卡通化或轻飘的恐龙。
- 不要无来源的边缘光和现代冷白 LED 污染。
- 不要花哨数字转场或持续高速快剪。
- 不要把源版本物种模板当作现代科学结论。
- 不要自动复制原影片角色、台词、标志或剧情段落。

---

## 13. Production Adapter Reference

```yaml
production_modules:
  model_adapter_reference:
    image:
      - GPT Image 2
    video:
      - Seedance 2.5
    upscaling: optional
  source_output_reference:
    aspect_ratio: 16:9
    video_resolution: 480p
    image_resolution: 2K
  source_templates:
    creatures:
      - 霸王龙电影版本模板
      - 迅猛龙电影版本模板
      - 腕龙电影版本模板
    environments:
      - 热带丛林
      - 访客中心
      - 高压围栏区
  replaceable: true
```

---

## 14. 冲突与缺失项

```yaml
conflicts:
  - id: DINO-FACT-01
    issue: 源文档将特定电影版本的无羽毛与尺寸写成固定规则
    resolution: 限定为虚构电影版本模板，科普用途必须另行核实
  - id: DINO-RESTORE-01
    issue: 8K修复画质与九十年代胶片采集语义混在一起
    resolution: Style Core保留胶片层次；8K仅归入生产修复参考
  - id: DINO-AUTHOR-01
    issue: 源文档用影片主创姓名作为风格锚点
    resolution: 标准化为具体摄影、调色、悬疑和音乐特征

missing_or_partial:
  original_story_world: 缺失
  factual_paleontology: 不提供
  fixed_human_character_canon: 缺失
  full_dialogue_system: 缺失
  scientific_source_provenance: 缺失
```

---

## 15. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/侏罗纪公园风格短片.md

style_profile:
  style_id: nineties_tropical_dinosaur_thriller
  version: 1.0-zh
  classification: hybrid_style_profile

  pre_content_modules:
    compatibility:
      authority: high
      preferred:
        - 热带恐龙冒险
        - 探索未知
        - 技术失控
        - 生物威胁与逃生
    story_direction:
      authority: medium
      value: 安全表象 → 微小异常 → 生物揭示 → 追逐或对峙 → 暂时逃脱或敬畏收束
    theme_expression_rules:
      authority: soft
      value: 先用环境、声音和人物反应积累悬疑，再完整揭示生物
    series_content_constraints:
      authority: hard
      value: 源电影版本规则不是现代古生物学事实

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 35mm温厚颗粒、低饱和复古绿、柔和电影色阶、自然物理光
    character_visual:
      authority: hard
      value: 生物鳞片、体量、颜色分区和运动重量跨镜稳定
    environment:
      authority: high
      value: 热带丛林、九十年代公共建筑和围栏林缘为可选强场景域
    cinematography:
      authority: hard
      value: 缓推积累张力、低角度强调体量、前景遮挡、反应镜头后揭示
    performance:
      authority: high
      value: 人物反应克制可读，生物运动体现重量、惯性与地面反馈
    editing_rhythm:
      authority: high
      value: 悬疑段延长，追逐段收紧，默认直切
    sound_design:
      authority: high
      value: 先听后见，脚步低频、雨林环境和设备声承担威胁感
    voice_system:
      authority: low
      value: 旁白可选；若使用则沉稳克制
    music_direction:
      authority: medium
      value: 冒险、敬畏、悬疑的大编制管弦乐，不使用具体作曲家姓名
    continuity_schema:
      authority: hard
      track:
        - 生物体型与皮肤
        - 天气与光源
        - 固定场景构件
        - 生物揭示程度
        - 人物与车辆位置

  production_modules:
    source_creature_templates: source_defined_optional
    source_environment_templates: source_defined_optional
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/侏罗纪公园风格短片.md
        version: attached-2026-08-24
        sha256: 67BAB904372A671A8B2C44D070340218AA4761DEAD90C1D41EBCAA1753FF94E8
    extracted_modules:
      - field: pre_content_modules
        source_section: planner + storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer + write_the_prompt + video_assembler
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator + source_templates
        extraction_type: direct
```
