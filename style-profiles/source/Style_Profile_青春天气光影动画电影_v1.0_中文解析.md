# Style Profile：青春天气光影动画电影（源文档名《新海诚动画电影风格》）

> **版本**：v1.0-zh  
> **源文档**：`新海诚动画电影风格.md`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`youth_weather_luminous_anime`  
> **解析原则**：正文与规则尽量中文化；创作者姓名与具体影片名只保留在来源说明，不作为运行时提示词依赖；模型、分辨率、生成工具和暂停节点进入 `production_adapter_reference`。

---

## 0. 解析结论

这份文档应归类为 **叙事风格参考 + 视听风格 Profile + 轻量生产 Playbook**。真正稳定、可跨模型复用的核心，不是某个创作者姓名，而是以下组合：**青春情感主题、距离与时间感、天气驱动的情绪、天空与城市光影、普通年轻角色、环境意象叙事、克制略伤感的第一人称旁白、钢琴为中心的音乐系统**。

本次解析做四个关键处理：

1. 把“成长、距离、时间、遗憾、思念、重逢、选择、命运”保留为 `Pre-Content` 风格兼容性信号，但不允许覆盖 Topic Hunter 已确定的核心 Thesis。
2. 把“东京街道、神社、电车站、校园”等降为**场景原型库**，不是固定世界 Canon。
3. 把具体影片对应的 BGM 模仿方式抽象成“钢琴独奏 / 钢琴+环境 / 钢琴+弦乐 / 钢琴+电子 / 钢琴+无词人声”五类音乐配器模板。
4. 把创作者姓名、具体影片名、Seedance、Nano Banana、Suno、2K/480p 等全部降到生产适配层，不进入永久视听身份。

---

## 1. 文档分类

```yaml
classification:
  primary: audiovisual_style_profile
  secondary:
    - narrative_style_reference
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_worldview: false
    has_character_canon: false
    has_visual_system: true
    has_sound_system: partial
    has_voice_system: partial
    has_bgm_system: true
    has_prompt_templates: partial
    has_model_specific_rules: true
    has_production_workflow: true
```

---

## 2. 适配范围

### 强适配

- 青春成长
- 异地、距离、错过、等待
- 相遇、陪伴、分离、重逢
- 时间流逝与记忆
- 校园、城市、通勤、旅行
- 雨天、黄昏、星空、云海、雪景等天气驱动叙事
- 需要“环境先表达情绪、人物后表达情绪”的短片

### 弱适配

- 纯动作爽片
- 高密度知识口播
- 黑色喜剧
- 极度冷硬的商业广告
- 复杂政治、战争或群像史诗
- 主要依靠连续对话而非环境意象推进的故事

### Style Compatibility Gate

若原选题的核心结论能够在不改语义的前提下，用“天气、时间、距离、城市空间、光影”加强表达，则判定 `acceptable`。若为了套风格必须把原故事改造成青春爱情或重逢故事，则判定 `mismatch`，不得静默改写。

---

## 3. 权威级

```yaml
authority:
  topic_direction: soft
  story_direction: medium
  worldview: none
  character_canon: none
  visual_identity: hard
  weather_mood_system: hard
  color_and_light: hard
  cinematography: hard
  performance: medium
  sound_design: medium
  dialogue_semantics: none
  narration_style: hard
  voice_timbre: low
  bgm_direction: hard
  continuity: medium
  production_model: none
```

---

## 4. Router A：Pre-Content

```yaml
pre_content:
  preferred_themes:
    - 成长
    - 距离
    - 时间
    - 遗憾
    - 思念
    - 重逢
    - 选择
    - 命运

  preferred_emotional_arcs:
    - 相遇 → 陪伴 → 分离 → 重逢
    - 平静 → 想念 → 寻找 → 释然
    - 希望 → 错过 → 等待 → 再次连接

  preferred_story_devices:
    - 天气变化
    - 时间变化
    - 通勤与移动
    - 信件或信息
    - 雨伞
    - 车票
    - 手机
    - 项链等情绪物件

  restrictions:
    - 不得强制增加爱情线
    - 不得改写已确认的事实与结论
    - 不得把场景原型误当固定世界设定
```

---

## 5. 视觉身份

### 核心视觉

- 动画电影静帧感
- 高精度环境背景
- 天空占据重要视觉权重
- 天气与情绪绑定
- 强调大气透视、体积光、反射光与城市光源
- 人物外观相对普通、自然、生活化
- 环境往往比人物更华丽、更具象征性

### 内部中性描述

```yaml
visual_identity:
  medium: 高质量二维动画电影
  environment_detail: 高
  sky_importance: very_high
  weather_driven: true
  realism_balance: 生活化人物 + 高精度理想化环境
  emotional_image_quality:
    - 明亮
    - 通透
    - 细腻
    - 略带梦境感
```

---

## 6. 色彩系统

### 晴空系
- 主色：天空蓝
- 辅色：云层白
- 点缀：阳光金
- 情绪：希望、青春、未来

### 黄昏系
- 主色：橙金
- 辅色：紫红
- 点缀：深蓝
- 情绪：遗憾、怀念、离别

### 雨天系
- 主色：青灰蓝
- 辅色：雨雾白
- 点缀：暖色城市光
- 情绪：孤独、思念、等待

### 夜景系
- 主色：深蓝
- 辅色：月光白
- 点缀：城市灯光橙
- 情绪：梦境、距离感、希望

> 源文档把“暖色霓虹”列为雨天点缀，但本 Profile 不把“霓虹”升级为必需元素；核心是**冷环境与暖人造光的对比**。

---

## 7. 天气系统

源文档将天气设为最高优先级的视觉情绪系统。

```yaml
weather_system:
  highest_priority:
    - 黄昏
    - 流星
    - 云海
    - 星空
    - 雨后放晴
  high_priority:
    - 暴雨
    - 晚霞
    - 雪景
    - 晨曦
  normal:
    - 阴天
    - 晴天
    - 微风
```

这些等级应理解为**风格推荐强度**，不是每条视频都必须出现 S 级天气。

---

## 8. 光影规则

每个重要镜头都应明确三个层次：

1. **主光源**：夕阳、月光、阳光、路灯等明确方向光。
2. **次光源**：窗户光、地面反射、城市灯光、建筑反光。
3. **环境光**：天空漫反射、空气透视、雨雾、体积光。

重点不是“把画面打亮”，而是通过**光线来源与天气共同塑造情绪**。

---

## 9. 场景原型库

### 城市
- 街道
- 商业街
- 天桥
- 电车站
- 十字路口

### 校园
- 教室
- 操场
- 图书馆
- 天台
- 走廊

### 自然
- 海边
- 山路
- 森林
- 河堤
- 宗教或传统建筑周边空间

### 雨景
- 公园
- 凉亭
- 公交站
- 便利店门口

### 黄昏
- 放学路
- 铁路道口
- 河岸
- 桥梁

### 夜景
- 城市夜景
- 高楼天台
- 灯火街区
- 车站

**Router 规则**：这些是可调用原型，不是固定地点，更不强制使用某个现实城市。

---

## 10. 角色设计与表演

### 角色倾向
- 年轻角色为主
- 普通人
- 自然感
- 生活化

源文档给出 14–25 岁与学生、上班族、摄影师、咖啡店店员、自由职业者、旅行者等身份。该范围作为**风格倾向**，不应变成硬限制。

### 表演原则
源文档没有建立详细微表情系统，因此本 Profile 只保留有明确支持的部分：
- 行走
- 奔跑
- 仰望
- 静止等待
- 背影
- 风吹头发与衣物
- 回忆段落的慢动作表现

`micro_expression_system`：源文档未明确。

---

## 11. 镜头语言

```yaml
cinematography:
  motifs:
    M01: 风吹人物与植物
    M02: 固定机位观看云层流动
    M03: 列车经过而人物相对静止
    M04: 仰望天空
    M05: 雨滴、积水与波纹
    M06: 逆光、体积光与镜头光晕
    M07: 回忆段落的慢动作、柔光、低对比
    M08: 人物背影行走，环境缓慢移动
    M09: 奔跑、寻找、重逢等高潮动作
```

### 镜头使用逻辑

- 环境空镜可承担情绪表达，不必每镜都有人。
- 高潮可从“静止/等待”切换到“奔跑/寻找”。
- 天空、云、雨、列车、灯光等均是叙事元素，而不只是背景装饰。
- 默认镜头时长 `5–8 秒` 属于源文档生产建议，进入 Production Adapter，不作为永久风格硬规则。

---

## 12. 声音设计

源文档的声音系统相对薄弱，主要明确：
- 旁白
- BGM
- 视频轨

没有完整定义环境拟音、角色对白音色、声场和 Foley 规则。

因此：

```yaml
sound_design:
  authority: medium
  environment_sfx: source_not_explicit
  dialogue_system: source_not_explicit
  narration: defined
  bgm: defined
```

不要从其他 Style Profile 自动补入复杂音效规则。

---

## 13. Narration / Voice Profile

### 旁白风格

- 第一人称
- 青春文学感
- 克制
- 轻微伤感
- 常用回望式表达
- 适合把普通瞬间与多年后的记忆连接起来

```yaml
narration:
  point_of_view: 第一人称
  tone:
    - 克制
    - 清澈
    - 轻微伤感
    - 回忆感
  pacing: 偏舒缓
  semantics_owner: Script Engine
```

### 音色

源文档未定义固定性别、年龄、音高或具体 timbre，因此 `voice_timbre: low`。

---

## 14. BGM / Music Brief

本次将源文档里的具体影片指代抽象成五类可复用音乐模板：

1. **钢琴独奏**：孤独、距离、记忆。
2. **钢琴 + 环境氛围**：雨、窗边、城市静夜、独处。
3. **钢琴 + 弦乐**：重逢、选择、情绪升华。
4. **钢琴 + 轻电子**：现代城市、天气异变、青春推进感。
5. **钢琴 + 无词人声**：命运感、梦境感、宏观情绪。

```yaml
music:
  core_instrument: 钢琴
  optional_layers:
    - 环境氛围
    - 弦乐
    - 轻电子
    - 无词人声
  emotional_keywords:
    - 青春
    - 思念
    - 距离
    - 时间
    - 希望
    - 轻微伤感
  independent_track: true
  avoid_specific_artist_or_work_dependency: true
```

---

## 15. 连续性

源文档要求各镜头通过角色、场景、道具元素图和必要的上一镜头视频保持连续，但没有给出完整状态账本。

Style Core 只保留：
- 角色外观连续
- 场景视觉连续
- 情绪物件连续
- 高连续动作镜头需要加强前后状态继承

具体 `asset_id` 与 `reference_video` 属于生产实现。

---

## 16. Prompt Assets

永久保留的提示词意图结构：

```yaml
prompt_assets:
  image:
    - 角色
    - 场景
    - 情绪物件
    - 天气
    - 光源
    - 色彩
  video:
    - 主体动作
    - 天气运动
    - 环境运动
    - 运镜
    - 光线变化
    - 情绪
  music:
    - 情绪
    - 钢琴核心
    - 可选配器
```

不锁死任何具体英文风格关键词。

---

## 17. Production Adapter Reference

以下来自源文档，但属于可替换生产配置：

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    image_model:
      - Nano Banana Pro
    video_model:
      - Seedance 2.5
    music_model:
      - Suno 5
    resolution:
      image: 2K
      video: 480p
    default_shot_duration: 5-8s
    workflow:
      - 故事分析
      - 全局规格
      - 故事板
      - 元素图
      - 关键帧
      - 逐镜视频
      - 旁白
      - BGM
      - 合成
```

---

## 18. 负面约束

### 风格层
- 避免让人物造型过度夸张或奇幻化
- 避免环境完全静态、天气没有作用
- 避免每镜都只靠人物说话推进
- 避免把天空、光线和天气当纯装饰

### 合成层
源文档明确：
- 不烧录字幕
- 不使用夸张转场
- 不使用突兀的 3D 特效
- 不使用过度滤镜
- 默认直切，章节间可淡入淡出

---

## 19. 冲突处理

```yaml
conflict_policy:
  no_silent_content_rewrite: true
  topic_owner: Topic Hunter
  script_semantics_owner: Script Engine
  audiovisual_owner: Audiovisual Director
  final_model_prompt_owner: Video Production

  rules:
    - 风格可建议“距离/时间/天气”表达，但不能强迫原故事变成青春爱情
    - 角色身份和地点原型只能建议，不能覆盖已锁定角色与场景
    - 第一人称旁白只在 Script Engine 允许旁白时启用
    - BGM 只定义情绪与配器，不改剧情
```

---

## 20. 缺失项与可靠度

```yaml
missing_or_partial:
  fixed_character_canon: 缺失
  detailed_worldview: 缺失
  character_voice_timbre: 缺失
  dialogue_style_system: 缺失
  detailed_foley_system: 缺失
  continuity_ledger: 缺失
  negative_prompt_system: 部分

reliability:
  visual_identity: high
  color_and_weather: high
  cinematography: high
  narration: high
  bgm: high
  performance: medium
  sound_design: low_medium
  continuity: medium
```

---

## 21. normalized_style_profile

```yaml
style_profile:
  id: youth_weather_luminous_anime
  version: "1.0-zh"
  source_name: 新海诚动画电影风格
  classification:
    primary: audiovisual_style_profile
    full_series_canon: false

  scope:
    topic_direction: true
    story_direction: true
    visual_style: true
    weather_system: true
    cinematography: true
    narration: true
    bgm: true
    sound_design: partial
    character_canon: false

  routing:
    pre_content:
      load:
        - preferred_themes
        - preferred_emotional_arcs
        - weather_as_story_device
    audiovisual:
      load:
        - visual_identity
        - color_system
        - weather_system
        - light_system
        - scene_archetypes
        - cinematography
        - narration_style
        - music_direction
        - continuity
    production:
      load:
        - asset_reference
        - model_adapter_reference

  visual_identity:
    format: 高质量二维动画电影
    environment_detail: high
    sky_importance: very_high
    weather_driven: true
    character_look: 普通、自然、生活化

  color_system:
    clear_sky: 天空蓝 + 云白 + 阳光金
    dusk: 橙金 + 紫红 + 深蓝
    rain: 青灰蓝 + 雨雾白 + 暖色人造光
    night: 深蓝 + 月光白 + 城市灯光橙

  weather:
    preferred:
      - 黄昏
      - 流星
      - 云海
      - 星空
      - 雨后放晴
      - 暴雨
      - 晚霞
      - 雪景
      - 晨曦

  cinematography:
    motifs:
      - 风吹
      - 云层
      - 列车经过
      - 仰望天空
      - 雨滴积水
      - 逆光体积光
      - 回忆慢动作
      - 背影行走
      - 奔跑寻找

  narration:
    point_of_view: 第一人称
    tone:
      - 克制
      - 青春
      - 轻微伤感
      - 回忆感

  music:
    core: 钢琴
    optional:
      - 环境氛围
      - 弦乐
      - 轻电子
      - 无词人声
    independent_track: true

  production_adapter_reference:
    replaceable: true
    source_mentions:
      - Nano Banana Pro
      - Seedance 2.5
      - Suno 5

  conflict_policy:
    no_silent_content_rewrite: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production

  provenance:
    extraction: source_grounded
    creator_name_runtime_dependency: false
    specific_work_runtime_dependency: false
    inferred_missing_fields: false
```
