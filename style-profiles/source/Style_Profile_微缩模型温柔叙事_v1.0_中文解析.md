# Style Profile：微缩模型温柔叙事

> **版本**：v1.0-zh  
> **源文档**：`微缩世界创意短片.md`  
> **内部风格 ID**：`miniature_tilt_shift_tender_story`  
> **解析原则**：保留微缩摄影、比例物理、温柔叙事与声音气质；模型、分辨率、时长、暂停节点和工具调用只作可替换生产参考。

---

## 0. 解析结论

该文档应归类为 **微缩模型视听风格 + 温柔情感叙事框架 + 生产手册**。稳定核心是：实拍微缩模型摄影、移轴浅景深、可见手工材质、柔和漫射光、克制运镜、明确的大小比例、温暖的小人物故事，以及钢琴或弦乐为主的轻音乐。

源文档中关于 60–90 秒、20–36 镜、具体模型、2K/480p/1080p、暂停节点、失败降级与提示词语法的内容不属于永久风格身份。

## 1. 文档分类与适配范围

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - narrative_style_bible
    - production_playbook
  full_series_canon: false
```

### 强适配

- 节日祝福、亲情、友情、陪伴与治愈故事
- 以普通生活物件形成巨大尺度反差的创意
- 角色数量有限、动作可被清楚拆解的温柔短片
- 需要通过材质、光线和小动作表达情绪的内容

### 弱适配

- 写实灾难、硬核战争、恐怖血腥、强竞技动作
- 高密度知识口播或大量对话驱动的剧情
- 需要快速剪辑、剧烈运镜或复杂群战的内容
- 物件比例无法稳定、必须频繁改变空间尺度的内容

### 风格兼容性闸门

只有当题材能在不改变核心结论的前提下，被转译成“小人物在可触摸的模型世界中完成一件具体事情”，才判定为 `acceptable`。若必须把严肃内容强行治愈化、童话化或节日化，则判定为 `mismatch`。

## 2. 权威级

```yaml
authority:
  topic_direction: soft
  story_structure: medium
  visual_identity: hard
  scale_physics: hard
  color_and_light: hard
  cinematography: hard
  performance: medium
  narration_style: medium
  sound_design: medium
  music_direction: hard
  production_model: none
```

## 3. 上游内容模块

- 推荐“建立世界 → 触发事件 → 推进 → 情感高潮 → 余韵”的 4–6 环节结构。
- 每个环节应有明确场景、参与角色、关键动作或道具及情绪功能。
- 风格只建议温柔、克制、有人物弧光的表达，不得修改已确认事实、Hook、Reveal 或核心结论。
- 第一人称与第三人称旁白均可；是否需要旁白由脚本语义决定。

## 4. 视觉身份

### 核心媒介

- 实拍感微缩模型世界
- 移轴摄影与微距镜头感
- 焦点集中于中间主体，前后景柔和虚化
- 精致但不塑料化的手工质感
- 真实可辨的布料纤维、木纹、玻璃反光与表面细节

### 色彩与光线

- 温暖路线：暖白、奶茶色、金黄与柔和夕阳
- 冷调梦幻路线：薄荷蓝、月光白与局部暖光
- 光线以自然光或柔和漫射光为主，避免无动机硬阴影
- 夜景可使用月光、烛光或细小散景，但不得把道具本体无理由做成发光物

## 5. 比例与世界物理

这是本 Profile 的最高优先级规则。

- 同一角色、场景和核心道具的相对尺寸跨镜保持稳定。
- 大于人偶身体的大道具必须体现重量与协作；单个人偶不能轻易举动巨大物件。
- 每个动作必须有明确主体，禁止“有人”“某人”等模糊描述。
- 禁止无依据悬浮、发光、瞬移、巨大人体手掌闯入或骑乘昆虫等破坏微缩写实感的行为。
- 固定道具的位置与状态不能无故变化。

## 6. 角色与表演

- 角色可略卡通化，但必须仍像精细制作的微缩人偶，而非二维动漫或光滑塑料 3D。
- 表演以小幅度、可读动作和明确物体互动为主。
- 情感高潮依靠停顿、目光、手部动作、协作和道具状态变化，不依赖夸张面部扭曲。
- 角色身份锁包括面容、发型、服装、鞋履、体型比例与关键道具。

## 7. 镜头与剪辑

- 开场可用俯瞰或大远景建立完整微缩空间。
- 叙事推进以中景和轻缓跟随为主。
- 情绪与材质节点使用面部近景、道具特写或微距镜头。
- 推荐缓慢推进、轻微横摇、柔和跟拍与静止观察。
- 避免快速剪辑、强烈抖动、广角畸变和频繁复杂运镜。
- 单镜时长随叙事决定；源文档的 4–10 秒仅作生产参考。

## 8. 声音、旁白与背景音乐

### 声音

- 环境声应小而清楚：脚步、布料、木材、玻璃、纸张、风与轻微物件摩擦。
- 大道具动作的声音重量应与视觉尺寸一致。
- 旁白与镜头原生人声不能相互覆盖；具体静音与避让交给后期。

### 旁白

- 温柔、克制、短句、有停顿和留白。
- 第一人称或第三人称均可。
- 不强制励志升华，也不强制节日祝福。

### 背景音乐

- 钢琴独奏或钢琴加弦乐
- 轻柔、温暖、无人声
- 全片可使用 1–2 个音乐段落，情绪高潮可适度增加弦乐层次
- 背景音乐作为独立音轨，不写进视频视觉提示词

## 9. 连续性与资产意图

- 角色参考应同时覆盖清晰面部、完整服装和全身比例。
- 场景参考应说明空间结构、光向、固定道具与日夜状态。
- 有叙事作用的道具应单独登记，并维护状态变化。
- 高连续动作可引用前镜尾态；普通镜头不必机械继承上一段视频。

## 10. 负面约束

- 禁止动漫化、二维卡通化、黏土感和光滑塑料感
- 禁止比例漂移、巨大手掌、无理由悬浮与发光道具
- 禁止脸部模糊、肢体畸形、文字、水印和随机字幕
- 禁止快速碎切、无动机抖动和硬阴影污染温柔气质
- 禁止把示例中的咖啡杯、信件、花束等升级为固定设定

## 11. 可替换生产参考与来源冲突

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    aspect_ratio_options: ["9:16", "16:9", "1:1"]
    duration_examples: ["60s", "90s"]
    image_models: ["GPT Image 2", "Nano Banana Pro", "Nano Banana 2", "Seedream 4.5", "Midjourney V7"]
    video_models: ["Seedance 2.5", "Kling 3.0 Omni", "Google Veo3.1 Fast"]
    music_models: ["Suno 5", "Mureka 8"]
    narration_models: ["ElevenLabs v3"]
```

已识别冲突：源文档一处把微缩美学描述为“非写实非动漫”，其他位置又要求“实拍风格”和“真实材质”；本 Profile 统一为 **实拍感微缩模型摄影，不等于现实尺度真人摄影**。提示词中的具体模型降级、分辨率和音色 ID 均不进入风格核心。

## 12. 缺失项与可靠度

```yaml
missing_or_partial:
  fixed_world_canon: 缺失
  detailed_character_voice: 缺失
  detailed_foley_system: 部分
  dialogue_system: 部分
  continuity_ledger: 部分

reliability:
  visual_identity: high
  scale_physics: very_high
  cinematography: high
  music: high
  narration: medium
  production_parameters: low_medium
```

## 13. 机器可读摘要

```yaml
style_profile:
  style_id: miniature_tilt_shift_tender_story
  version: "1.0-zh"
  classification: hybrid_style_profile
  pre_content_modules:
    preferred_story_shape: [建立世界, 触发事件, 推进, 情感高潮, 余韵]
    compatibility_gate: 不得为了套用治愈微缩风格改写核心语义
  audiovisual_modules:
    visual_identity: 实拍感微缩模型摄影与移轴浅景深
    scale_physics: 跨镜比例稳定，大道具体现重量与协作
    cinematography: 克制缓慢，以中景、微距和柔和推进为主
    narration: 温柔、克制、短句、有留白
    music: 钢琴或钢琴加弦乐的独立无人声背景音乐
  production_modules:
    adapter_reference: replaceable
    prompt_templates_are_canon: false
  provenance:
    source_documents:
      - file: 微缩世界创意短片.md
        sha256: E4F667C2B89300BE074C8A8FCDA47825C54E1D2AFFCED2101BD5753039994A31
    extracted_modules:
      - module: 视觉、比例物理、镜头、旁白与音乐
        extraction: normalized
      - module: 模型、分辨率、时长与暂停节点
        extraction: direct
        routed_to: production_modules
```
