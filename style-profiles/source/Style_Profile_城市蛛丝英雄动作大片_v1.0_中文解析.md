# Style Profile：城市蛛丝英雄动作大片

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/蜘蛛侠动作风格.md`  
> **源文件 SHA-256**：`35263DD6E72F82D689E251ABE3E225EF1921A92213C006CAB1A63DE2FCCDD666`  
> **源技能名**：`城市英雄大片`  
> **内部风格 ID**：`urban_web_swinging_action`  
> **库状态**：`pending_review`  
> **命名处理**：源文件名保留在 provenance；标准化结果只提炼城市摆荡、蛛丝物理、真人动作摄影和连续性规则，不默认使用受保护角色、战衣、标志或故事设定。

---

## 0. 解析结论

这是一份**真人城市超能力动作样式 + 固定 28 秒剧情模板 + 单镜生产手册**。真正可复用的 Style Core 是：

- 真人身份与原有服装优先，不自动替换为超级英雄战衣；
- 镜头贴身追踪人物，在高楼街谷、街道、墙面和屋顶之间连续运动；
- 蛛丝必须从明确的手部发出，并连续连接到具体上方或侧上方建筑锚点；
- 动作遵守可读的重力、惯性、摆荡弧线、蹬墙和落地关系；
- 低空高速、墙面奔跑、天际线悬停与安静生活片刻形成速度反差；
- 城市地标、街道结构和交通工具必须符合所选城市；车辆只存在于合理的道路空间；
- 以真人写实摄影、动态跟拍、倾斜与翻滚镜头制造大片感。

源文档中的 28 秒、10 个阶段、三明治、黑猫、回家打电话等属于**固定剧情模板**，不是通用风格规则。本次将它们路由到 `production_modules`，不作为所有项目的 Canon。

---

## 1. 文档分类

```yaml
classification:
  primary: production_playbook
  secondary:
    - audiovisual_style_profile
    - narrative_style_bible
  full_series_canon: false

  flags:
    has_topic_direction: false
    has_story_direction: true
    has_character_canon: false
    has_visual_system: true
    has_action_system: true
    has_sound_system: partial
    has_music_system: false
    has_fixed_timeline_template: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 真人身份代入的城市超能力动作短片
- 高楼街谷摆荡、跑酷、墙面运动和屋顶穿越
- 单镜头或少镜头的高速城市展示
- 需要从高速动作切到轻松生活片刻的内容

### 中等适配

- 城市旅行创意片、运动品牌概念片
- 其他具有绳索、抓钩或空中轨迹的英雄动作
- 不使用既有角色外观的原创都市英雄故事

### 弱适配

- 写实纪录片、无奇幻能力的人物传记
- 复杂多人打斗、室内对白戏
- 需要独立背景音乐驱动的 MV

---

## 3. 权威与内容边界

```yaml
authority:
  topic_direction: none
  fixed_story_template: low
  user_identity: hard
  original_clothing: hard
  live_action_visual: hard
  city_authenticity: high
  web_physics: hard
  body_integrity: hard
  cinematography: high
  sound_design: medium
  music_direction: none
  production_model: none
```

- 用户照片只作为身份和服装参考，不授权新增战衣、品牌标志或其他人物身份。
- 固定剧情模板不能覆盖用户已提供的剧情。
- 城市地标和代表交通工具属于需要当前项目核实的外部事实，不应由 Style Profile 永久写死。
- 超能力动作是虚构视觉设定，不应被描述为现实可安全模仿的行为。

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: medium
    preferred:
      - 城市冒险
      - 自我代入
      - 高速动作与生活反差
      - 地标穿越
    avoid:
      - 纯室内对白
      - 无空间运动的静态主题

  story_direction:
    authority: soft
    value: 日常起点 → 能力触发 → 城市高速穿越 → 高点停顿 → 日常回归

  restrictions:
    - 用户剧情优先于固定28秒模板
    - 不默认复制既有角色设定
    - 不改写用户服装与身份
```

---

## 5. 视觉身份

```yaml
visual_identity:
  medium: 真人写实动作电影
  lighting:
    - 温暖午后
    - 金色时刻
    - 夜间霓虹作为可选后段
  contrast: 中高
  texture:
    - 真实皮肤
    - 真实服装材质
    - 真实城市表面
  avoid:
    - 二维动漫
    - 三维卡通渲染
    - 插画
    - 赛璐璐
```

日间到日落再到夜景是源模板的时间推进方式；若当前剧情没有跨时段需求，不应强制使用。

---

## 6. 人物身份与服装锁

- 面部、肤色、发型、体型比例和性别称谓服从用户参考。
- 服装、裤装、鞋履和配饰完全沿用已确认参考，不自动英雄化。
- 三视图是源文档的生产策略，不是必须的视觉成片形式。
- 每个动作镜头都应保持四肢结构完整、关节方向可信、身体比例稳定。

```yaml
character_visual:
  identity_lock:
    - 面部比例
    - 肤色
    - 发型发色
    - 体型
  wardrobe_lock:
    - 上装
    - 下装
    - 鞋履
    - 配饰
  forbidden:
    - 自动替换战衣
    - 跨镜换脸
    - 肢体融合或断裂
```

---

## 7. 城市空间规则

- 所选城市的地标、建筑语汇、天际线、道路尺度和代表交通工具应彼此一致。
- 街道动作发生在真实可解释的道路、建筑立面和屋顶层级中。
- 车辆只出现在道路或合乎逻辑的停车位置，不能出现在屋顶、墙面、露台或天际线中。
- 屋顶空间使用水箱、空调外机、天线、露台和护栏等合理元素。
- 角色与墙面、车顶、钢梁、阳台、泳池边缘等必须建立明确接触或承载关系。

---

## 8. 蛛丝与运动物理

这是本 Profile 的最高权重模块。

```yaml
web_physics:
  origin: 明确的角色手部
  target: 上方或侧上方的具体建筑锚点
  continuity: 从手到锚点是一根完整、不间断的线
  curve: 与摆荡方向和重力一致的连续弧线
  forbidden:
    - 断裂蛛丝
    - 悬浮碎片
    - 从错误肢体发射
    - 无锚点的随机延伸

body_physics:
  required:
    - 重心可解释
    - 摆荡弧线连续
    - 蹬墙有接触点
    - 落地后速度转换可读
    - 前后动作保持惯性
```

源模板中的 3 米低空、40 度镜头倾斜、45 度墙面姿态、5–6 步等是动作设计参考，不是所有项目的永久数值。

---

## 9. 镜头语言

- 贴身无人机式追踪或高速稳定跟拍。
- 极近特写用于手部发射和蛛丝连接。
- 快速后拉揭示城市尺度。
- 镜头倾斜、翻滚和低空掠过用于传递速度与力量，但必须围绕主体运动动机。
- 高点使用广角静止或短暂停顿，形成速度后的呼吸。
- 可采用一镜到底，也可按完整动作节拍拆成少量长镜。

```yaml
cinematography:
  preferred:
    - 连续追踪
    - 低空跟拍
    - 极近特写后快速后拉
    - 倾斜镜头
    - 动机明确的翻滚
    - 天际线广角停顿
  avoid:
    - 无动机随机甩镜
    - 将多场景压成不可读的单一飞行动作
    - 频繁碎片化短镜
```

---

## 10. 表演与节奏

- 日常状态要轻松、自信、具有生活感。
- 高速动作强调流线姿态、抓握、蹬踏、着陆和再次发射的连续性。
- 高潮后安排安静观看城市、短暂进食或与小动物互动等生活化反差。
- 如果用户提供自己的故事，保留“速度—停顿—回归”的节奏原则即可，不保留模板事件。

---

## 11. 声音系统

```yaml
sound_design:
  in_scene:
    - 风噪
    - 城市交通
    - 蛛丝发射与绷紧
    - 墙面脚步
    - 车辆鸣笛
    - 落地与衣物运动
  dialogue: 可由当前镜头承载少量短台词
  music_direction: source_default_none
```

“无背景音乐”是源模板的声音方案，可作为默认值；若当前项目有独立音乐设计，不能由本 Profile 强制禁止。

---

## 12. 连续性锁

```yaml
continuity_schema:
  character:
    - 面容
    - 体型
    - 服装与鞋履
  city:
    - 地标位置关系
    - 道路与屋顶层级
    - 时间与光线推进
  action:
    - 当前速度
    - 身体朝向
    - 蛛丝发射手
    - 锚点位置
    - 蛛丝张力
    - 接触面
  environment:
    - 车辆只在道路
    - 屋顶元素合理
```

---

## 13. 生产模板与负面约束

### 固定 28 秒模板

以下只保留为 `production_modules.fixed_timeline_template`：卧室出发、手部发射、低空摆荡、墙面奔跑、街道穿越、天际线停顿、屋顶杂技、日落休息、夜巷互动、回家。它不能自动覆盖当前脚本。

### 负面约束

- 不要受保护角色战衣、胸标或未经用户指定的品牌标志。
- 不要动漫、卡通、插画或三维游戏渲染感。
- 不要身份漂移、服装替换、比例异常和肢体错误。
- 不要断裂、分段或无锚点的蛛丝。
- 不要车辆出现在屋顶、墙面或阳台。
- 不要把多个完整场景压缩成一个不可读动作。

---

## 14. Production Adapter Reference

```yaml
production_modules:
  fixed_timeline_template:
    duration_seconds: 28
    stage_count: 10
    status: optional_source_template
  model_adapter_reference:
    image:
      - Nano Banana Pro
      - Nano Banana 2
    video:
      - Seedance 2.5
  source_output_reference:
    aspect_ratio: 16:9
    resolution: 720p
    prompt_limit_characters: 2300
  replaceable: true
```

---

## 15. 冲突与缺失项

```yaml
conflicts:
  - id: HERO-STORY-01
    issue: 固定28秒剧情模板与用户自定义剧情可能冲突
    resolution: 用户剧情优先，固定模板仅作可选生产参考
  - id: HERO-IP-01
    issue: 源文件名指向具体受保护角色，但正文要求沿用用户原服装
    resolution: 标准化为原创城市蛛丝英雄动作，不注入战衣、标志或角色 Canon

missing_or_partial:
  full_visual_palette: 部分
  independent_music_system: 缺失
  multi_character_action_rules: 缺失
  weather_variants: 缺失
  city_fact_source: 运行时核实
```

---

## 16. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/蜘蛛侠动作风格.md

style_profile:
  style_id: urban_web_swinging_action
  version: 1.0-zh
  classification: production_playbook

  pre_content_modules:
    compatibility:
      authority: medium
      preferred:
        - 城市冒险
        - 真人身份代入
        - 高速动作与生活反差
    story_direction:
      authority: soft
      value: 日常起点 → 城市高速穿越 → 高点停顿 → 日常回归
    series_content_constraints:
      authority: hard
      value: 不默认使用既有受保护角色的战衣、标志或故事 Canon

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 真人写实城市动作电影，高速动态跟拍与天际线广角停顿
    character_visual:
      authority: hard
      value: 用户身份和原服装锁定，不自动英雄化
    environment:
      authority: high
      value: 城市地标、道路、屋顶与交通工具空间关系可信
    cinematography:
      authority: high
      value: 连续追踪、低空跟拍、手部极近特写、快速后拉、倾斜与动机明确的翻滚
    performance:
      authority: hard
      value: 重力、惯性、接触点、蛛丝锚点和身体结构必须可读
    editing_rhythm:
      authority: medium
      value: 高速动作与高点静止、生活片刻形成反差
    sound_design:
      authority: medium
      value: 城市环境、风噪、蛛丝张力、脚步与接触声
    music_direction:
      authority: low
      value: 源模板默认无独立背景音乐，可被当前项目覆盖
    continuity_schema:
      authority: hard
      track:
        - 人物身份与服装
        - 发射手与锚点
        - 蛛丝连续性
        - 身体惯性
        - 城市空间层级

  production_modules:
    fixed_timeline_template: source_defined_optional
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/蜘蛛侠动作风格.md
        version: attached-2026-08-24
        sha256: 35263DD6E72F82D689E251ABE3E225EF1921A92213C006CAB1A63DE2FCCDD666
    extracted_modules:
      - field: pre_content_modules
        source_section: planner + storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: multimodal_analyze_tool + storyboard_designer + write_the_prompt
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator + fixed_28s_template
        extraction_type: direct
```
