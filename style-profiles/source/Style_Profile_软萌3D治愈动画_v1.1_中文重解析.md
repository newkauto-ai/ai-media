# Style Profile：软萌 3D 治愈动画（中文重解析版）

> **版本**：v1.1-zh  
> **源文档**：`软萌 3D 治愈动画.md`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`soft_cute_3d_healing`  
> **解析原则**：只提取源文档明确支持的内容；示例角色、示例剧情不升级为系列 Canon；模型、提示词语法、暂停节点等可替换执行细节不进入永久视听身份。

---

## 0. 解析结论

这份文档不是“纯视觉风格文档”，而是 **混合型 Style Profile + Production Playbook**。它同时包含轻剧情方向、软萌 3D 视觉体系、镜头与表演规则、声音/BGM 分层、图片与视频提示词模板，以及较多具体模型和生产流程规定。

本次重解析后的关键处理是：

1. **保留为 Style Core**：软萌 3D 的角色比例、眼睛、四肢、圆角形体、材质粗糙度、柔和光线、浅景深、低饱和暖色；小动作表演；一镜一主要运镜；角色一致性；轻柔音效；BGM 独立音轨。
2. **降级为 Pre-Content 兼容性建议**：轻剧情、小事件、治愈情绪、低冲突、分享/陪伴/等待/发现/安慰等，不允许覆盖 Topic Hunter 的 Content Thesis。
3. **不允许覆盖 Frozen Script**：四段式故事、示例剧情、示例角色、具体台词只作为风格参考，不能重写已冻结的 Hook、Reveal、Meaning、事实与对白语义。
4. **移入 Production Adapter**：GPT Image、Seedance、Suno、`@图片1`、特殊字符、分辨率、生成顺序、强制暂停点等。
5. **发现一个源文档内部矛盾**：文档多处写“60 秒默认 24 镜、每镜约 5 秒”，数学上约为 120 秒；而后面的完整示例实际使用 12 镜 × 5 秒 ≈ 60 秒。因此“24 镜”不能被提升为永久 Style Profile 规则，应由生产阶段根据时长重新计算。

---

## 1. 文档分类

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - story_direction_reference
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_worldview: false
    has_character_canon: false
    has_visual_system: true
    has_sound_system: true
    has_voice_system: partial
    has_bgm_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
```

**判断理由**：源文档明确定义了“动物治愈日常 / 幻想小生物童话 / 小孩温馨生活”等内容方向，也定义了完整视听与生产规则；但没有固定世界观、长期固定角色或系列 Canon，因此不应归为 Series Bible。

---

## 2. 适配范围

### 强适配
- 小动物治愈日常
- 幻想小生物童话
- 儿童温馨生活
- 小尺度单事件
- 分享、陪伴、发现、安慰、照顾、等待
- 低冲突、轻情节、情绪由平静/好奇走向温暖/安心的短片

### 弱适配
- 高密度知识解释
- 复杂悬疑和多层反转
- 快节奏动作
- 追逐、打斗、复杂群戏
- 依赖强压迫、强惊吓或持续高能冲突的题材

### Router Gate
若题材本身仍能保留原 Content Thesis，只是表达方式需要变得更温柔、小尺度，可判为 `acceptable`；若必须删掉核心冲突或反转才能套入此风格，应判为 `mismatch`，不能静默改写内容。

---

## 3. 权威级

```yaml
authority:
  topic_direction: soft
  story_direction: medium
  worldview: none
  character_canon: none
  visual_identity: hard
  character_visual: hard
  cinematography: hard
  performance: hard
  editing_rhythm: medium
  sound_design: hard
  dialogue_semantics: none
  voice_timbre: low
  voice_behavior: medium
  bgm_direction: hard
  continuity: hard
  prompt_template_reference: medium
  production_model: none
```

说明：

- `story_direction: medium` 仅表示在**剧本冻结前**可作为表达兼容性约束；剧本冻结后自动降为建议。
- 源文档没有固定角色音色参数，因此不能把 Voice Timbre 设为强权威。
- 具体模型与语法属于 Skill 4，不属于 Style Profile 权威。

---

## 4. Router A：Pre-Content 仅加载这些内容

```yaml
pre_content:
  preferred_content_shapes:
    - 轻剧情
    - 小事件
    - 单一情绪连接
    - 低冲突
  preferred_subjects:
    - 小动物
    - 幻想小生物
    - 儿童与小动物
  preferred_emotions:
    - 分享
    - 陪伴
    - 等待
    - 发现
    - 安慰
  emotional_arc:
    - 平静
    - 好奇或轻微困扰
    - 温柔互动
    - 安心或满足
  avoid:
    - 复杂追逐
    - 大规模战斗
    - 多角色同时复杂动作
```

**不得加载到 Topic Hunter 作为题材强制器的内容**：小狐狸、发光种子、森林小屋等均属于示例，不是 Canon。

---

## 5. 叙事与情绪表达

源文档偏好四段式轻剧情：“温暖开场 → 小事件 → 温柔互动 → 治愈收尾”。该结构可以作为 Script Engine 的**风格建议**，但不作为硬结构模板。

叙事核心不是强反转，而是让“小事件”成为情绪连接的载体。互动应简单、可视、低成本，例如靠近、观察、递出、照顾、种植、拥抱、等待结果。结尾倾向停留在一个温暖、安静、有余味的状态。

---

## 6. 角色视觉系统

### 6.1 造型比例
- 头身比：约 `1:1.5–1:2`
- 头大身小
- 四肢短、圆、粗，弱化骨节
- 脸颊饱满
- 眼睛约占脸部面积 `25%–35%`
- 眼睛圆润、存在清晰高光
- 形体边缘采用柔和圆角倒角，避免锐利棱角

### 6.2 材质
- 毛绒：高粗糙度、哑光、可见细绒
- 木质 / 陶瓷：中等粗糙度、低反光
- 奶油感表面：视觉上光滑柔软，但避免塑料高光
- 总体禁止廉价塑料玩具感、过度镜面反射

### 6.3 角色一致性硬锁
跨镜头不可漂移：
- 主色与副色
- 服装款式、颜色、图案位置
- 配件
- 眼睛形状与高光特征
- 耳朵、尾巴的尺寸与形态
- 头身比
- 四肢粗细
- 脸颊饱满度

每个出现该角色的生产镜头，应持续绑定同一角色逻辑资产。

---

## 7. 色彩、光影、景深与场景

### 色彩
- 总体低饱和
- 暖色倾向
- 常见可用色：奶油白、浅木色、浅绿色、奶油橘、柔和雨后蓝、暖黄色
- 避免刺眼高饱和、冷灰脏光

### 光线
- 侧前方约 45° 的柔和漫射主光
- 对侧弱反射补光
- 避免硬顶光、强硬轮廓光、冷色硬光、死白光

### 景深
- 浅景深
- 源文档给出等效 `f/1.8–2.8`
- 主体清晰，背景柔和虚化
- 不追求全景深从前到后全部清晰

### 场景
- 干净、视觉焦点明确
- 给角色保留活动区
- 道具少而明确
- 材质容易辨识
- 强调生活感与童话感，不堆杂物

---

## 8. 镜头语言与剪辑节奏

### 可用运镜
- 固定机位
- 缓慢推进
- 轻微横移
- 缓慢后拉
- 平稳跟拍
- 轻微上摇
- 轻微下摇

### 硬规则
- 一镜只保留一个主要运镜
- 一镜只安排一个主要动作
- 镜头运动克制、稳定、可预测
- 结尾允许更长的情绪停留

### 禁止
- 360° 环绕
- 快速旋转
- 突然变焦
- 多重运镜同时叠加
- 大幅度手持晃动
- 高频角度乱切

### 节奏
源文档总体倾向“开场慢 → 小事件略加速 → 温柔互动放缓 → 结尾最慢”。具体镜头数与时长不锁死，由 Production Manifest 决定。

---

## 9. 角色表演与物体互动

### 表演尺度
- 小动作
- 细表情
- 不夸张
- 不持续大幅运动

常见动作：
- 眨眼
- 抬头 / 低头
- 伸手 / 递出
- 抱紧
- 轻触
- 慢慢靠近
- 小心观察
- 耳朵微动
- 尾巴轻摆

### 物体互动五步法
1. 先看向物体
2. 慢慢靠近
3. 产生明确接触
4. 物体给出轻微反馈
5. 角色产生表情变化

这条规则属于高价值、可复用的表演语法。

---

## 10. 声音设计

### 视频内
- 台词
- 环境音
- 轻微拟音

适配声源：
- 雨滴
- 水滴
- 布料摩擦
- 陶瓷轻碰
- 泥土
- 木质接触
- 鸟鸣
- 轻微发光 / 奇幻反馈声

### 声音气质
- 干净
- 轻柔
- 近距离
- 不喧闹
- 与小动作同步

### Voice
源文档只说明台词可随镜头同步生成，**没有定义可复用的固定音高、音色、共鸣、口音、语速范围**。因此运行时应由 Skill 3 根据具体角色另建 `recommended_runtime_voice_profile`，并标记为“运行时推荐”，不可伪装为源文档定义。

---

## 11. BGM / Music Brief

### 源文档明确规则
- BGM 独立为 `audio_layer`
- 不写入视频生成 Prompt
- 后期叠加
- 音乐应与整体治愈情绪线一致
- 倾向慢、舒缓、温暖、安静

### 乐器方向
- 轻柔木琴
- 钢片琴
- 弦乐
- 温暖环境氛围

### 规范化 Music Brief
```yaml
music:
  narrative_function: 托住治愈氛围，不抢夺小动作与表情
  emotional_arc: 平静 -> 好奇 -> 温暖 -> 安心
  tempo: 慢
  rhythm_density: 低
  melody_strength: 低到中
  preferred_instruments:
    - 轻柔木琴
    - 钢片琴
    - 柔和弦乐
  avoid:
    - 强鼓点
    - 高频密集节奏
    - 过度煽情
    - 压过对白和拟音
  independent_track: true
```

---

## 12. 连续性

Style Profile 要求至少锁定：
- 角色颜色
- 服装与配件
- 眼睛
- 耳朵 / 尾巴
- 体型比例
- 道具位置与状态
- 场景光线与色调
- 角色前后情绪状态

单镜失败时，优先只重做该镜，并保持角色资产绑定不变。

---

## 13. Prompt Assets：只保留模板意图，不锁死模型

可保留的模板类型：
- 角色资产图模板
- 场景资产图模板
- 道具资产图模板
- 首帧模板
- 尾帧模板
- 视频 Prompt 结构模板
- 负面约束包

永久模板的核心字段应是：

```text
主体
+ 造型比例
+ 表情
+ 场景
+ 小事件
+ 材质
+ 光线
+ 色彩
+ 构图
+ 动作
+ 运镜
+ 声音
+ 连续性
+ 负面约束
```

不要永久绑定某一具体模型语法。

---

## 14. Production Adapter Reference

以下来自源文档，但应由 Skill 4 当前适配器决定是否继续使用：

```yaml
production_adapter_reference:
  image_model_reference:
    - GPT Image 2
  video_model_reference:
    - Seedance 2.5
  music_model_reference:
    - Suno 5
  asset_binding_reference:
    - "@图片1"
    - "<主角>"
    - "<场景>"
    - "<道具>"
  audio_markup_reference:
    sfx: "<...>"
    dialogue: "{...}"
    onscreen_text: "【...】"
  workflow_reference:
    - 先主角资产
    - 再场景/道具/首尾帧
    - 先试做开场镜头
    - 再批量后续镜头
    - BGM 最后独立生成
```

这些全部是**可替换执行细节**，不是软萌治愈风格本身。

---

## 15. 冲突处理

### 不得覆盖
- Content Thesis
- 事实与证据
- Hook
- Reveal
- Meaning
- 已冻结对白的核心语义
- 已确认系列 Canon

### 可在不改语义前提下调整
- 场景表达
- 动作尺度
- 镜头速度
- 构图
- 表演细节
- 环境音
- BGM
- 资产视觉材质

### 优先级
```yaml
priority:
  topic_thesis:
    - user_current_instruction
    - explicit_series_bible
    - topic_hunter
    - style_profile_soft_constraints

  script_semantics:
    - user_current_instruction
    - frozen_script
    - script_engine
    - style_profile_story_preferences

  visual:
    - user_current_override
    - series_visual_canon
    - style_profile
    - audiovisual_defaults

  voice:
    - user_current_override
    - series_voice_canon
    - runtime_voice_profile
    - style_profile_voice_behavior

  bgm:
    - user_current_override
    - series_music_canon
    - style_profile
    - music_director_defaults

  final_model_prompt_syntax:
    - video_production_current_adapter
    - stored_template
    - style_profile_reference
```

---

## 16. 缺失项与可靠度

| 模块 | 状态 | 说明 |
|---|---|---|
| 视觉风格 | 高可靠 | 源文档非常明确 |
| 角色一致性 | 高可靠 | 明确列出跨镜头锁定字段 |
| 镜头语言 | 高可靠 | 明确一镜一运镜 |
| 表演 | 高可靠 | 明确一镜一动作与互动五步法 |
| 声音 | 中高可靠 | 主要是轻拟音与分层规则 |
| 固定角色音色 | 缺失 | 只有台词生成方式，没有稳定音色定义 |
| 世界观 | 缺失 | 没有固定世界规则 |
| 长期角色 Canon | 缺失 | 示例角色不能当 Canon |
| 镜头数量 | 冲突 | “24 镜 × 5 秒 = 60 秒”不成立，不能锁死 |
| 模型参数 | 可替换 | 进入 Production Adapter |

---

# 17. 机器可读 Normalized Style Profile

```yaml
style_profile:
  meta:
    style_id: soft_cute_3d_healing
    display_name: 软萌 3D 治愈动画
    version: v1.1-zh
    source_files:
      - 软萌 3D 治愈动画.md
    language: zh-CN

  classification:
    primary: hybrid_style_profile
    full_series_canon: false

  compatibility:
    best_for:
      - 轻剧情治愈
      - 小动物
      - 幻想小生物
      - 儿童温馨故事
      - 小尺度单事件
    weak_for:
      - 复杂悬疑
      - 高密度知识解释
      - 战斗
      - 快节奏动作
      - 大规模群戏

  scope:
    topic_direction: true
    story_direction: true
    worldview: false
    character_canon: false
    visual_style: true
    character_visual: true
    cinematography: true
    performance: true
    sound_design: true
    voice_direction: partial
    bgm_direction: true
    prompt_templates: true
    model_specific_rules: true
    production_workflow: true

  authority:
    topic_direction: soft
    story_direction: medium
    visual: hard
    character_visual: hard
    cinematography: hard
    performance: hard
    sound: hard
    voice_timbre: low
    voice_behavior: medium
    bgm: hard
    continuity: hard
    production_model: none

  routing:
    pre_content:
      load:
        - preferred_content_shapes
        - preferred_emotions
        - emotional_arc
        - low_conflict_preference
    audiovisual:
      load:
        - visual_identity
        - character_visual_consistency
        - cinematography
        - performance
        - sound_design
        - voice_behavior
        - music_direction
        - continuity
    production:
      load:
        - prompt_template_reference
        - negative_constraints
        - model_adapter_reference
        - workflow_reference

  narrative:
    preferred_structure:
      - 温暖开场
      - 小事件
      - 温柔互动
      - 治愈收尾
    structure_authority: advisory
    conflict_intensity: low
    theme_expression: 通过小动作和互动表达，不靠复杂对白

  worldview:
    source_defined: false

  character:
    proportions:
      head_body_ratio: "1:1.5–1:2"
      eyes_face_area: "25%–35%"
      limbs: 短圆粗
      edges: 柔和圆角倒角
    consistency_lock:
      - 主色与副色
      - 服装
      - 配件
      - 眼睛形状与高光
      - 耳朵
      - 尾巴
      - 头身比
      - 四肢粗细
      - 脸颊饱满度

  audiovisual:
    visual_identity:
      format: 原创软萌 3D 治愈动画
      saturation: 低
      color_mood: 温暖
      material_finish: 哑光低反光
      lighting: 侧前方柔和漫射光
      depth_of_field: 浅景深
    cinematography:
      preferred:
        - 固定机位
        - 缓慢推进
        - 轻微横移
        - 缓慢后拉
        - 平稳跟拍
        - 轻微上摇
        - 轻微下摇
      one_primary_camera_move_per_shot: true
    performance:
      one_primary_action_per_shot: true
      interaction_sequence:
        - 看向
        - 靠近
        - 接触
        - 物体反馈
        - 表情变化
    sound:
      in_video:
        - dialogue
        - ambience
        - foley
        - sfx
      bgm_embedded_in_video_prompt: false

  music:
    role: 独立背景音乐
    tempo: 慢
    rhythm_density: 低
    emotional_arc:
      - 平静
      - 好奇
      - 温暖
      - 安心
    instruments:
      - 轻柔木琴
      - 钢片琴
      - 柔和弦乐

  continuity:
    required: true
    lock_character_asset_across_shots: true
    retry_failed_shot_only: true

  prompt_assets:
    template_types:
      - character_asset
      - scene_asset
      - prop_asset
      - first_frame
      - end_frame
      - video
      - negative_constraints

  production_adapter_reference:
    replaceable: true
    source_mentions:
      - GPT Image 2
      - Seedance 2.5
      - Suno 5
    known_source_conflict:
      - "60 秒 + 24 镜 + 每镜约 5 秒存在算术冲突，不应锁死"

  conflict_policy:
    no_silent_content_rewrite: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production

  provenance:
    extraction: source_grounded
    examples_are_canon: false
    inferred_missing_fields: false
```
