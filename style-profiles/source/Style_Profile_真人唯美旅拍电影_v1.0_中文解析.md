# Style Profile：真人唯美旅拍电影

> **版本**：v1.0-zh  
> **源文档**：`唯美旅拍风格视频.md`  
> **内部风格 ID**：`live_action_lyrical_travel_film`  
> **解析原则**：保留真人旅拍、真实地点锚定、自然表演、光影与旅行情绪；爆款文案、固定押韵率、镜头数量、工具和生成参数只作生产参考。

---

## 0. 解析结论

该文档应归类为 **真人旅拍视听风格 + 生活方式内容框架 + 重型生产手册**。可长期复用的风格核心是：真实人物、真实或可信地点、自然光与黄金时刻、旅行中的身体运动、环境先于口号、克制的胶片感、自然声景，以及由舒缓到高潮再回落的音乐曲线。

源文档把“正能量、60% 押韵、100–520 字、固定 30 秒单元、每单元高镜头数”写成硬规则，这些属于特定自媒体策略，不应成为永久审美身份。

## 1. 分类与兼容性

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - narrative_style_bible
    - production_playbook
  full_series_canon: false
```

### 强适配

- 城市漫游、自然旅行、度假、生活方式与人物状态片
- 有真实目的地或可信空间参照的旅拍
- 通过行走、奔跑、回望、停驻和风景观察表达情绪
- 需要社交媒体传播，但仍希望保留电影观察感的内容

### 弱适配

- 产品细节必须精确复刻的商业证据片
- 大量对白、复杂剧情反转或高强度动作
- 阴郁、讽刺、黑色幽默等不适合被强制“正能量化”的内容
- 缺少人物身份与地点依据，却要求伪装成真实旅行记录的内容

### 兼容性闸门

风格可以增强地点、光线、动作和感官体验，但不能把任何故事强制改写为“治愈旅行鸡汤”。真实地点的地标、植被、建筑和气候若有来源，应优先于通用旅拍想象。

## 2. 权威级

```yaml
authority:
  topic_direction: soft
  story_structure: medium
  visual_identity: hard
  location_fidelity: hard_when_reference_exists
  character_identity: hard_when_reference_exists
  cinematography: high
  performance: medium_high
  narration_style: medium
  sound_design: medium
  music_direction: high
  marketing_copy_formula: low
  production_model: none
```

## 3. 上游内容模块

- 从地点、人物、情绪、平台用途和已有文案中提取真实创作约束。
- 抽象文案应被转译为时间、空间、感官和动作，不只生成漂亮空镜。
- 第一人称旁白可用于生活感悟，但 Hook、故事、共鸣、反思与行动号召只是可选营销结构。
- 不强制正面情绪，不强制押韵，不强制 CTA；这些由当前账号定位和脚本决定。

## 4. 视觉身份

- 真人实拍或可信真人电影质感
- 自然皮肤、真实发丝、布料与鞋履，不做塑料化磨皮
- 场景具有明确地域结构、植被、建筑和气候线索
- 黄金时刻、逆光、晨雾、风、花海、海岸、山路、城市街巷等可作为原型
- 胶片感应来自受控颗粒、高光扩散和色彩层次，不来自重滤镜

## 5. 色彩与光线

- 优先使用自然光、黄金时刻、柔和逆光和环境反射光。
- 人物肤色保持自然，不因统一调色丢失真实色相。
- 主色、辅色和强调色可用 6:3:1 作为构图启发，不升级为机器硬阈值。
- 真实场景参考存在时，地点固有色和主要光向不得被通用“唯美”调色覆盖。

## 6. 人物与表演

- 人物以自然、松弛、真实在场为主，避免过度摆拍。
- 常用动作：行走、停驻、看风景、回望、张臂、轻跑、与风和衣料互动。
- 招牌动作属于可选镜头原型，不应每片重复堆满。
- 表演应与场景发生关系：脚步接触地面、手触植物或栏杆、视线落到真实地标。
- 有人物参考时，面容、体型、发型、服装和鞋履是连续性硬锁；下半身缺失不得无依据“脑补”为事实，应标记为待确认设计。

## 7. 镜头、节奏与连续性

- 大景交代目的地，中景观察人物与环境关系，近景捕捉表情、手部和材质。
- 推荐平稳跟拍、缓慢推进、环绕、侧向移动和适度手持呼吸感。
- 高潮可加快镜头与动作密度，结尾恢复舒缓和留白。
- 场景连续时可用前段尾帧、动作方向、光线方向和环境声桥保持连接。
- 每 30 秒必须 10–50 镜、每段固定 30 秒等数字属于源文档生产方案，不是视听身份。

## 8. 声音、对白、旁白与音乐

### 声景

- 风、脚步、水声、衣料、城市远声和现场空间反射应保留。
- 人物对白与旁白分轨管理；跨段音色一致性依赖明确声音参考。
- 对白是否出现字幕由当前发布需求决定，不将“无字幕”误当内容语义。

### 旁白

- 第一人称、感官化、具体、避免空泛口号。
- 可以抒情、故事化或感悟式，但不强制 60% 押韵。
- 文字应和可见画面对应，避免“画面旅行、旁白说教”。

### 背景音乐

- 纯器乐，随叙事呈渐起、高潮、舒缓曲线。
- 可融合钢琴、弦乐、轻打击与地点自然声景。
- 不依赖具体音乐人姓名。

## 9. 负面约束

- 禁止动漫、插画、CG 塑料人和过度磨皮
- 禁止真实地点结构漂移、地标错位和气候混用
- 禁止人物身份、服装、鞋履和音色跨段漂移
- 禁止无动机高速碎切、模板动作堆砌和空洞正能量口号
- 禁止随机字幕、水印、品牌标识和未经确认的团队信息

## 10. 可替换生产参考与来源冲突

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    segment_length: "30s"
    image_model: "GPT Image 2"
    video_model: "Seedance 2.5"
    music_models: ["Suno 5", "Mureka 8"]
    narration_models: ["ElevenLabs v3", "Doubao"]
```

来源冲突与风险：

- 两个视频模型选项在源文档中实际写成相同名称与分辨率，无法构成真实选择。
- “错误素材后台自动重做且不打扰用户”缺少成本与停止条件，不可继承为默认规则。
- “有字幕但无硬伤”被归为可用，与“无字幕红线”冲突。
- 强制高镜头数量可能破坏真实旅拍的呼吸感，应由项目时长和音乐节奏决定。
- 公开列出的具体音色 ID 属可漂移的适配参数，不进入风格核心。

## 11. 缺失项与可靠度

```yaml
missing_or_partial:
  fixed_color_palette: 缺失
  detailed_location_verification: 部分
  dialogue_writing_system: 部分
  foley_system: 部分
  continuity_ledger: 部分

reliability:
  live_action_identity: high
  location_anchor: high
  performance: medium_high
  cinematography: high
  narration: medium
  marketing_formula: low
  production_parameters: low
```

## 12. 机器可读摘要

```yaml
style_profile:
  style_id: live_action_lyrical_travel_film
  version: "1.0-zh"
  classification: hybrid_style_profile
  pre_content_modules:
    preferred_content: [旅行, 城市漫游, 自然体验, 生活方式]
    restrictions: 不得强制正能量、押韵或鸡汤化
  audiovisual_modules:
    visual_identity: 真人实拍旅拍电影感
    location_fidelity: 有参考时锁定地标、植被、建筑、气候与光向
    performance: 自然行走、停驻、回望及环境互动
    cinematography: 大景建立环境，中近景建立人物在场感
    narration: 第一人称、感官化、具体
    music: 纯器乐的渐起、高潮、舒缓曲线
  production_modules:
    adapter_reference: replaceable
    fixed_shot_count_is_canon: false
    automatic_retry_requires_cost_gate: true
  provenance:
    source_documents:
      - file: 唯美旅拍风格视频.md
        sha256: A86672EA91ECC48A57B6A7409E1428D1B118BD8E4ACCCC46F5E3A308F06FEB6C
    extracted_modules:
      - module: 真人视觉、地点锚定、表演、镜头、旁白与音乐
        extraction: normalized
      - module: 爆款文案、模型、时长、镜头数与暂停流程
        extraction: direct
        routed_to: production_modules
```
