# Style Profile：手工粘土微缩世界

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/粘土3D动画风格.md`  
> **源文件 SHA-256**：`1FE7613AD1F8C046FAC8925F73EE5905011720C3EB6FF7389A941DF68F60DC47`  
> **内部风格 ID**：`handcrafted_clay_diorama`  
> **库状态**：`pending_review`  
> **解析原则**：只提取可复用的风格、叙事、声音与连续性规则；源文档中的工具调用、按钮、积分、模型、分辨率和工作流步骤仅作为生产参考，不在本次执行。

---

## 0. 解析结论

这是一份**材质主导的视听风格 + 实拍转化流程 + 生产手册**。最稳定的 Style Core 是：

- 所有人物、场景和道具统一转化为手工粘土材质；
- 表面可见轻微捏制、压纹或指纹痕迹，整体哑光、厚实、圆润；
- 场景倾向微缩模型或陈列式空间感，常配浅景深；
- 光线温暖柔和，硬质材料也要被重新解释为粘土或厚树脂；
- 实拍转化优先保留主体身份、空间结构、构图重点和原有氛围；
- 动作节奏温和，叙事可依靠旁白与生活化细节推进。

源文档内部有两组未完全统一的规则：一处强调“色彩饱满鲜明、中高饱和”，另一处要求“柔和、略低饱和、保留原图主色逻辑”；一处强调“停格质感”，视频规则又要求动作自然连贯。故本版不自动提升为 `ready`。

---

## 1. 文档分类

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - pure_visual_style
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: false
    has_story_direction: partial
    has_world_rule: true
    has_character_canon: false
    has_visual_system: true
    has_sound_system: partial
    has_voice_system: partial
    has_music_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 治愈日常、居家、咖啡馆、手作与生活方式内容
- 城市街景、旅行、植物、静物与轻产品展示
- 真实照片到幻想材质世界的转化短片
- 需要亲切、童话、可触感和手作温度的轻叙事

### 中等适配

- 轻科普、品牌故事、文化小故事
- 温和的群像、活动和空间展示
- 需要旁白驱动但画面不依赖复杂对白的短片

### 弱适配

- 高速武打、严肃战争、硬恐怖
- 依赖真实金属、玻璃、皮肤和薄织物精确质感的题材
- 复杂机械结构、精密文字界面和写实证据展示

---

## 3. 权威与事实边界

```yaml
authority:
  topic_direction: none
  story_direction: soft
  material_world: hard
  photo_identity_preservation: hard
  character_visual: medium
  environment: hard
  color: medium
  lighting: high
  cinematography: medium
  motion_behavior: medium
  voice: medium
  music: medium
  production_model: none
```

- “照片转粘土”只允许改造视觉材质，不得改写人物身份、产品关键识别特征、空间关系或事实信息。
- 场景类型清单是**适配模块**，不是每个项目都必须出现的内容。
- “大眼、球状头发、暖橙肤色”等人物模板只适用于无强身份参考的原创角色；若有真人参考，应服从身份保真，不得强行覆盖。

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: medium
    preferred:
      - 日常生活
      - 治愈互动
      - 手作与空间展示
      - 轻童话表达
    avoid:
      - 复杂冲突
      - 高速多人动作
      - 依赖真实证据材质的内容

  story_direction:
    authority: soft
    value: 场景建立 → 具体生活动作或展示 → 细节特写 → 温和收束

  narration_style:
    authority: medium
    value: 温和、亲切、舒缓；是否使用旁白由当前项目决定

  restrictions:
    - 不改写选题 Thesis
    - 不改事实或人物身份
    - 不因粘土风自动把严肃内容改成低幼故事
```

---

## 5. 视觉身份

### 材质世界

- 手工粘土是全画面的统一材质语法，不允许局部仍保留写实材质。
- 表面应有轻微手工塑形痕迹，但不能粗糙到像未完成模型。
- 轮廓圆润、边缘柔和、厚度可见，避免锐角和轻薄感。
- 整体质感为细腻哑光，避免塑料高光和廉价玩具感。

### 空间语法

- 场景可呈现微缩模型或展示台式纵深，但仍需保持可读的空间结构。
- 主体明确、层次清楚，前后景可轻度虚化。
- 对由实拍转化的建筑、交通工具和产品，保留基本比例与识别轮廓。

```yaml
visual_identity:
  medium: 手工粘土三维动画
  surface:
    - 轻微捏制痕迹
    - 压纹与手工不均匀
    - 细腻哑光
  geometry:
    - 圆润
    - 厚实
    - 无锐角
  spatial_feel:
    - 微缩模型感
    - 浅景深
    - 清晰主体层级
```

---

## 6. 角色与物体转化

### 真人或既有角色

- 锁定脸型、五官比例、年龄感、发型、服装、姿态和气质。
- 五官可适度简化，但必须保持可辨识度。
- 皮肤改为哑光粘土，头发改为块状或团簇体积，服装改为厚实压纹结构。
- 不得因风格化造成换脸、过度 Q 版、比例失衡或身份漂移。

### 原创粘土角色

- 可采用较大的圆形眼睛、简化鼻梁、厚圆耳朵和圆柱形四肢。
- 轮廓饱满，表情友善，避免尖锐、纤细或写实毛孔。
- 具体肤色、眼型与头身比属于当前角色设定，不是永久固定值。

### 材质映射

```yaml
material_mapping:
  wood: 粘土表面刻入木纹，板件厚，接缝略不规则
  metal: 带低调暗光泽的金属感粘土，边角圆化
  glass: 厚树脂般半透明，边缘厚重，避免薄玻璃感
  fabric: 宽厚圆柱褶皱或压制编织纹，不表现轻薄飘逸
  plants: 厚叶片、圆钝叶尖、浅刻叶脉
  wall_and_floor: 手工抹平痕迹、厚板缝和轻微边缘变形
```

---

## 7. 色彩与光影

```yaml
color:
  base: 暖色、协调、生活化
  source_conflict:
    - 饱满鲜明、中高饱和
    - 柔和、略低饱和、尊重原图主色
  normalized_rule: 保留原图主色逻辑；默认中等饱和，按题材在审核时上调或下调
  avoid:
    - 霓虹污染
    - 杂乱撞色
    - 塑料糖果色

lighting:
  key: 约45度暖侧光或柔和顶侧光
  quality: 漫射、宽高光、阴影过渡缓慢
  contrast: 低至中等
  atmosphere: 温暖、轻童话、生活感
```

---

## 8. 镜头、动作与剪辑

- 推荐固定镜头、缓慢推进、轻柔环绕、平稳拉远和细节特写。
- 一个镜头以一个主要动作和一个视觉重点为主。
- 动作应温和、连续、可读；“停格感”主要来自材质和造型，不必强制降低运动帧率。
- 开场可建立完整空间，结尾可渐隐或温和收束。
- 避免快速旋转、抖动、闪烁转场和无动机快切。

```yaml
cinematography:
  preferred:
    - 固定机位
    - 缓慢推进
    - 平稳拉远
    - 轻柔环绕
    - 材质细节特写
  avoid:
    - 快速旋转
    - 混乱手持
    - 频繁变焦
    - 无动机快切

motion:
  surface_impression: 定格动画般手作质感
  actual_movement: 默认自然连贯
  unresolved_option: 是否刻意保留轻微停格节奏需项目级确认
```

---

## 9. 声音、旁白与音乐

### 声音设计

- 轻微粘土摩擦、厚实物体接触、柔和环境声。
- 自然音效应与画面动作同步，不制造夸张卡通音效。

### 旁白

- 可选；有旁白时偏温和、亲切、舒缓。
- 旁白内容应与当前展示区域或动作紧密对应。

### 背景音乐

```yaml
music_direction:
  function: 作为连续的温和底层，不压过旁白和细小拟音
  default_mood:
    - 治愈
    - 温暖
    - 轻松
  possible_instrumentation:
    - 原声吉他
    - 轻柔钢琴
    - 轻氛围音色
  avoid:
    - 高密度鼓点
    - 强烈攻击性低频
```

---

## 10. 连续性锁

```yaml
continuity_schema:
  character:
    - 身份与脸部辨识
    - 发型体积结构
    - 服装颜色与压纹
    - 身体比例
  environment:
    - 空间布局
    - 展示区域关系
    - 光源方向与色温
    - 道具位置
  material:
    - 全画面粘土化
    - 表面哑光程度
    - 边缘圆润程度
  transition:
    - 实拍起始状态
    - 粘土目标状态
    - 主体与构图不漂移
```

---

## 11. 负面约束

- 不要写实皮肤毛孔、丝状发丝或轻薄飘逸布料。
- 不要廉价塑料玩具感、光滑 CG 表面或局部材质混杂。
- 不要低幼化、过度 Q 版、身份失真或场景比例混乱。
- 不要高频抖动、疯狂跳跃、快速乱飞镜头。
- 不要无关文字、水印、字幕或品牌标志漂移。

---

## 12. Production Adapter Reference

以下只记录源文档提及的生产配置，不构成永久风格规则：

```yaml
production_modules:
  model_adapter_reference:
    image:
      - Nano Banana 2
      - Nano Banana Pro
    video:
      - Seedance 2.5
    voice:
      - TextToSpeech
      - Seed Audio
    music:
      - Suno 5
      - Mureka 8

  asset_reference:
    character: 白底全身参考图
    scene: 正面全景、侧面近景、俯瞰、细节特写
    transition: 实拍起始帧到粘土目标帧

  replaceable: true
```

画幅、分辨率、镜头秒数、模型名、提示词占位符和逐阶段确认均由当前 Video Production Adapter 决定。

---

## 13. 冲突与缺失项

```yaml
conflicts:
  - id: CLAY-COLOR-01
    issue: 源文档同时要求饱满鲜明和略低饱和
    resolution: 默认保留原图主色与中等饱和；项目级审核后确定
  - id: CLAY-MOTION-01
    issue: 源文档同时强调停格质感和自然连贯动作
    resolution: 将停格感限定为材质与造型印象，运动节奏待项目级确认

missing_or_partial:
  fixed_character_canon: 缺失
  fixed_color_palette: 未统一
  exact_stop_motion_cadence: 缺失
  detailed_sound_palette: 部分
  recurring_series_rules: 缺失
```

---

## 14. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/粘土3D动画风格.md

style_profile:
  style_id: handcrafted_clay_diorama
  version: 1.0-zh
  classification: hybrid_style_profile

  pre_content_modules:
    compatibility:
      authority: medium
      preferred:
        - 治愈日常
        - 生活方式
        - 手作与空间展示
      avoid:
        - 高速多人动作
        - 依赖写实材质证据的内容
    story_direction:
      authority: soft
      value: 场景建立 → 具体动作 → 材质细节 → 温和收束

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 统一手工粘土材质、圆润厚实轮廓、可见塑形痕迹、哑光表面、微缩空间感
    character_visual:
      authority: medium
      value: 身份优先；皮肤、头发和服装统一转化为粘土体积与压纹
    environment:
      authority: hard
      value: 保留原空间结构与识别要素，统一粘土化并保持层级清楚
    cinematography:
      authority: medium
      value: 固定、缓推、缓拉、轻环绕和材质特写
    performance:
      authority: medium
      value: 温和、自然、动作可读，避免高速夸张运动
    editing_rhythm:
      authority: medium
      value: 舒缓，简单直切或轻淡入淡出
    sound_design:
      authority: medium
      value: 轻粘土摩擦、厚实接触与柔和环境声
    voice_system:
      authority: medium
      value: 旁白可选；温和、亲切、舒缓
    music_direction:
      authority: medium
      value: 轻柔治愈底层，避开强攻击性节奏
    continuity_schema:
      authority: hard
      track:
        - 人物身份
        - 材质统一
        - 空间布局
        - 道具位置
        - 光源方向

  production_modules:
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable
    generation_workflow: ignored_in_style_core

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/粘土3D动画风格.md
        version: attached-2026-08-24
        sha256: 1FE7613AD1F8C046FAC8925F73EE5905011720C3EB6FF7389A941DF68F60DC47
    extracted_modules:
      - field: pre_content_modules
        source_section: planner
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer + write_the_prompt + video_assembler
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator + planner
        extraction_type: direct
```
