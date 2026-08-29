# Style Profile：手绘自然成长奇幻（源文档名《宫崎骏动画大师》）（中文重解析版）

> **版本**：v1.1-zh  
> **源文档**：`宫崎骏动画大师.md`  
> **对齐规范**：`Skill 3 — Unified Style Profile Schema v1.0`  
> **内部风格 ID**：`hand_drawn_nature_growth_fantasy`  
> **说明**：内部 Profile 使用中性风格 ID，避免把创作者姓名当作生产提示词依赖。源文档本身也要求不复刻已有角色、影片镜头、名称、标志性角色外观与具体场景。

---

## 0. 解析结论

这份文档应归为 **Narrative Style Bible + Audiovisual Style Profile + Production Playbook**。它不只是“画风”，还包含成长命题、人与自然/机械关系、复杂冲突哲学、角色原型、对白表达、镜头语言、表演、声音、BGM、连续性和大量模型执行说明。

本次重解析做了四个关键修正：

1. **叙事约束可提前路由，但不能取得 Content Thesis 所有权**。成长、自然、人文、非黑白冲突等可以在 Topic Hunter / Script Engine 前作为兼容性和表达约束，但不得改写已确定的核心选题与结论。
2. **角色“声音系统”被降为行为与声场约束**。源文档有“清澈但胆怯的少女声”等模板示例，也要求提取音色资产，但没有定义一套固定角色 Canon 音色，因此不能把示例音色当永久风格事实。
3. **把 30 秒、3–5 切镜、模型名、参考图占位符、分辨率等全部降到 Production Adapter**，永久 Style Core 只保留“分层空间、自然生命运动、细腻表演、波形节奏、物理声效”等可跨模型规则。
4. **识别源文档内部规格矛盾**：模型名称/分辨率处存在重复“480p / 480p”表述；所谓“30 秒多镜头模板”的示例时间轴实际只写到约 15 秒。这些不能作为稳定 Profile 规则。

---

## 1. 文档分类

```yaml
classification:
  primary: narrative_style_bible
  secondary:
    - audiovisual_style_profile
    - production_playbook
  full_series_canon: false

  flags:
    has_topic_direction: true
    has_story_direction: true
    has_worldview: true
    has_character_canon: partial
    has_visual_system: true
    has_sound_system: true
    has_voice_system: partial
    has_bgm_system: true
    has_prompt_templates: true
    has_model_specific_rules: true
    has_production_workflow: true
```

它不是完整 Series Bible，因为没有固定的长期角色名单、长期剧情历史或唯一世界 Canon；但其“成长、自然、反战、环保、复杂冲突、普通人成长”等内容规则足以在 Pre-Content 阶段发挥作用。

---

## 2. 风格兼容性

### 强适配
- 少年 / 少女成长
- 普通人进入陌生世界
- 自然奇幻
- 森林、海洋、天空、小镇
- 飞行冒险
- 蒸汽机械与手作机械
- 人与自然的误解、冲突、修复、共生
- 温暖中带轻微忧伤、最终向光的故事
- 需要生活细节、世界规则和复杂立场的奇幻题材

### 弱适配
- 纯知识罗列
- 高密度信息口播
- 只靠“爽点”推进、没有成长的英雄叙事
- 单纯炫技式战斗
- 长篇说教
- 需要完全冷硬、机械、去情感表达的内容

### Style Compatibility Gate
如果一个题材的核心 Thesis 与“成长 / 自然 / 人文 / 多方立场”并不矛盾，可通过视听层适配；如果必须改变核心结论才能套入风格，输出 `STYLE-CONTENT MISMATCH`，不能强行重写。

---

## 3. 权威级

```yaml
authority:
  topic_direction: medium
  story_direction: medium_high
  worldview: hard
  character_archetype: medium_high
  fixed_character_canon: none
  dialogue_style: hard
  dialogue_semantics: none
  visual_identity: hard
  cinematography: hard
  performance: hard
  environment_motion: hard
  mechanical_motion: hard
  sound_design: hard
  voice_timbre: low
  voice_behavior: hard
  bgm_direction: hard
  continuity: hard
  prompt_template_reference: medium
  production_model: none
```

说明：

- `story_direction` 在剧本冻结前可作为强兼容性约束；冻结后不能重写语义。
- `worldview: hard` 指该风格一旦用于奇幻世界，就要求规则自洽、幻想服务主题；仍低于用户当轮明确要求与 Series Canon。
- `voice_timbre: low`：源文档有模板和提取流程，但没有固定可复用音色 Canon。
- `dialogue_style: hard` 只约束“怎么说”，不拥有“说什么”的语义权。

---

## 4. Router A：Pre-Content

以下模块可在 Topic Hunter / Script Engine 前加载：

```yaml
pre_content:
  themes:
    - 成长
    - 自然敬畏
    - 环境与共生
    - 反战或技术失控的人文反思
    - 劳动
    - 责任
    - 共情
    - 自我认同

  protagonist_principles:
    - 主角优先是普通人、少年少女、学徒、劳动者、旅人
    - 主角不能一开始就是完美英雄
    - 成长通过行动体现，而不是旁白宣布

  conflict_principles:
    - 避免简单善恶二元
    - 对立方应有自身逻辑
    - 人类、自然、机械、神灵、动物均可有独立立场

  theme_expression:
    - 用行动、环境、道具、后果表达
    - 避免口号化说教
    - 避免长篇解释世界观

  dialogue_style:
    - 简洁
    - 真诚
    - 儿童或少年自然口语
    - 成人更克制
```

### Router A 不得做的事
- 不把任何已有电影角色或故事当作默认题材
- 不强制每个故事都出现飞行器、森林、精灵
- 不修改 Topic Hunter 已确定的 Thesis
- 不改事实、证据、Reveal、Meaning

---

## 5. 世界观

源文档要求幻想不能成为无规则奇观堆砌。若故事出现魔法、精灵、神灵或机械，需要说明：
- 能力或力量从哪里来
- 为什么会出现
- 如何运行
- 角色为什么能与其互动
- 世界的自然法则、机械法则或神灵规则如何保持前后一致

场景与道具强调**功能性**：
- 木屋要有生活结构
- 城镇要有街道、居民与功能空间
- 森林要有树种、苔藓、腐木、溪流、昆虫等生命层次
- 飞行器 / 锅炉 / 机械要有驾驶、传动、动力或蒸汽结构
- 道具应具叙事作用，而非纯装饰

---

## 6. 角色与表演

### 6.1 角色原型
源文档偏好：
- 少年、少女
- 普通劳动者
- 学徒
- 飞行员
- 森林守护者
- 面包店帮工
- 机械师
- 乡村孩子
- 旅人

这些是**推荐原型**，不是固定角色 Canon。

### 6.2 成长
角色应有缺点：胆小、急躁、依赖、迷路、逃避、固执、过度自信或不懂自然。成长通过：
- 劳动
- 照顾他人
- 修理
- 穿越
- 保护
- 承认错误
- 做出选择

### 6.3 微表演
少年少女：
- 快速眨眼
- 眉毛轻扬
- 犹豫抿嘴
- 轻微脸颊变化
- 呼吸从急促到平复
- 重心不稳、急停踉跄

成人：
- 更克制
- 眼神稳定
- 下颌轻微放松或紧绷
- 短暂停顿后说话

动物 / 精灵：
- 耳朵
- 尾巴
- 触须
- 翅膀
- 身体膨胀收缩
- 眼睛大小变化
- 发光变化

### 6.4 多角色反应
说话者之外的角色不能呆站。需要眨眼、转头、低头、抓衣角、挪脚、退缩、靠近等微反应，并保持视线与身体朝向关系。

---

## 7. 视觉身份

### 核心
- 高质量二维手绘动画
- 柔和轮廓线
- 水彩背景
- 分层赛璐珞质感
- 自然笔触
- 轻微纸张纹理
- 逐帧动画生命感
- 拒绝三维塑料感、真人照片感、廉价贴图感

### 空间
明确三层：
1. 前景：草叶、树枝、窗框、云雾、水滴、锅炉管道等，可略失焦或快速横向运动
2. 主体：角色处于清晰行动层
3. 背景：水彩远景、山脉、森林、建筑、天空，稳定但有缓慢运动

深度主要通过**线条清晰度、色彩饱和度、层次移动差**建立，不依赖真人摄影式极端虚化。

---

## 8. 色彩与光影

### 色彩倾向
- 森林生命色
- 天空飞行色
- 海浪童话色
- 蒸汽机械色
- 夜间暖灯色

### 可用色彩角色
- 自然：森林绿、天空蓝、云白、土壤赭石
- 奇幻：暖金、青蓝、柔白、微光绿
- 危险 / 污染：铁锈红、烟灰黑、暗紫、病态绿

### 光影
- 面部柔和自然光
- 森林斑驳树影
- 窗光、炉火、油灯暖光
- 云层具有体积
- 远景低饱和、偏蓝
- 水面倒影更暗、更柔，随波纹变化
- 黄铜、铁皮、油污、蒸汽应有材质差异

---

## 9. 世界运动：风、水、植物、机械

### 风
必须在画面中可见：
- 草叶
- 树冠
- 头发
- 衣角
- 窗帘
- 旗帜
- 云
- 烟雾

飞行中：
- 发丝与衣物向后
- 眼睛略眯
- 身体考虑风阻

### 水
- 河流、雨滴、水洼、海浪均需动态
- 倒影随波纹变形
- 雨滴落水存在冲击 → 扩散 → 消失

### 植物
- 森林不是静态背景
- 草、苔藓、藤蔓、花瓣、孢子微粒有细微运动
- 远山大气透视
- 近景植物方向不完全一致

### 机械
- 齿轮
- 螺旋桨
- 连杆
- 蒸汽阀门
- 活塞

机械运动必须有重量、节奏、惯性和噪声，禁止无逻辑平移。

---

## 10. 镜头语言

### 重点镜头
- 自然开阔构图
- 儿童低机位视角
- 横向跟拍奔跑
- 飞行 / 高处视角（仅在剧情需要时）
- 手指、鞋底、发丝、阀门等动作特写
- 短暂静观自然镜头

### 构图
- 前景 / 主体 / 背景分层
- 生活空间通过锅炉、桌面、窗台、晾衣绳、工具等细节建立可信度
- 夸张广角与强对称属于稀缺强调手段，不应滥用

### 节奏
源文档明确的节奏波形：
**紧张 → 舒缓 → 惊奇 → 行动 → 情感回落**

该“波形”属于 Style Core；“固定 30 秒、每段 3–5 个子镜头”属于 Production Adapter，不进入永久风格规则。

---

## 11. 声音设计

### 声场
- 森林：柔和扩散
- 木屋：轻微反射
- 飞行：对白受到风噪影响
- 海边：对白与浪声共存

### 拟音
可用：
- 草叶摩擦
- 木门吱呀
- 锅炉咕噜
- 蒸汽喷出
- 衣料抖动
- 脚踩泥土
- 雨滴落叶
- 翅膀拍动
- 螺旋桨旋转

拟音应说明声源、材质、距离、空间和动作同步点，不用“震撼音效”这类空泛词。

### 对白
- 简洁
- 真诚
- 儿童不成人腔
- 不长篇解释
- 成人表演更克制
- 主题尽量通过行动而不是哲学台词输出

---

## 12. Voice Profile

### 源文档支持
- 可以定义角色声音特征
- 可以从角色设定视频提取并绑定音色资产
- 儿童声音应自然
- 成人声音更克制
- 声音要考虑所在空间与环境噪声

### 源文档没有固定定义
- 固定音高
- 固定音色
- 固定共鸣位置
- 固定语速
- 固定口音
- 固定角色 Voice Canon

因此：

```yaml
voice:
  source_defined_timbre: false
  style_behavior:
    child: 自然、清澈、非成人腔
    adult: 克制、沉稳
  runtime_voice_profile_required: true
```

源文档里的“清澈但有点胆怯的少女声”等属于模板示例，不升级为 Canon。

---

## 13. BGM / Music Brief

### 核心情绪
- 温暖
- 清澈
- 冒险
- 童年
- 自然
- 希望
- 略带忧伤但最终向光

### 乐器池
- 钢琴
- 弦乐群
- 小提琴
- 大提琴
- 长笛
- 双簧管
- 单簧管
- 圆号
- 竖琴
- 钟琴
- 手风琴
- 木琴
- 轻打击乐
- 轻柔合唱质感 / 音乐盒质感（按剧情使用）

### 情景映射
- 森林治愈：钢琴 + 长笛 + 弦乐
- 飞行冒险：圆号 + 弦乐 + 木管上行
- 海浪童话：竖琴 + 钢片琴 + 轻柔木管
- 蒸汽机械：低音弦乐 + 手风琴 + 轻打击
- 战争阴影：低沉铜管 + 大提琴 + 稀疏鼓点

### 硬规则
- BGM 独立生成
- 不写入视频 Prompt
- 不用知名音乐人姓名作为生成依赖
- 不遮盖对白
- 不过度煽情

---

## 14. 连续性

Style Profile 强制需要“状态账本”概念。

至少记录：

```yaml
continuity_state:
  character:
    position:
    pose:
    expression:
    costume:
    hair:
    injury:
    wetness:

  prop:
    owner:
    position:
    state:

  environment:
    weather:
    wind_direction:
    light_direction:
    time_of_day:
    water_state:
    mechanical_state:

  emotion:
    state:
```

### 职责
- Skill 3：设计 `expected_end_state` 与下一 Beat 的继承要求
- Skill 4：记录实际生成后的 `actual_end_state` 与偏差

---

## 15. Prompt Assets：保留结构，不锁死语法

### 图像资产
建议永久保留的资产类别：
- 角色
- 动物 / 精灵
- 场景
- 机械 / 飞行器
- 道具

### 角色参考图
源文档偏好多视角设定，用于锁定：
- 面部
- 体型
- 发型
- 服饰
- 标志道具

### 场景
应明确：
- 光源方向
- 天气
- 前景
- 中景行动区
- 远景

### 机械
必须具备结构可实现性，而不是只有外壳。

### 视频 Prompt 的永久结构
可保留“运动描述栈”概念：

```text
镜头
→ 主体动作与面部
→ 空间 / 风 / 水 / 机械阻力
→ 物理拟音 / 对白
```

具体时间戳、占位符和模型语法由 Skill 4 适配。

---

## 16. Production Adapter Reference

以下内容来自源文档，但属于可替换适配层：

```yaml
production_adapter_reference:
  image_model_mentions:
    - Nano Banana Pro
    - GPT Image 2
    - Seedream 4.5
  video_model_mentions:
    - Seedance 2.5
  audio_generation:
    - text_to_instrumental
  source_workflow_mentions:
    - 角色/场景/机械逻辑资产绑定
    - 角色设定短视频
    - 提取角色音色
    - 多模态转视频
    - 分段生成
    - 独立 BGM
    - 最终合成

  known_source_conflicts:
    - 模型与分辨率描述存在重复 480p 表述
    - 所谓 30 秒视频 Prompt 示例时间轴只示范到约 15 秒
```

这些不应成为长期 Style Profile 的硬事实。

---

## 17. 负面约束

### 视觉
- 禁止真人照片感
- 禁止廉价三维塑料感
- 禁止静态背景贴图感
- 禁止角色像木偶一样僵硬
- 禁止自然元素完全不动
- 禁止机械无逻辑运动

### 动作
- 禁止反关节
- 禁止瞬移
- 禁止无重力漂浮
- 禁止没有惯性和阻力的动作

### IP / 模仿
- 不复刻已有动画角色
- 不复刻具体电影镜头
- 不使用已有 IP 标志
- 不依赖知名创作者姓名作为最终生产 Prompt 风格关键词

---

## 18. 冲突处理

### Topic / Thesis
```text
用户当轮明确指令
> 明确 Series Bible
> Topic Hunter
> Style Profile 的内容兼容性约束
```

### Script Semantics
```text
用户当轮明确指令
> Frozen Script
> Script Engine
> Narrative Style Constraint
```

### Visual / Performance / Sound / BGM
```text
用户当轮覆盖
> Series Canon
> Selected Style Profile
> Audiovisual Director Default
```

### Model Prompt Syntax
```text
Skill 4 当前模型适配器
> 已存模板
> Style Profile 参考
```

### 冲突原则
- 不静默重写内容
- Canon 高于普通风格偏好
- 当轮用户同领域覆盖优先
- 生产降本不能先删 Thesis / Reveal / 核心意义
- 严重不兼容时允许拒绝强套风格

---

## 19. 缺失项与可靠度

| 模块 | 状态 | 说明 |
|---|---|---|
| 叙事主题 | 高可靠 | 源文档明确 |
| 世界观哲学 | 高可靠 | 自然/机械/人类与多方立场明确 |
| 视觉风格 | 高可靠 | 手绘、水彩、赛璐珞、分层明确 |
| 表演 | 高可靠 | 微表情、重心、互动明确 |
| 自然运动 | 高可靠 | 风、水、植物详细 |
| 机械运动 | 高可靠 | 齿轮、连杆、蒸汽、惯性明确 |
| 镜头语言 | 高可靠 | 低机位、跟拍、飞行、静观自然等明确 |
| 声音 | 高可靠 | 声场与拟音明确 |
| BGM | 高可靠 | 情绪和乐器池明确 |
| 固定角色 Voice | 缺失 | 只有模板和生成/提取机制 |
| 长期角色 Canon | 缺失 | 角色原型不是固定角色 |
| 30 秒模板参数 | 有冲突 | 示例时间轴不满 30 秒 |
| 分辨率 | 有冲突 | 480p 重复表述，不能作为稳定事实 |

---

# 20. 机器可读 Normalized Style Profile

```yaml
style_profile:
  meta:
    style_id: hand_drawn_nature_growth_fantasy
    display_name: 手绘自然成长奇幻
    legacy_name: 宫崎骏动画大师
    version: v1.1-zh
    source_files:
      - 宫崎骏动画大师.md
    language: zh-CN

  classification:
    primary: narrative_style_bible
    secondary:
      - audiovisual_style_profile
      - production_playbook
    full_series_canon: false

  compatibility:
    best_for:
      - 少年少女成长
      - 普通人成长
      - 自然奇幻
      - 飞行冒险
      - 森林与小镇
      - 蒸汽机械
      - 人与自然冲突
      - 温暖略带忧伤的成长叙事
    weak_for:
      - 纯知识罗列
      - 高密度信息口播
      - 无成长爽文
      - 单纯炫技战斗
      - 长篇说教

  scope:
    topic_direction: true
    story_direction: true
    worldview: true
    character_archetype: true
    fixed_character_canon: false
    visual_style: true
    cinematography: true
    performance: true
    environment_motion: true
    mechanical_motion: true
    sound_design: true
    voice_direction: partial
    bgm_direction: true
    continuity: true
    prompt_templates: true
    model_specific_rules: true
    production_workflow: true

  authority:
    topic_direction: medium
    story_direction: medium_high
    worldview: hard
    character_archetype: medium_high
    dialogue_style: hard
    dialogue_semantics: none
    visual: hard
    cinematography: hard
    performance: hard
    sound: hard
    voice_timbre: low
    voice_behavior: hard
    bgm: hard
    continuity: hard
    production_model: none

  routing:
    pre_content:
      load:
        - narrative_themes
        - protagonist_principles
        - conflict_principles
        - worldview_principles
        - dialogue_style
        - theme_expression_rules
    audiovisual:
      load:
        - visual_identity
        - spatial_grammar
        - color_and_light
        - natural_motion
        - mechanical_motion
        - character_performance
        - cinematography
        - sound_design
        - voice_behavior
        - music_direction
        - continuity
    production:
      load:
        - asset_template_reference
        - motion_stack_reference
        - negative_constraints
        - model_adapter_reference

  narrative:
    themes:
      - 成长
      - 自然敬畏
      - 环境与共生
      - 责任
      - 劳动
      - 共情
      - 自我认同
      - 反战或技术失控的人文反思
    protagonist:
      imperfect_at_start: true
      growth_through_action: true
    conflict:
      binary_good_evil: avoid
      multi_party_motivation: required
    exposition:
      prefer_show_over_tell: true

  worldview:
    fantasy_rules_must_be_consistent: true
    wonder_must_serve_theme: true
    nature_human_relationship_required_when_relevant: true

  character:
    preferred_archetypes:
      - 少年
      - 少女
      - 普通劳动者
      - 学徒
      - 飞行员
      - 机械师
      - 乡村孩子
      - 旅人
    performance:
      micro_expression: required
      physical_weight: required
      interaction_reaction: required

  audiovisual:
    visual_identity:
      format: 高质量二维手绘动画
      outline: 柔和
      background: 水彩
      layering: 赛璐珞分层
      texture: 自然笔触与轻微纸张纹理
      avoid:
        - 三维塑料感
        - 真人照片感
        - 廉价贴图感
    spatial_grammar:
      layers:
        - 前景
        - 主体
        - 背景
      depth_by_motion_parallax: true
    natural_motion:
      wind: visible
      water: animated
      vegetation: animated
      clouds: animated
    mechanical_motion:
      weight: required
      inertia: required
      transmission_logic: required
    cinematography:
      preferred:
        - 自然开阔构图
        - 儿童低机位
        - 横向跟拍
        - 动作细节特写
        - 静观自然
        - 剧情需要时的飞行镜头
      rhythm_wave:
        - 紧张
        - 舒缓
        - 惊奇
        - 行动
        - 情感回落
    sound:
      spatialized: true
      physical_foley_required: true
      bgm_embedded_in_video_prompt: false

  music:
    narrative_function: 托住成长、自然、冒险与情感和解
    emotional_core:
      - 温暖
      - 清澈
      - 冒险
      - 童年
      - 自然
      - 希望
      - 略带忧伤但最终向光
    instruments:
      - 钢琴
      - 弦乐群
      - 长笛
      - 双簧管
      - 单簧管
      - 圆号
      - 竖琴
      - 钟琴
      - 手风琴
      - 木琴
      - 轻打击乐
    independent_track: true
    avoid_artist_name_dependency: true

  continuity:
    required: true
    track:
      - 角色位置
      - 姿态
      - 表情
      - 服装
      - 发丝
      - 受伤与湿润状态
      - 道具归属与位置
      - 天气
      - 风向
      - 光线方向
      - 水面状态
      - 机械状态
      - 情绪状态

  prompt_assets:
    permanent_structure:
      - 镜头
      - 主体动作与面部
      - 空间和物理阻力
      - 拟音与对白
    model_syntax_locked: false

  production_adapter_reference:
    replaceable: true
    source_mentions:
      - Nano Banana Pro
      - GPT Image 2
      - Seedream 4.5
      - Seedance 2.5
      - text_to_instrumental
    known_source_conflicts:
      - "分辨率描述存在重复 480p"
      - "30 秒 Prompt 示例时间轴只写到约 15 秒"

  conflict_policy:
    no_silent_content_rewrite: true
    topic_owner: Topic Hunter
    script_semantics_owner: Script Engine
    audiovisual_owner: Audiovisual Director
    final_model_prompt_owner: Video Production
    style_can_reject_bad_fit: true

  provenance:
    extraction: source_grounded
    examples_are_canon: false
    creator_name_used_as_runtime_prompt_dependency: false
    inferred_missing_fields: false
```
