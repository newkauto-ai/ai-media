# Style Profile：全尺寸羊毛毡世界（源文档名《羊毛毡动画风格》）

> **版本**：v1.0-zh  
> **源文档**：`羊毛毡动画风格.md`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`full_scale_wool_felt_world`  
> **解析原则**：把“羊毛毡材质世界”作为永久 Style Core；9:16、具体模型、三视图格式、占位符语法、逐镜确认等降到 `production_adapter_reference`。

---

## 0. 解析结论

这是一份 **材质主导型 Audiovisual Style Profile + Production Playbook**。它最有价值、最独特的地方不是“可爱”，而是一个非常明确的世界重建原则：

> **现实世界的角色、建筑、食物、场景和道具，都以真实尺度存在，但全部由羊毛毡材质重新建造。不是微缩模型、不是玩偶舞台、不是定格木偶。**

第二个关键特征是：**运动要流畅自然，而不是故意模仿传统定格动画的卡顿感。**

本次解析将以下内容提升为 Style Core：
- 全尺寸真实尺度
- 羊毛纤维覆盖所有表面
- 手工不均匀质感
- 柔软圆润、无锐角
- 暖哑色彩
- 柔和漫射光
- 构图简洁、背景 2–3 层
- 画面与旁白强语义对应
- 角色按主要角色 / 次要角色 / 群像进行比例分级
- 流畅自然动作
- 温暖、怀旧的音乐与旁白方向

---

## 1. 文档分类

```yaml
classification:
  primary: material_style_profile
  secondary:
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: false
    has_story_direction: partial
    has_worldview: true
    has_character_canon: false
    has_visual_system: true
    has_sound_system: partial
    has_voice_system: partial
    has_bgm_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
```

这里的 `worldview: true` 不是剧情世界观，而是**物质世界规则**：所有实体都由羊毛毡材质重建，但保持现实尺度与真实物体形状。

---

## 2. 适配范围

### 强适配
- 人情故事
- 家庭与日常
- 美食
- 手工艺
- 温暖回忆
- 小人物故事
- 轻知识叙事
- 需要“柔软、亲切、手作温度”的旁白短片

### 中等适配
- 商业故事
- 轻科普
- 历史小故事
- 情绪化数据表达
- 象征性群像

### 弱适配
- 写实战争
- 恐怖
- 高速动作
- 需要真实皮肤、真实金属硬度的题材
- 依赖精确屏幕文字或复杂 UI 的内容

---

## 3. 权威级

```yaml
authority:
  topic_direction: none
  story_direction: soft
  material_world_rule: hard
  character_visual: hard
  scene_visual: hard
  scale_rule: hard
  color_and_light: hard
  cinematography: hard
  motion_behavior: hard
  narration_alignment: hard
  sound_design: medium
  narration_voice: medium
  bgm_direction: medium
  continuity: low_medium
  production_model: none
```

---

## 4. Router A：Pre-Content

这份 Style Profile 基本不应参与 Topic Hunter 选题。

只允许提供两类软约束：

```yaml
pre_content:
  preferred_expression:
    - 温暖
    - 亲切
    - 手工感
    - 怀旧
    - 人情味

  narration_visual_alignment:
    required: true

  restrictions:
    - 不改写选题 Thesis
    - 不改事实
    - 不强行把严肃主题改成可爱故事
```

---

## 5. 世界材质规则

这是本 Profile 的最高权重。

```yaml
material_world:
  scale: 真实世界全尺寸
  base_material: 羊毛毡
  surface:
    - 可见羊毛纤维
    - 轻微不均匀的手工表面
    - 柔和织物光泽
    - 毡化纹理
  geometry:
    - 柔软圆润
    - 避免锐利棱角
  prohibited_interpretations:
    - 微缩模型
    - 沙盘
    - 玩偶舞台
    - 木偶
    - 玩具手办
```

### 非人物元素

建筑、房间、街道、食物、道具应保持**真实物体的形状与比例**：
- 饺子仍然像真实饺子
- 餐厅仍然是正常尺寸的餐厅
- 街道仍然是现实比例街道
- 不因为“毛毡”而自动 Q 版化所有物体

---

## 6. 角色造型分级

### 主要角色：写实感可爱
- 默认
- 头身比约 `1:3–1:4`
- 面部圆润温暖
- 身体与四肢仍有正常比例感
- 眼睛、鼻子、嘴巴必须清晰可读
- 可爱感主要来自毛毡材质与圆润面部，而不是夸张大头

### 次要角色：适度 Q 版
- 头身比约 `1:2`
- 比例更圆润
- 表情略夸张
- 保留辨识度

### 人群 / 象征性群像：高度 Q 版
- 头大体小
- 面部简化
- 适合多人画面与抽象情绪表达

### Router 解释
“不同角色层级可以使用不同造型级别”不等于“同一个重复角色可跨镜头任意改变比例”。源文档对重复角色连续性未明确，因此这一点应交由 Continuity 层另行约束，不在本 Profile 中自行补写为硬事实。

---

## 7. 色彩系统

```yaml
color:
  palette: 暖哑色
  examples:
    - 陶土暖棕
    - 灰粉
    - 鼠尾草绿
    - 奶油米白
  saturation: 低至中低
  avoid:
    - 高饱和纯红
    - 霓虹色
    - 刺眼数字色
```

色彩任务是强化“手工、柔软、温暖”，不是制造糖果色玩具感。

---

## 8. 光影

- 柔和漫射光
- 暖环境光
- 避免硬阴影
- 可使用浅景深
- 关键叙事节点允许更聚焦的戏剧性光照
- 仍应保留真实尺度空间感

```yaml
lighting:
  key: 柔和漫射
  ambient: 温暖
  contrast: low_to_medium
  hard_shadow: avoid
```

---

## 9. 构图与空间

- 主体突出
- 构图简洁
- 背景层次通常不超过 2–3 层
- 不把场景做成拥挤的玩具展示柜
- 真实尺度空间要可进入、可行走、可使用
- 关键叙事节点可用“聚光式构图”提高戏剧性

---

## 10. 镜头语言

### 推荐
- 缓慢推进
- 平稳平移
- 轻微跟随
- 自然轨道运动
- 中景到近景的温和变化

### 避免
- 手持抖动
- 快速变焦
- 快速碎切
- 镜头卡顿
- 过度剧烈旋转

### 关键差异
虽然“羊毛毡”容易让人联想到停格动画，但源文档明确要求：
- **流畅**
- **自然**
- **连贯**
- 不追求僵硬、卡顿或断续的定格感

---

## 11. 动作与表演

角色可以有自然幅度的动作：
- 伸手
- 转身
- 行走
- 轻轻前倾
- 点头
- 温暖微笑

但整体动作要：
- 柔和
- 连续
- 保持毛毡柔软质感
- 避免疯狂跳跃、剧烈挥舞、过度高速动作

---

## 12. 旁白与画面耦合

这是源文档的硬规则之一。

> **画面必须直接回应旁白正在说的内容。**

例如：
- 旁白说“饺子出锅”，画面核心就应是饺子出锅。
- 旁白说情绪转折，画面主体应以表情、姿态或环境同步表达转折。

禁止旁白已经进入下一个信息点，画面仍停留在上一段无关氛围。

```yaml
narration_visual_alignment:
  required: true
  semantic_distance: low
```

---

## 13. 声音设计

源文档规定：
- 视频内可含自然 SFX
- BGM 通常作为跨镜头独立音轨
- 若旁白为独立轨道，视频提示词不重复生成台词

Style Core 可保留：
- 轻微布料摩擦
- 柔和物体接触
- 安静室内环境
- 与材质相符的轻拟音

没有完整定义复杂声场系统。

---

## 14. Narration / Voice Profile

源文档只明确旁白的方向：
- 慢
- 温暖
- 温柔
- 真诚
- 略带怀旧

```yaml
narration:
  pace: 慢
  tone:
    - 温暖
    - 真诚
    - 轻柔
    - 略带怀旧
  fixed_gender: source_not_defined
  fixed_age: source_not_defined
```

---

## 15. BGM / Music Brief

```yaml
music:
  emotion:
    - 温暖
    - 治愈
    - 怀旧
    - 安静
  tempo: 慢
  suggested_instruments:
    - 柔和钢琴
    - 轻原声吉他
  density: 低
  independent_track: true
```

具体模型不进入 Style Core。

---

## 16. Prompt Assets

### 永久提示词结构意图

```yaml
prompt_assets:
  visual:
    order:
      - 世界材质规则
      - 主体
      - 角色比例等级
      - 羊毛纤维与手工表面
      - 暖哑色
      - 光线
      - 构图
      - 真实尺度约束
      - 负面约束

  video:
    order:
      - 参考资产
      - 羊毛毡世界规则
      - 场景氛围
      - 分段动作
      - 运镜
      - SFX
      - 负面约束
```

提示词正文最终应优先中文化；英文占位符语法只属于具体生产适配器。

---

## 17. Production Adapter Reference

```yaml
production_adapter_reference:
  replaceable: true

  source_mentions:
    aspect_ratio: "9:16"
    image_model:
      - Nano Banana Pro
    video_model:
      - Seedance 2.5
    music_model:
      - Suno 5
      - Mureka 8
    narration_model:
      - ElevenLabs v3
      - Doubao

  asset_format_reference:
    character_sheet: 16:9 白底三视图
    views:
      - 正面
      - 侧面
      - 四分之三背面

  shot_reference:
    outer_duration: 10-30s
    generator_duration_range: 4-30s
    internal_beats: 2-4
```

### 源文档中需要注意的规格关系
故事板建议镜头 `10–30 秒`，而生成工具范围写 `4–30 秒`。两者并不完全冲突：前者是故事板推荐，后者是技术能力边界。永久 Style Profile 不锁死任何秒数。

---

## 18. 负面约束

### 核心负面
- 不要微缩模型
- 不要沙盘
- 不要玩偶舞台
- 不要木偶感
- 不要玩具手办感
- 不要真实人类皮肤
- 不要光滑 CG 塑料感
- 不要锐利边缘
- 不要高饱和霓虹
- 不要快速乱飞镜头
- 不要僵硬卡顿运动

### 文字
源文档明确指出：文字类内容并不适合该风格，应尽量避免要求模型直接渲染复杂文本。

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
    - 羊毛毡材质可以重塑视觉，不得改写原文案事实
    - 旁白与画面必须强关联，但不能为了对齐画面而改旁白原意
    - 9:16 不是 Style Core，不得覆盖项目已锁定画幅
    - 角色 Q 版等级是视觉策略，不得把真实人物身份改成儿童或动物
```

---

## 20. 缺失项与可靠度

```yaml
missing_or_partial:
  topic_system: 缺失
  story_theme_system: 弱
  fixed_character_canon: 缺失
  detailed_voice_timbre: 缺失
  detailed_bgm_instrumentation: 部分
  recurring_character_continuity: 未明确
  video_assembler_rules: 缺失

reliability:
  material_world: very_high
  scale_rule: very_high
  character_visual: high
  color_and_light: high
  cinematography: high
  motion_behavior: high
  narration_alignment: high
  sound: medium
  music: medium
  continuity: low_medium
```

---

## 21. normalized_style_profile

```yaml
style_profile:
  id: full_scale_wool_felt_world
  version: "1.0-zh"
  source_name: 羊毛毡动画风格

  classification:
    primary: material_style_profile
    full_series_canon: false

  routing:
    pre_content:
      load:
        - warm_expression_preference
        - narration_visual_alignment
    audiovisual:
      load:
        - material_world
        - scale_rule
        - character_style_levels
        - color
        - lighting
        - composition
        - cinematography
        - motion_behavior
        - narration_visual_alignment
        - sound
        - narration
        - music
    production:
      load:
        - asset_format_reference
        - prompt_structure_reference
        - model_adapter_reference

  material_world:
    material: 羊毛毡
    scale: 真实世界全尺寸
    visible_fibers: true
    handmade_surface: true
    rounded_forms: true
    avoid:
      - 微缩模型
      - 沙盘
      - 玩偶舞台
      - 木偶
      - 玩具手办

  character:
    style_levels:
      main:
        ratio: "约 1:3–1:4"
        direction: 写实感可爱
      secondary:
        ratio: "约 1:2"
        direction: 适度 Q 版
      crowd:
        direction: 高度 Q 版

  visual:
    palette: 暖哑低饱和
    lighting: 柔和漫射
    background_layers: "2–3"
    realistic_scale_space: true

  cinematography:
    preferred:
      - 缓慢推进
      - 平稳平移
      - 轻微跟随
      - 自然轨道运动
    avoid:
      - 手持抖动
      - 快速变焦
      - 快速碎切
      - 卡顿运动

  motion:
    smooth_and_fluid: true
    stop_motion_jitter: false

  narration_visual_alignment:
    required: true

  narration:
    tone:
      - 温暖
      - 真诚
      - 轻柔
      - 略带怀旧

  music:
    tempo: 慢
    emotion:
      - 温暖
      - 治愈
      - 怀旧
    independent_track: true

  production_adapter_reference:
    replaceable: true
    source_mentions:
      - Nano Banana Pro
      - Seedance 2.5
      - Suno 5
      - Mureka 8
      - ElevenLabs v3
      - Doubao

  conflict_policy:
    no_silent_content_rewrite: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production

  provenance:
    extraction: source_grounded
    inferred_missing_fields: false
```
