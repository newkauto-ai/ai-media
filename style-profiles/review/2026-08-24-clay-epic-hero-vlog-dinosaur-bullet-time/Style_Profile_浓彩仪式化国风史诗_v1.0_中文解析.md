# Style Profile：浓彩仪式化国风史诗

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/张艺谋电影美学-国风武侠史诗历史.md`  
> **源文件 SHA-256**：`F09882EF77A37E975EA9D2798F22E613CBBE63B40B3061A94876AFBA6BC125CF`  
> **内部风格 ID**：`ritualized_chinese_epic_color`  
> **库状态**：`pending_review`  
> **命名处理**：源文档标题保留在 provenance；标准化风格名改为可复用的具体视觉语言，不把在世创作者姓名本身当作生成规则。

---

## 0. 解析结论

这是一份**国风史诗/武侠视听风格 + 角色与场景身份板规范 + 制作手册**。它最稳定的 Style Core 不是泛泛的“大师感”，而是以下可观察规则：

- 单一主色统治画面，其他颜色主动降饱和或水墨化；
- 对称构图、框架构图和大量留白形成仪式感；
- 大侧光、强逆光、深暗部与自然媒介共同塑造层次；
- 风、雨、雪、沙不是背景装饰，而是镜头中的运动主体；
- 人物动作克制、缓慢，情绪通过眼部、口部、颈部和手部的生理细节表达；
- 以较长镜头、升格与精确动作节点建立宿命感，高潮才允许有限快切；
- 环境声和材质声优先于背景音乐，默认无旁白、无字幕。

源文档中的“英雄红、影墨黑、竹林绿、大漠黄”是四种可选色彩域，不应在同一条 Style Core 中全部同时启用。

---

## 1. 文档分类

```yaml
classification:
  primary: audiovisual_style_profile
  secondary:
    - hybrid_style_profile
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: false
    has_story_direction: partial
    has_character_archetypes: partial
    has_visual_system: true
    has_performance_system: true
    has_sound_system: true
    has_voice_system: partial
    has_music_system: partial
    has_prompt_templates: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 国风武侠、历史史诗、宫廷与战争前夜
- 高端国潮广告、传统器物和服装的仪式化展示
- 宿命、牺牲、权力、忠诚、抉择等克制主题
- 需要大自然媒介参与叙事的短片

### 中等适配

- 历史人物小传、文化意象短片
- 现代故事的东方仪式化转译
- 低对白、强视觉的品牌叙事

### 弱适配

- 轻喜剧、快节奏口播、日常 Vlog
- 强写实新闻或证据型纪录片
- 依赖明亮自然色和松弛表演的内容

---

## 3. 权威级

```yaml
authority:
  topic_direction: none
  themes: soft
  story_direction: soft
  visual_identity: hard
  color_domain: hard_after_selection
  composition: hard
  lighting: hard
  natural_media: hard
  performance: hard
  cinematography: high
  editing_rhythm: medium
  sound_design: high
  voice_system: low
  music_direction: medium
  production_model: none
```

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: medium
    preferred:
      - 宿命与抉择
      - 克制冲突
      - 仪式、权力与牺牲
      - 人与环境对抗
    avoid:
      - 轻浮喜剧
      - 高频信息口播

  theme_expression_rules:
    authority: soft
    value:
      - 通过动作、环境和色彩表达，不依赖解释性台词
      - 高潮前保留停顿与蓄势

  restrictions:
    - 不改写 Topic Thesis
    - 不把色彩象征自动解释为事实
    - 脚本已冻结时，新增主题规则只能标记为 UPSTREAM-CONSTRAINT-LATE
```

---

## 5. 色彩域系统

每个项目先选择一个主色域，再允许少量中性色和材质色存在。

```yaml
color_domains:
  heroic_red:
    中文名: 英雄红
    情绪方向: 热烈、牺牲、宿命
  ink_black:
    中文名: 影墨黑
    情绪方向: 隐忍、压抑、水墨感
  bamboo_green:
    中文名: 竹林绿
    情绪方向: 清冷、潜伏、杀机
  desert_yellow:
    中文名: 大漠黄
    情绪方向: 风沙、生命力、荒凉

color_rule:
  dominant_ratio: 建议至少约65%
  secondary_colors: 降饱和或水墨化
  avoid:
    - 大面积杂色
    - 平均分配多种高饱和主色
    - 糖水片式综合色调
```

“65%”是源文档的设计建议，不是需要逐像素测量的硬指标；实际以主色是否形成明确统治力为准。

---

## 6. 构图与空间

- 对称构图强调秩序、权力和仪式。
- 框架构图可借门洞、廊柱、窗棂、红纱、竹叶或兵器间隙窥视主体。
- 大量留白或负空间让人物显得孤立、受压或被命运包围。
- 场景锚点需稳定：廊柱间距、屏风位置、竹节密度、地平线高度、门洞比例等不能跨镜漂移。

```yaml
composition:
  primary:
    - 对称构图
    - 框架构图
    - 大量留白
  depth_devices:
    - 前景遮挡
    - 重复建筑构件
    - 自然媒介分层
```

---

## 7. 光影与质感

- 大侧光用于勾勒骨骼、衣物和兵器轮廓。
- 强逆光使发丝、雨滴、雪粒、沙尘和纱幕边缘发光。
- 暗部保持深邃玄色和层次，不使用无方向的大平光。
- 保留皮肤毛孔、汗水、尘土、粗麻、甲胄和纱料的真实质感。
- 可保留轻微胶片颗粒，避免现代美颜、塑料皮肤和过度锐化。

```yaml
lighting:
  preferred:
    - 大侧光
    - 强逆光
    - 高明暗对比
    - 有动机的自然光或火光
  forbidden:
    - 大平光
    - 无来源轮廓光
    - 现代磨皮美颜
```

---

## 8. 自然媒介系统

每个镜头原则上选择一种主要自然媒介并让它承担叙事功能：

- 风：推动衣摆、旗帜、纱幕、竹叶和尘土，表现力量方向。
- 雨：强调压迫、决断、身体负荷和金属质感。
- 雪：降低环境速度，放大静默与孤独。
- 沙：遮蔽视线、压缩纵深、制造荒凉和运动惯性。

```yaml
natural_media:
  required_per_shot: one_primary_medium
  choices:
    - 风
    - 雨
    - 雪
    - 沙
  rule: 媒介方向、密度和强度必须跨连续镜头保持可解释变化
```

---

## 9. 角色造型与表演

### 角色视觉锁

- 骨骼轮廓、肤色、眼型、发型发色。
- 服装材质、主色比例、宽袖或甲胄结构。
- 标志性兵器、饰物和佩戴位置。
- 同一角色不同镜头不得重新设计外观。

### 表演规则

- 动作克制：拔剑、回头、合眼、握紧、抬颌等均需有准备和完成状态。
- 不直接写“愤怒、悲伤、坚定”，而写可见生理表现。
- 优先组合眼部、口部、颈部和手部细节。
- 服装、风雨和道具的运动应回应身体力量，而不是独立乱动。

```yaml
performance:
  baseline: 仪式化、克制、缓慢、可见蓄力
  emotion_expression:
    - 眼睑与视线
    - 牙关与嘴唇
    - 颈部肌肉
    - 手指与指节
  avoid:
    - 抽象情绪标签替代动作
    - 夸张舞台式表情
    - 无准备的突然大动作
```

---

## 10. 镜头与剪辑节奏

### 慢节奏

- 单镜约 6–12 秒；固定长镜头占主导。
- 用风吹、叶落、雨滴或动作完成点作为剪切锚点。

### 中节奏

- 单镜约 4–8 秒；固定、缓推与轻手持混合。
- 以拔剑完成、转头到位、视线落点等动作节点切换。

### 快节奏

- 单镜约 2–4 秒，只用于高潮动作段。
- 连续快切后必须给出较长呼吸镜头。

```yaml
cinematography:
  baseline:
    - 固定长镜
    - 缓慢推进
    - 缓慢拉远
    - 升格慢动作
    - 克制手持微晃
  editing:
    default_transition: 直切
    optional_transition: 少量短溶解
    forbidden:
      - 滑动
      - 翻页
      - 数字缩放转场
```

---

## 11. 声音与音乐

```yaml
sound_design:
  priority:
    - 环境声
    - 动作与材质声
    - 背景音乐
  recurring_sources:
    - 风声
    - 雷雨
    - 雪地脚步
    - 金属摩擦
    - 沙尘冲击
  continuity: 环境声跨镜头尽量不断裂

voice_system:
  default_narration: false
  default_subtitles: false

music_direction:
  optional: true
  mood:
    - 沉郁
    - 宿命
    - 史诗
  instrumentation:
    - 弦乐
    - 低沉打击乐
    - 克制的传统器乐色彩
  mix_rule: 背景音乐低于环境声，不遮蔽关键材质声
```

---

## 12. 连续性锁

```yaml
continuity_schema:
  character:
    - 面容与骨骼轮廓
    - 发型
    - 服装材质与主色
    - 兵器与饰物状态
  environment:
    - 固定建筑构件
    - 主色域
    - 主光方向
    - 自然媒介方向与强度
  action:
    - 角色位置
    - 运动方向与速度
    - 道具交接状态
    - 前后镜身体惯性
```

连续动作中的插入特写至少保留两项可见证据，如兵器局部、衣摆方向、身体惯性、背景视差或雨沙方向。

---

## 13. 负面约束

- 不要杂色污染主色域。
- 不要大平光、塑料皮肤、美颜滤镜和过度锐化。
- 不要把抽象情绪词直接当作表演说明。
- 不要现代应用界面式排版、渐变色块或花哨数字转场。
- 不要为了制作便利删除 Hook、核心证据、Reveal 或 Content Thesis。

---

## 14. Production Adapter Reference

```yaml
production_modules:
  model_adapter_reference:
    image:
      - Nano Banana Pro
    video:
      - Seedance 2.5
      - Kling 3.0 Omni
    music:
      - Suno 5
      - Mureka 8
  asset_reference:
    character_board: 横版角色身份板
    scene_board: 横版场景身份板
  output_reference:
    aspect_ratio: 16:9
    target_resolution: 1080p_after_upscale
  replaceable: true
```

模型、分辨率、身份板排版和重试次数属于生产适配，不属于永久 Style Core。

---

## 15. 冲突与缺失项

```yaml
conflicts:
  - id: EPIC-COLOR-01
    issue: 四种主色方案并列存在
    resolution: 当前项目必须只选择一个主色域，不能默认混用
  - id: EPIC-MEDIA-01
    issue: 每镜必须放大一种自然媒介可能与室内静态场景冲突
    resolution: 室内可使用纱幕、烟尘、烛火或雨声等可见/可听媒介；仍不适用时标记 not_applicable

missing_or_partial:
  fixed_character_canon: 缺失
  exact_historical_period: 缺失
  narration_profile: 缺失
  full_music_system: 部分
  factual_historical_constraints: 缺失
```

---

## 16. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/张艺谋电影美学-国风武侠史诗历史.md

style_profile:
  style_id: ritualized_chinese_epic_color
  version: 1.0-zh
  classification: audiovisual_style_profile

  pre_content_modules:
    compatibility:
      authority: medium
      preferred:
        - 国风武侠
        - 历史史诗
        - 仪式化品牌叙事
    themes:
      authority: soft
      value:
        - 宿命
        - 牺牲
        - 权力
        - 抉择
    theme_expression_rules:
      authority: soft
      value: 以色彩、自然媒介和克制动作表达，少用解释性台词

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 单一主色统治、对称或框架构图、强侧逆光、深暗部、真实材质与轻胶片颗粒
    character_visual:
      authority: hard
      value: 骨骼轮廓、服装材质、主色和标志性道具锁定
    environment:
      authority: hard
      value: 固定建筑锚点与一种主要自然媒介共同构成空间
    cinematography:
      authority: high
      value: 固定长镜、缓推缓拉、升格和有限手持
    performance:
      authority: hard
      value: 仪式化克制动作，以生理细节代替抽象情绪词
    editing_rhythm:
      authority: medium
      value: 慢节奏为基线，高潮允许有限快切，默认直切
    sound_design:
      authority: high
      value: 环境和材质声优先，跨镜保持空间连续
    voice_system:
      authority: low
      value: 默认无旁白、无字幕
    music_direction:
      authority: medium
      value: 可选沉郁史诗底层，弦乐和低沉打击为主
    continuity_schema:
      authority: hard
      track:
        - 主色域
        - 光源方向
        - 自然媒介方向与强度
        - 服装与道具
        - 动作惯性

  production_modules:
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable
    generation_workflow: ignored_in_style_core

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/张艺谋电影美学-国风武侠史诗历史.md
        version: attached-2026-08-24
        sha256: F09882EF77A37E975EA9D2798F22E613CBBE63B40B3061A94876AFBA6BC125CF
    extracted_modules:
      - field: pre_content_modules
        source_section: planner + storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer + write_the_prompt + video_assembler
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator + planner
        extraction_type: direct
```
