# Style Profile：暗黑东方神话废墟奇幻（源文档名《暗黑中式奇幻短片（黑神话悟空风格）》）

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/暗黑中式奇幻短片 (黑神话悟空风格).md`  
> **源文件 SHA-256**：`12C3C0174DA2E8A0BF997D94F8800FE9CA08EA9169588A6F1174DE86DA2E4500`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`dark_eastern_mythic_ruins`  
> **重要说明**：源文档高度依赖具体 IP、角色、武器、法术和作品风格。本解析强制拆成 **可复用 Style Core** 与 **`source_ip_reference` 专属层**。只有明确选择对应 IP/系列时，才允许加载专属层。

---

## 0. 解析结论

这份源文档不是单纯的“美术风格”，而是 **IP 专属 Narrative/Combat Bible + Audiovisual Style Bible + Production Playbook**。其中最可复用的视听核心是：

- 暗黑东方神话
- 废墟美学
- 古建、石窟、泥塑、青铜、战损材质
- 深灰 / 暗褐 / 黛绿 / 暗红 / 暗金为主的低饱和色系
- 极强冷暖色温对冲
- 丁达尔体积光
- 风沙、灰烬、雾、碎石等高密度环境粒子
- 巨大造像与渺小人物形成尺度压迫
- 重物理、重惯性、重打击感
- 动作镜头的起势 / 释放 / 碰撞 / 收势分解
- 空间声学、低频重击、法术高频共鸣
- 中国传统乐器与暗黑史诗配器融合
- 低沉、沧桑、宿命感旁白

本次解析最关键的架构处理：**悟空、金箍棒、具体五种法术、Boss 造型、章节书法等不直接写入通用 Style Core。**

---

## 1. 文档分类

```yaml
classification:
  primary: ip_specific_audiovisual_bible
  secondary:
    - combat_style_bible
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: partial

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_worldview: true
    has_character_canon: true
    has_visual_system: true
    has_sound_system: true
    has_voice_system: true
    has_bgm_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
    has_ip_specific_content: true
```

---

## 2. 适配范围

### 强适配
- 东方神话
- 神魔奇幻
- 古代遗迹
- 破败寺庙、石窟、荒岭、幽谷
- 宿命感
- 高压迫感 Boss
- 重兵器对战
- 法术与物理环境交互
- 废墟与文明残响
- 黑暗、肃杀、史诗感

### 弱适配
- 轻治愈
- 日常喜剧
- 现代都市爱情
- 清新儿童故事
- 明亮商业广告
- 高饱和未来科技霓虹

### Style Compatibility Gate
若故事可在不改变核心语义的前提下，使用“暗黑东方神话 + 废墟 + 宿命 + 重物理”包装，则可加载通用 Style Core。若必须引入悟空、金箍棒或特定法术才能成立，则应要求显式加载 `source_ip_reference`，不能默认注入。

---

## 3. 权威级

```yaml
authority:
  topic_direction: medium
  story_direction: medium
  worldview: medium_high
  generic_visual_identity: hard
  generic_material_system: hard
  generic_cinematography: hard
  combat_grammar: hard
  physics: hard
  environment_particles: hard
  sound_design: hard
  narration_voice: hard
  bgm_direction: hard

  ip_character_canon: conditional_hard
  ip_prop_canon: conditional_hard
  ip_spell_canon: conditional_hard

  dialogue_semantics: none
  production_model: none
```

---

## 4. Router A：Pre-Content

```yaml
pre_content:
  preferred_themes:
    - 宿命
    - 神性与人性
    - 文明残响
    - 衰败
    - 试炼
    - 生死对决
    - 孤独
    - 远古力量

  preferred_tone:
    - 压抑
    - 神秘
    - 苍凉
    - 肃杀
    - 史诗

  restrictions:
    - 不得默认加入具体 IP 角色
    - 不得默认加入特定武器或法术
    - 不得改写 Topic Hunter 已确定的 Thesis
```

---

## 5. 通用世界观与场景语法

### 废墟美学
- 风化
- 剥落
- 战损
- 残缺
- 青苔
- 锈蚀
- 断壁残垣
- 巨型造像
- 古建构件
- 石刻与泥塑

### 尺度
- 巨型佛像 / 神像 / 建筑构件
- 小尺度人物
- 强烈尺度反差
- 空间必须有纵深与雾层

### 环境不是静态背景
- 风沙形成带状涡旋
- 灰烬漂浮
- 尘埃在体积光中可见
- 枯叶、烟雾、纸符可流动
- 剧烈能量可导致碎石悬浮或异常重力
- 粒子与角色斗篷、铠甲产生物理接触

---

## 6. 色彩系统

### 基础色
- 深灰
- 暗褐
- 黛绿 / 青黑
- 暗红
- 暗金
- 低饱和蓝灰

### 暖高光
- 暗金
- 铜色
- 金红
- 炽热橙金

### 冷暗部
- 黛绿
- 冰蓝
- 青灰
- 靛蓝

### 核心规则
**冷暖色温对冲是硬规则。**  
角色、建筑、法术碰撞均可使用：
- 暖色受光面
- 冷色背光面
- 瞬态暖爆发
- 冷色余震扩散

---

## 7. 光影系统

### 高反差
- 强明暗对比
- 低照度环境
- 集中高亮区
- 大面积深暗部

### 丁达尔体积光
- 强光束穿透破损屋顶、石缝、烟尘或树冠
- 光束中可见微尘、灰烬
- 光柱应与周围深暗环境形成极强亮度差

### 逆光金边
- 角色轮廓可用金色或暖色 Rim Light
- 用于从黑暗环境中分离主体

---

## 8. 材质系统

### 古建筑 / 遗迹
- 风化石灰岩
- 青石
- 剥落朱砂漆
- 腐朽木材
- 青苔
- 干燥裂纹
- 石屑与尘土

### 金属
- 黑铁
- 暗金
- 青铜
- 铜绿
- 锈斑
- 重度战损划痕
- 撞击凹坑

### 泥塑 / 石窟造像
- 干燥泥胎
- 纤维骨料
- 彩漆剥落
- 斑驳灰尘
- 风化开裂

### 布料
- 撕裂
- 焦黑
- 风压拉扯
- 战损边缘

---

## 9. 角色造型通用原则

通用层只保留：
- 饱经风霜
- 战损
- 真实材质感
- 强剪影
- 低饱和暗色服装 / 铠甲
- 风压明显的布料或毛发
- 与环境同样具有尘土、磨损和物理重量

具体“猴类英雄”“红披风”“锁子甲”等属于 `source_ip_reference`，除非明确选用该系列。

---

## 10. 镜头语言

### 宏观
- 高空远景展示荒凉尺度
- 低机位仰拍巨型神像或 Boss
- 人物在宏大环境中占比很小

### 动作
- 动态跟拍
- 快速推进 / 拉退
- 运动模糊
- 碰撞时瞬时镜头震颤
- 关键打击慢动作 / 子弹时间
- 极近特写展示纹理与情绪

### 限制
动态环绕、极速推进和震颤只应用在高能节点，不能让全片都处于失控镜头状态。

---

## 11. Combat Grammar：动作切分

源文档明确不鼓励把复杂过招塞进单镜。

通用拆法：

1. **起**：蓄力、视线、武器、姿态。
2. **承**：力量释放、追踪或突进。
3. **转**：碰撞点、环境破坏或法术反应。
4. **合**：落地、反作用力、尘沙余波、气势回落。

```yaml
combat_grammar:
  decompose_complex_action: true
  beats:
    - 起势
    - 释放
    - 碰撞
    - 收势
  intersperse_ruin_closeups: true
  directional_match: required
```

---

## 12. 物理与粒子

### 重量感
- 武器动作有惯性
- 角色移动有重心
- 撞击导致环境反馈
- 地面、石柱、铠甲、碎石均应产生物理后果

### 风场
- 沙粒有流体方向
- 布料被风压拉扯
- 尘沙绕过主体
- 高能量场可产生涡流

### 异常物理
源文档允许：
- 局部反重力
- 时间膨胀
- 空间折射
- 能量涟漪

这些属于奇幻世界的视觉语言，但应服从具体剧本规则。

---

## 13. 转场与空镜

跨场景切换时，源文档强调：
- 新场景先用短空镜建立
- 空镜不含角色
- 聚焦新环境标志物
- 前后运镜方向尽量匹配
- 可用云雾、风沙、墨烟作为介质遮罩
- 高能动作后应有减速余温，再进入低能场景

这是高度可复用的电影化规则。

---

## 14. 声音设计

### 空间声学
不同空间需要不同混响：
- 巨型寺庙 / 石穴：长衰减、空旷、湿冷
- 峡谷 / 幽谷：多重反射与深远回声
- 远景：高频衰减、轻微传播延迟
- 特写：放大金属、布料、毛发等微观拟音

### 重击
- 高瞬态
- 低频重量
- 金属与石材材质清晰
- 冲击后有长尾余韵

### 法术
- 高频共鸣
- 耳鸣
- 空气撕裂
- 真空感
- 能量爆裂

### 环境
- 风沙
- 石屑
- 枯木
- 灰烬
- 砂砾撞击铠甲与布料

---

## 15. SFX 三段式

```yaml
sfx_envelope:
  attack: 起音 / 瞬态
  peak: 高潮 / 能量峰值
  decay: 余韵 / 空间回响
```

视觉打击点应与声音峰值对齐。具体 ±1 帧、EQ、dB 等数值属于后期生产适配层，不进入永久 Style Core。

---

## 16. Narration / Voice Profile

### 旁白
- 中老年男性倾向
- 深沉
- 低音
- 沧桑
- 缓慢
- 宿命感
- 历史厚重感

```yaml
narration:
  gender_tendency: 男
  age_impression: 中老年
  pitch: 低
  pace: 慢
  tone:
    - 深沉
    - 沧桑
    - 压抑
    - 宿命
    - 历史厚重
```

角色对白音色应由角色 Canon 或项目角色设定决定，不由通用 Style Core 固定。

---

## 17. BGM / Music Brief

### 核心
- 东方神秘
- 暗黑史诗
- 重量感
- 宿命
- 战斗压迫

### 配器
- 埙
- 二胡
- 锣鼓 / 重型打击
- 低频弦乐或交响层
- 可选无词合唱或低沉吟唱质感

```yaml
music:
  direction: 暗黑东方史诗
  instruments:
    - 埙
    - 二胡
    - 锣鼓
    - 重型打击
    - 低频弦乐
  optional:
    - 无词合唱
    - 低沉吟唱
  independent_track: true
  avoid_specific_artist_name: true
```

---

## 18. 字幕 / 书法视觉

源文档有很强的章节与 Boss 书法标题系统，包括：
- 熔岩灼烧
- 石窟雕刻
- 青铜锈斑

但这不是所有“暗黑东方神话”都必需。

因此：

```yaml
calligraphy_title_system:
  authority: optional
  load_when:
    - 章节定场
    - Boss 登场
    - 用户明确需要书法标题
```

不可与全局 `no text` 负面约束同时硬加载，应由生产 Router 按镜头类型切换。

---

## 19. source_ip_reference

以下内容来自源文档，但不属于通用 Style Core：

```yaml
source_ip_reference:
  load_policy: explicit_only

  characters:
    - 孙悟空
    - 妖魔 Boss

  props:
    - 如意金箍棒

  spells:
    - 完美闪避
    - 定身术
    - 金刚不坏
    - 聚气散形
    - 身外身法

  character_specific_visuals:
    - 火眼金睛
    - 战损锁子甲
    - 深红战损斗篷

  usage_rule:
    - 只有当项目明确为相关 IP / 悟空题材时加载
    - 通用暗黑东方奇幻项目不得自动注入
```

---

## 20. Prompt Assets

永久可复用结构：

```yaml
prompt_assets:
  image:
    - 场景尺度
    - 废墟材质
    - 冷暖色温
    - 丁达尔光
    - 环境粒子
    - 主体材质
    - 物理状态
    - 负面约束

  video_motion_stack:
    - Camera
    - Subject Action
    - Space / Environment
    - SFX

  combat:
    - 起势
    - 释放
    - 碰撞
    - 收势

  sound:
    - 起音
    - 峰值
    - 余韵
```

字段名保留英文仅为机器路由，实际生成正文应尽量中文化。

---

## 21. Production Adapter Reference

```yaml
production_adapter_reference:
  replaceable: true

  source_mentions:
    image_model:
      - GPT Image 2
      - Nano Banana Pro
      - Nano Banana 2
    video_model:
      - Seedance 2.5
      - Google Veo3.1 Fast
    music_model:
      - Suno 5
      - Mureka 8
    narration_model:
      - MiniMax Speech 2.8 HD
    super_resolution:
      - Jimeng SR
      - MediaKit
```

### 源文档内部冲突

1. 一处写“图像和视频模型强制唯一、严禁任何替代”，后文又定义了多种降级模型。
2. 一处允许全局目标 480p / 1080p，后文又锁定视频生成 480p，再依靠超分输出更高分辨率。
3. 全局负面常写 `no text`，但章节 / Boss 标题又要求生成书法大字。
4. 这些都是**生产路由冲突**，不得进入永久 Style Core。

---

## 22. 负面约束

### 通用
- 避免现代元素
- 避免高饱和霓虹
- 避免明快商业光
- 避免卡通 Q 版
- 避免光滑塑料材质
- 避免没有重量的打斗
- 避免环境粒子完全不与主体互动
- 避免复杂动作全部塞进一个镜头
- 避免连续镜头空间方向混乱
- 避免花哨数字转场

---

## 23. 冲突处理

```yaml
conflict_policy:
  no_silent_content_rewrite: true

  owners:
    topic: Topic Hunter
    script_semantics: Script Engine
    series_canon: Series Bible
    audiovisual: Audiovisual Director
    final_prompt_and_model: Video Production

  ip_rule:
    generic_style_core: always_available_when_selected
    source_ip_reference: explicit_only

  rules:
    - 通用风格不能自动生成悟空、金箍棒或具体法术
    - 若 Series Bible 已定义角色外观，以 Series Bible 为最高角色 Canon
    - 风格只负责把既有动作变成暗黑东方废墟视听表达
    - 法术规则若与项目世界观冲突，以项目世界观为准
```

---

## 24. 缺失项与可靠度

```yaml
missing_or_partial:
  generic_non_ip_character_archetypes: 部分
  non_combat_dialogue_style: 缺失
  peaceful_scene_rhythm: 部分
  general_life_scene_system: 缺失

reliability:
  visual_identity: very_high
  ruin_materials: very_high
  color_and_light: very_high
  combat_grammar: very_high
  physics_and_particles: very_high
  sound_design: very_high
  narration: high
  music: high
  generic_story_direction: medium
```

---

## 25. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/暗黑中式奇幻短片 (黑神话悟空风格).md"
style_profile:
  style_id: dark_eastern_mythic_ruins
  version: "1.0-zh"
  classification: mixed
  classification_detail:
    primary: narrative_style_bible
    secondary: [combat_style_bible, audiovisual_style_profile, production_playbook]
    full_series_canon: partial

  pre_content_modules:
    load:
      - dark_mythic_theme_preference
      - ruin_world_preference
      - fate_tone
    ip_specific:
      load: source_ip_reference
      condition: explicit_only
  audiovisual_modules:
    load:
      - visual_identity
      - color_system
      - light_system
      - ruin_materials
      - scale_grammar
      - combat_grammar
      - physics
      - particles
      - cinematography
      - transitions
      - sound_design
      - narration
      - music
  production_modules:
    load:
      - prompt_structure_reference
      - model_adapter_reference
      - postproduction_reference

  visual_identity:
    core:
      - 暗黑东方神话
      - 废墟美学
      - 低饱和
      - 高反差
      - 巨物尺度压迫
      - 重物理

  color:
    base:
      - 深灰
      - 暗褐
      - 黛绿
      - 暗红
      - 暗金
    lighting_rule: 暖高光 + 冷暗部强对冲

  light:
    chiaroscuro: true
    tyndall_shafts: true
    rim_light: 暖金
    atmospheric_particles_in_beam: true

  materials:
    - 风化石材
    - 剥落古建彩漆
    - 泥塑
    - 青铜锈斑
    - 黑铁战损
    - 撕裂布料

  combat:
    decompose_complex_action: true
    beats:
      - 起势
      - 释放
      - 碰撞
      - 收势
    ruin_closeups_between_impacts: true
    directional_match: true

  sound:
    spatial_acoustics: true
    heavy_transient_impacts: true
    magical_resonance: true
    envelope:
      - 起音
      - 峰值
      - 余韵

  narration:
    profile: 深沉、低沉、沧桑、缓慢、宿命感的中老年男声倾向

  music:
    style: 暗黑东方史诗
    instruments:
      - 埙
      - 二胡
      - 锣鼓
      - 重型打击
      - 低频弦乐
    independent_track: true

  source_ip_reference:
    load_policy: explicit_only
    contains:
      - 悟空角色
      - 金箍棒
      - 具体法术体系
      - 特定 Boss 设计

  production_adapter_reference:
    replaceable: true
    known_conflicts:
      - 模型唯一锁定与后备降级同时存在
      - 480p 生成与 1080p 目标混合
      - no text 与章节书法标题并存

  conflict_policy:
    no_silent_content_rewrite: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production

  provenance:
    source_documents:
      - file: "暗黑中式奇幻短片 (黑神话悟空风格).md"
        sha256: "12C3C0174DA2E8A0BF997D94F8800FE9CA08EA9169588A6F1174DE86DA2E4500"
        source_version: "本地文件 2026-08-18"
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer 与 write_the_prompt
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator 与 video_assembler
        extraction_type: direct
    extraction: source_grounded
    ip_specific_content_separated: true
    inferred_missing_fields: false
```
