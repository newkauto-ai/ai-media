# Style Profile：传统手工艺电影纪录（源文档名《传统手工艺纪录风格短片》）

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/传统手工艺纪录风格短片.md`  
> **源文件 SHA-256**：`F8C513582E9F326EF61C8669982A83E7B56ED047CEBFED567633549F9674EBBB`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`traditional_craft_cinematic_documentary`  
> **解析原则**：工艺史实必须由外部文献或用户输入提供；Style Profile 只负责“怎么呈现”，不能自行生成历史事实。具体 2×3 分镜矩阵、3 组 × 30 秒、45 秒终剪等进入生产适配层。

---

## 0. 解析结论

这份源文档应归类为 **纪录片内容框架 + 传统工艺视听 Style Profile + Production Playbook**。最可复用的 Style Core 是：

- 传统手工艺主题
- 古籍木刻版画线描 × 超写实材质微距
- 国画矿物色系
- 高反差暗部与哑光粗糙表面
- 工艺物理过程的可视化
- 工匠手部、工具、原材料、火、水、蒸汽、纤维等微观细节
- “起源 → 工艺过程 → 成品与生活”三段纪录表达
- 画面和旁白紧密对应
- 沉稳、凝练、略带文学意象的纪录片旁白
- 古琴 / 埙 / 编钟为中心的低频古典器乐
- L-Cut / J-Cut 等连续纪录片声画连接

最需要防止的错误是：**Style Profile 不能把源文档示例中的朝代、传承年限、地域、工艺步骤当成真实事实。所有史实必须来自用户文献。**

---

## 1. 文档分类

```yaml
classification:
  primary: documentary_style_profile
  secondary:
    - narrative_structure_reference
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_worldview: false
    has_character_canon: false
    has_visual_system: true
    has_sound_system: true
    has_voice_system: true
    has_bgm_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
    requires_factual_source: true
```

---

## 2. 适配范围

### 强适配
- 非遗
- 传统工艺
- 古法制作
- 器物文化
- 材料工艺
- 传统食品制作
- 造纸、陶瓷、冶炼、木作、织造、雕刻等过程型内容
- 有明确文献依据的地域工艺故事

### 中等适配
- 历史器物
- 传统建筑工法
- 地方生活技艺
- 食物制作史

### 弱适配
- 无物理制作过程的抽象文化话题
- 纯现代工业
- 需要大量 UI、数据图表或人物采访对白的内容
- 缺乏可靠事实来源却要求讲“历史真相”的题材

---

## 3. 事实边界

这是本 Profile 的最高级内容约束。

```yaml
factual_boundary:
  style_may_generate_facts: false
  historical_origin_source_required: true
  process_source_required: true
  dates_and_lineage_source_required: true
  regional_distribution_source_required: true
```

### Router 规则
- Topic Hunter 可以提出“某传统工艺”的选题。
- Script Engine 必须基于已验证文献生成事实脚本。
- Style Profile 只能把事实转换为镜头、物理过程、色彩、声音与旁白表达。
- 不得因风格需要补造“千年传承”“始于某朝”等数据。

---

## 4. Router A：Pre-Content

```yaml
pre_content:
  preferred_story_shape:
    - 工艺溯源
    - 工艺流程
    - 成品进入生活
    - 人与器物的关系
    - 技艺与文明的关系

  requirements:
    - 有工艺文献或可靠背景资料
    - 能提取物理制作节点
    - 能找到可视化材料状态变化

  restrictions:
    - 不得先写历史结论再找证据
    - 不得把文学意象当历史事实
```

---

## 5. 三段叙事结构

源文档明确偏好：

### A：工艺溯源
作用：
- 地理
- 历史
- 人物
- 原材料
- 文明关系

### B：工艺流程
作用：
- 核心步骤
- 技术条件
- 工匠动作
- 材料形变
- 水火等物理高潮

### C：成品实景
作用：
- 成品质检
- 现实使用
- 材质神韵
- 人文空间
- 哲理收束

这套结构属于 `story_direction: medium_high`，但如果实际内容不适合三段式，不能强行改写事实。

---

## 6. 视觉身份

### 核心混合
- 古籍木刻版画线描质感
- 现代电影纪录片
- 超写实微距
- 微粒胶片颗粒
- 高反差暗部
- 哑光粗糙材质

### 视觉目的
不是把整条片做成“古画”，而是让：
- 历史溯源段具有古籍与版画感
- 工艺段拥有极强材质触感
- 成品段拥有电影纪录片质感

---

## 7. 色彩系统

源文档指定国画矿物色：

- 赭石
- 松石绿
- 朱砂
- 黛蓝

`≥90%` 属于生产量化目标，不应作为永久机器硬阈值；Style Core 改为：

```yaml
color:
  palette:
    - 赭石
    - 松石绿
    - 朱砂
    - 黛蓝
  dominance: high
  finish: 哑光
  avoid:
    - 霓虹
    - 赛博朋克
    - 明亮数字光效
    - 现代工业广告感
```

---

## 8. 材质与微距

这是本风格最重要的镜头资产之一。

### 关注对象
- 手
- 皮肤与劳动痕迹
- 古法工具
- 原材料
- 水珠
- 火焰
- 铁水
- 蒸汽
- 纸浆纤维
- 木纹
- 金属表面
- 陶瓷裂纹
- 丝线
- 包浆

### 表现逻辑
- 高反差打亮
- 浅景深
- 极近特写
- 真实表面粗糙度
- 材料形变必须可见

---

## 9. 物理过程可视化

源文档明确要求把抽象古典表述转换为**可执行的物理语言**。

例如逻辑类型：
- 高温 → 火焰颜色、材料发亮、气泡、火星
- 淬火 → 蒸汽、水花、颜色从热态转冷态
- 抄纸 → 纤维随水流运动、表面张力、滴水
- 锻打 → 形变、冲击、火星、工具反作用力

Style Core 规则：

```yaml
process_visualization:
  abstract_phrase_to_physics: required
  material_state_change: required
  force_and_reaction: required
  fluid_behavior: required_when_relevant
  heat_behavior: required_when_relevant
```

---

## 10. 工匠角色

这不是角色 Canon，而是纪录片主体类型。

### 重点
- 体态
- 手部动作
- 专注神态
- 工作姿态
- 与工具和原材料的真实交互

### 避免
- 过度英雄化
- 过度摆拍
- 现代商业模特感
- 无视工艺流程的空洞人物肖像

---

## 11. 镜头语言

### 工艺溯源段
- 宽景
- 稳定横摇
- 缓慢推进
- 大景深
- 地域环境建立
- 古籍 / 版画插入

### 工艺过程段
- 极近特写
- 中景手持纪实
- 时间流逝
- 呼吸式轻微变焦
- 高反差动作特写
- 慢速推轨

### 成品段
- 手持质检
- 生活化中景
- 柔和天光宽景
- 极度材质特写
- 平稳退轨
- 留白收尾

---

## 12. Eye Tracing / 视线连续性

源文档强调相邻镜头视觉重心连续。

永久规则保留为：

```yaml
eye_tracing:
  required: true
  principle:
    - 前镜尾帧视觉焦点与后镜首帧尽量接近
    - 动作方向尽量继承
    - 高频工艺切镜中避免视觉焦点突然跨越画面
```

具体 `$X,Y` 坐标与 20% 阈值属于生产 QC 参考，不进入 Style Core。

---

## 13. 旁白风格

### 语气
- 磁性
- 低沉
- 有力
- 沉稳
- 克制
- 气息饱满
- 情绪内敛
- 具有感染力

### 文案
- 句式凝练
- 节奏沉稳
- 可有文学意象
- 但事实陈述必须清楚
- 结尾可由具体工艺上升到“人与器物 / 时间 / 文明”关系

### 中性化处理
源文档用具体电视机构作为旁白风格参照。本 Profile 不保留品牌名称，改写为**高质量中文人文纪录片解说腔**。

---

## 14. 声音设计

### 工艺现场拟音
- 锤击
- 水声
- 蒸汽
- 风箱
- 金属碰撞
- 木材摩擦
- 纤维与水
- 工具刮擦

### 声画
工艺物理动作与 SFX 应点对点对应。

### 转场
源文档强调：
- J-Cut
- L-Cut
- 前一场景声音提前进入下一画面
- 某个声音延续至下一镜再淡出

这是可复用的纪录片剪辑规则。

---

## 15. BGM / Music Brief

```yaml
music:
  style: 中国古典器乐
  instruments:
    - 古琴
    - 埙
    - 编钟
  tempo: 舒缓
  register: 偏低
  role:
    - 历史厚重感
    - 工艺节奏铺底
    - 不抢旁白
  independent_track: true
```

源文档给出 BGM 低于 VO `8–12 dB`，该数值属于后期适配层。

---

## 16. Narration 与 BGM 混音

Style Core：
- VO 始终是主信息层
- BGM 不能盖过旁白
- 工艺高潮节点前可短暂停顿
- 重要物理 SFX 可暂时成为听觉焦点

具体 dB、Fade 秒数进入 Production Adapter。

---

## 17. 负面约束

- 不要现代工业场景污染古法工艺
- 不要数字霓虹
- 不要赛博朋克
- 不要光滑现代商业渲染
- 不要过度滤镜
- 不要把古法材料做成塑料
- 不要忽略工艺步骤的物理因果
- 不要让旁白和画面各说各话
- 不要凭空生成史实
- 不要用不可靠文字标注制造“历史感”

---

## 18. Prompt Assets

永久结构：

```yaml
prompt_assets:
  documentary_scene:
    - 史实锚点
    - 地域
    - 人物
    - 工艺状态
    - 材料
    - 光线
    - 矿物色
    - 运镜

  craft_macro:
    - 材料初态
    - 施力动作
    - 物理形变
    - 温度 / 水分 / 蒸汽
    - 微观纹理
    - SFX

  finished_product:
    - 成品质检
    - 实际使用
    - 材质特写
    - 人文空间
    - 留白收尾
```

---

## 19. Production Adapter Reference

```yaml
production_adapter_reference:
  replaceable: true

  source_mentions:
    spec_file: Craft_Spec.md
    aspect_ratio: "16:9"
    final_duration: "45s"
    storyboard_matrix: "2x3"
    groups:
      - A
      - B
      - C
    image_model:
      - GPT Image 2
    video_model:
      - Seedance 2.5
    music_model:
      - Mureka 8
    narration_model:
      - MiniMax Speech 2.8 HD
      - ElevenLabs v3
    super_resolution:
      - MediaKit
```

---

## 20. 源文档内部规格冲突

这部分必须显式隔离，防止 Router 把错误数字升级成规则。

### 冲突 1：18 格 / 36 节点
源文档同时出现：
- `3 组 × 6 格`
- “共 36 个分镜节点”
- 后文又称 “18 个节点”
- Storyboard 部分又写 “36 个镜头”“每组 12 镜头”

这些数字无法同时成立。

### 冲突 2：时间区间
源文档写：
- 全片 45 秒
- 3 组各生成 30 秒视频
- A：0–30s
- B：15–30s
- C：30–45s

B 的标注实际只有 15 秒，同时 3 条 30 秒原始视频总长为 90 秒，只有通过后期裁剪才能得到 45 秒。

### 冲突 3：6 格参考图 → 12 个分镜
源文档规定一张 2×3 参考图只有 6 格，但又要求每组生成 12 个分镜节点。如何从 6 格映射到 12 节点没有明确规范。

### 处理结论
上述全部进入 `known_source_conflicts`，**不进入 Style Core**。真实生产时应根据目标时长重新计算镜头结构。

---

## 21. 冲突处理

```yaml
conflict_policy:
  no_silent_fact_generation: true
  no_silent_content_rewrite: true

  owners:
    topic: Topic Hunter
    facts_and_script_semantics: Script Engine
    audiovisual: Audiovisual Director
    production_timing_and_models: Video Production

  rules:
    - 历史事实优先级高于风格
    - 用户文献优先于 Style Profile 示例
    - Style 可建议三段纪录结构，但不能编造缺失工艺步骤
    - 旁白文学化不得扭曲事实
    - 生产时长与矩阵数量由 Production Adapter 重新计算
```

---

## 22. 缺失项与可靠度

```yaml
missing_or_partial:
  fixed_character_canon: 缺失
  dialogue_system: 不适用 / 缺失
  recurring_scene_continuity: 部分
  interview_style: 缺失
  factual_verification_method: 只要求来源，未定义验证流程

reliability:
  documentary_structure: high
  visual_identity: high
  mineral_color_system: high
  craft_macro_language: very_high
  physics_visualization: very_high
  narration: high
  music: high
  production_timing_spec: low
  storyboard_node_count: low
```

---

## 23. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/传统手工艺纪录风格短片.md"
style_profile:
  style_id: traditional_craft_cinematic_documentary
  version: "1.0-zh"
  classification: mixed
  classification_detail:
    primary: audiovisual_style_profile
    secondary: [narrative_structure_reference, production_playbook]
    full_series_canon: false
    requires_factual_source: true

  pre_content_modules:
    load:
      - craft_documentary_story_shape
      - source_requirement
  audiovisual_modules:
    load:
      - visual_identity
      - mineral_palette
      - material_macro
      - physics_visualization
      - cinematography
      - eye_tracing
      - narration
      - sound
      - music
  production_modules:
    load:
      - storyboard_matrix_reference
      - model_adapter_reference
      - timing_reference
      - qc_reference

  factual_boundary:
    style_may_generate_facts: false
    source_required_for:
      - 起源
      - 朝代
      - 传承年限
      - 地域分布
      - 工艺步骤

  narrative:
    preferred_structure:
      - 工艺溯源
      - 工艺流程
      - 成品实景与文明意义
    authority: medium_high

  visual:
    identity:
      - 古籍木刻版画线描
      - 超写实材质微距
      - 电影纪录片
      - 微粒胶片颗粒
      - 高反差暗部
    palette:
      - 赭石
      - 松石绿
      - 朱砂
      - 黛蓝
    palette_dominance: high

  craft_physics:
    abstract_to_physical_visualization: true
    material_state_change: true
    force_reaction: true
    heat_and_fluid_behavior: true

  cinematography:
    origin:
      - 宽景
      - 稳定横摇
      - 缓慢推进
    process:
      - 极近特写
      - 手持纪实
      - 时间流逝
      - 高反差动作特写
    final_product:
      - 生活化中景
      - 柔和宽景
      - 材质极近特写
      - 平稳退轨
    eye_tracing: required

  narration:
    profile: 低沉、磁性、沉稳、克制的中文人文纪录片解说
    writing:
      - 凝练
      - 沉稳
      - 有意象
      - 事实清晰

  music:
    instruments:
      - 古琴
      - 埙
      - 编钟
    tempo: 舒缓
    independent_track: true

  production_adapter_reference:
    replaceable: true
    known_source_conflicts:
      - 18 格与 36 节点冲突
      - 3×30 秒原始视频与 45 秒成片关系未完整定义
      - B 段时间区间只标 15 秒
      - 6 格参考图与每组 12 节点映射不明确

  conflict_policy:
    no_silent_fact_generation: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production

  provenance:
    source_documents:
      - file: "传统手工艺纪录风格短片.md"
        sha256: "F8C513582E9F326EF61C8669982A83E7B56ED047CEBFED567633549F9674EBBB"
        source_version: "本地文件 2026-08-18"
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: multimodal_analyze_tool、storyboard_designer 与 write_the_prompt
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator 与 video_assembler
        extraction_type: direct
    extraction: source_grounded
    factual_examples_are_canon: false
    inferred_missing_fields: false
```
