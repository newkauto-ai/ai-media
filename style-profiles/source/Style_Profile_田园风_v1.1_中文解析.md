# Style Profile：田园风

> **版本**：v1.1-zh  
> **显示名称**：田园风  
> **内部风格 ID**：`oriental_pastoral_cinematic_lifestyle`  
> **分类**：`hybrid_style_profile`  
> **升级来源**：田园风 v1.0 + 江南采茶 / 制茶 / 泡茶 / 品茗项目多轮 LookDev、视频生成、镜头审查、节奏重构与最终成片经验  
> **核心定位**：真人东方田园电影美学 + 自然生活过程 + 真实人物关系 + 高信息密度工艺细节 + 地域 / 民俗 / 非遗文化可扩展能力  
> **适用范围扩展**：田园生活、古村生活、农事、采摘、传统饮食、茶事、园艺、非遗民俗、传统工艺、手作、节气与乡土文化展示  
> **v1.1 核心升级**：从“江南采茶样片型风格”升级为可复用的东方田园 / 乡土文化 / 工艺生活 Style System，减少对年轻女性、汉服、Golden Hour、极浅景深等单一样片条件的过拟合。

---

# 0. v1.1 升级结论

田园风 v1.0 已验证了以下稳定能力：

- 通透、低至中饱和的东方自然光电影质感
- 真实人物与自然环境共处
- 长焦浅景深与轻盈前景层次
- 人物自然表演与生活化互动
- 环境镜头、人物镜头、动作镜头、材质微距之间的景别变化
- 工序细节与材料状态变化
- 自然环境声、Foley 与独立低密度 BGM

但 v1.0 仍带有明显的“江南少女采茶”样片特征：

- 年轻女性、汉服、江南、Golden Hour 占比过高
- 85–135mm + 极浅景深表达过强
- “快乐”情绪被默认得过多
- “一个镜头一个任务”过于刚性
- 缺少连续镜头的 Shot Architecture
- 缺少非遗 / 民俗 / 工艺的文化真实性边界
- 对复杂工艺的材料状态连续性定义不够系统
- 声音仍偏采茶案例，而不是材料 / 行为驱动

v1.1 将长期 Style Core 收敛为：

1. **真人东方自然主义电影质感**
2. **人物真实在场，而非摆拍**
3. **明确的前中后景、选择性对焦与自然空间层次**
4. **环境负责世界，人物负责情绪，过程负责因果，材质负责触感**
5. **镜头焦段与景深服从当前信息任务，而不是被风格固定**
6. **工艺过程必须表现“动作 → 材料反馈 → 状态变化”**
7. **相邻镜头同时考虑景别、主体与信息功能变化**
8. **现场自然声和动作声属于风格核心**
9. **地域 / 民俗 / 工艺事实必须由外部可靠信息约束，Style 不得自行编造**
10. **田园风负责“怎么看”，领域 Profile 负责“该领域怎么讲”**

---

# 1. 分类与职责边界

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - audiovisual_style_profile
    - production_playbook
    - lifestyle_story_reference
  full_series_canon: false

  flags:
    has_visual_system: true
    has_visual_domains: true
    has_cinematography_system: true
    has_shot_architecture: true
    has_performance_system: true
    has_process_state_system: true
    has_sound_system: true
    has_music_direction: true
    has_cultural_fidelity_boundary: true
```

## 1.1 本 Profile 负责

- 视觉质感
- 摄影与景深语言
- 镜头组织
- 人物表演方式
- 过程 / 材质表现
- 光线与色彩
- 环境声与 Foley
- BGM 方向
- 视觉连续性
- 文化内容的真实性边界

## 1.2 本 Profile 不负责

- 历史事实
- 非遗项目正式名称
- 地域归属
- 工艺步骤事实
- 仪式顺序
- 工具真实用途
- 服饰身份含义
- 象征意义
- 具体模型参数
- 固定镜头数量
- 固定镜头时长

这些内容必须由当前项目、脚本、研究资料或专门领域 Profile 提供。

---

# 2. 强 / 中 / 弱适配

## 强适配

- 田园生活
- 江南 / 徽州 / 山村 / 古村生活
- 茶园、花田、果园、稻田、菜园
- 采摘、农事、园艺
- 采茶、制茶、泡茶、品茗
- 家庭料理、地方食物、酿造
- 竹编、陶艺、木雕、染布、织造、造纸等传统手作
- 非遗工艺过程展示
- 民俗准备、节庆活动、集市、乡土文化
- 人物与劳动、自然、地域之间关系明确的短片

## 中等适配

- 民宿生活
- 轻旅行
- 中式园林
- 四季 / 节气
- 轻人文纪录
- 传统建筑空间体验
- 社区型地方文化活动

## 弱适配

- 都市霓虹
- 商务科技
- 高频知识口播
- 强销售硬广
- 激烈动作
- 黑暗惊悚
- 重反转剧情
- 纯视觉特效展示

---

# 3. Style Core

```yaml
style_core:
  medium: 真人超写实自然主义电影摄影

  mood_baseline:
    - 通透
    - 自然
    - 有生命感
    - 有触感
    - 有地域空气
    - 克制
    - 真实在场

  visual_keywords:
    - 东方田园电影
    - 自然主义光线
    - 前中后景层次
    - 选择性对焦
    - 长焦空间压缩
    - 自然前景
    - 真实材质
    - 人物生活化表演
    - 工艺状态变化
    - 材质微距
    - 现场环境声

  avoid_identity:
    - 商业影楼写真
    - 旅游宣传片
    - 过度梦幻滤镜
    - CG塑料质感
    - 统一模板化古风
```

---

# 4. Visual Domains

田园风不是单一“江南少女”模板。当前项目根据内容选择一个或多个 Domain。

```yaml
visual_domains:

  pastoral_lifestyle:
    中文: 田园生活
    focus:
      - 人与自然
      - 日常劳动
      - 陪伴
      - 季节
      - 生活气息
    mood_reference:
      - 通透
      - 温暖
      - 松弛
      - 明媚

  craft_process:
    中文: 传统工艺 / 手作
    focus:
      - 手
      - 工具
      - 材料
      - 制作过程
      - 物理反馈
      - 状态变化
    mood_reference:
      - 专注
      - 克制
      - 有触感
      - 人文

  folk_culture:
    中文: 民俗 / 非遗活动
    focus:
      - 人群关系
      - 仪式或活动空间
      - 服饰
      - 群体动作
      - 地域环境
      - 现场声音
    mood_reference: runtime_required

  food_tea:
    中文: 食物 / 茶 / 酿造
    focus:
      - 原料
      - 手部操作
      - 温度
      - 蒸汽
      - 液体
      - 成品
      - 品尝反馈
```

### Domain 组合示例

- 江南采茶品茗：`pastoral_lifestyle + food_tea`
- 竹编手作：`craft_process + pastoral_lifestyle`
- 陶艺制作：`craft_process`
- 晒染：`craft_process + folk_culture`
- 庙会 / 舞龙：`folk_culture`
- 地方糕点：`food_tea + craft_process`
- 古法酿造：`food_tea + craft_process`

---

# 5. 人物视觉与表演

## 5.1 人物视觉

人物身份由项目定义，不再默认必须是“年轻女性 + 汉服”。

可包括：

- 年轻人
- 中老年匠人
- 家庭成员
- 村民
- 手艺人
- 学徒
- 民俗参与者
- 群体劳动者

人物视觉原则：

- 真人感
- 自然面部比例
- 保留真实皮肤纹理
- 发丝、布料、手部有真实细节
- 服装符合当前地域、时代、身份与活动需要
- 不因“唯美”强行替换为白衣、汉服或年轻女性

## 5.2 情绪模式

```yaml
performance_emotion:
  baseline:
    - 自然
    - 在场
    - 与行为真实互动
    - 与环境真实互动

  runtime_modes:

    joyful:
      - 明媚
      - 轻松
      - 陪伴
      - 自然笑意

    serene:
      - 安静
      - 舒展
      - 松弛

    focused:
      - 专注
      - 熟练
      - 克制

    reverent:
      - 庄重
      - 尊重
      - 克制

    communal:
      - 热闹
      - 参与感
      - 群体互动
```

### 表演规则

- 人物优先看正在操作的物件、材料、工具或同伴
- 不长时间直视镜头
- 动作必须有真实接触和反馈
- 微表情来自行为结果，而不是“主动表演情绪”
- 群体民俗场景允许更强动作，但仍保持真实现场逻辑

---

# 6. 地域与环境

地域信息由项目决定。

江南 / 徽州只是 v1.0 已验证的一个 Region Preset，而不是田园风全局硬规则。

## 6.1 江南 / 徽州 Preset

可使用：

- 白墙
- 黛瓦
- 马头墙
- 深灰屋顶
- 木窗
- 石板路
- 木檐
- 竹器
- 青山
- 薄雾
- 茶园
- 庭院
- 水岸

## 6.2 环境规则

环境镜头负责：

- 地域
- 建筑
- 季节
- 天气
- 空间关系
- 活动规模

环境镜头独立承担空间交代，不要求每个工艺镜头都保留完整地域背景。

### 重要原则

**环境负责建立世界，不负责反复证明世界。**

地域建立之后，应允许镜头进入：

- 手
- 工具
- 材料
- 人物表情
- 局部动作
- 微观状态变化

---

# 7. 光线系统

## 7.1 硬原则

```yaml
lighting_core:
  principle: motivated_naturalistic_light
  rule: 光线应当像来自场景中真实存在的太阳、天空、门窗、火源或实用光源
```

Golden Hour 不再是全局硬规则。

## 7.2 Lighting Modes

```yaml
lighting_modes:

  golden_hour_pastoral:
    use_for:
      - 茶园
      - 花田
      - 田野
      - 温暖人物互动

  soft_morning:
    use_for:
      - 采摘
      - 清晨劳作
      - 古村生活

  overcast_diffuse:
    use_for:
      - 湿润地区
      - 柔和民俗纪录
      - 阴天农事

  window_side_light:
    use_for:
      - 作坊
      - 室内工艺
      - 安静手作

  courtyard_dappled:
    use_for:
      - 院落
      - 树下
      - 日常生活

  fire_practical_light:
    use_for:
      - 打铁
      - 烧制
      - 火炉
      - 夜间传统工艺
```

## 7.3 通透定义

“通透”来自：

- 清晰空气层次
- 柔和阴影
- 干净高光
- 真实色相
- 适度黑位
- 局部光线方向

不是：

- 全部提亮
- HDR 拉平
- 阴影全部打开
- 大面积白雾
- 全画面金黄色滤镜

---

# 8. 色彩

默认不是固定色板，而是“低至中等饱和 + 自然固有色 + 柔和冷暖关系”。

江南生活可参考：

```yaml
palette_reference:
  light:
    - 象牙白
    - 暖白
    - 淡金
  natural:
    - 嫩茶绿
    - 青绿
    - 柔和草绿
  secondary:
    - 灰蓝
    - 淡青
    - 黛灰
  shadow:
    - 深青绿
    - 灰蓝绿
    - 柔和墨绿
```

其他地域应保留当地真实材料、服装、建筑与自然环境固有色。

避免：

- 高饱和草绿
- 强橙青 LUT
- 霓虹
- 冷白广告光
- 统一“古风黄”

---

# 9. Camera Language：任务驱动摄影

镜头焦段与景深不再由田园风统一固定，而由当前视觉任务决定。

```yaml
camera_language:

  environment:
    purpose:
      - 地域
      - 建筑
      - 田园
      - 人群空间
    lens_behavior: wide_to_normal_or_compressed_wide
    depth_of_field: moderate_when_needed

  human_emotion:
    purpose:
      - 表情
      - 人物关系
      - 情绪反馈
    lens_behavior: medium_telephoto
    preferred_reference: 70-135mm
    depth_of_field: shallow

  action:
    purpose:
      - 人物正在做什么
      - 人与工具 / 材料关系
    lens_behavior: normal_to_short_telephoto
    preferred_reference: 50-100mm
    depth_of_field: task_dependent

  process:
    purpose:
      - 动作如何改变材料
      - 工艺因果
    lens_behavior: normal_to_short_telephoto_or_macro
    depth_of_field: task_dependent

  material_detail:
    purpose:
      - 纹理
      - 水分
      - 温度
      - 表面
      - 材料状态变化
    lens_behavior: macro
    depth_of_field: shallow_or_very_shallow

  group_or_ritual:
    purpose:
      - 群体关系
      - 仪式空间
      - 动作队形
    lens_behavior: preserve_spatial_relationships
    depth_of_field: moderate
```

### 核心原则

**焦段和景深服务信息，而不是风格强迫镜头。**

---

# 10. Depth of Field

浅景深仍是重要工具，但不再全局强制。

```yaml
depth_of_field:
  principle: task_dependent_selective_focus

  use_shallow_when:
    - 人物情绪
    - 手部动作
    - 材质微距
    - 感官细节
    - 需要隔离主体

  use_moderate_when:
    - 工艺需要同时看清手、工具、材料
    - 群体活动
    - 民俗仪式
    - 空间关系重要
    - 环境建立

  avoid:
    - 无论内容都强制极浅景深
    - 前景人物背景同时全部清晰且无视觉层次
```

---

# 11. 前景与空间层次

可使用：

- 植物
- 工具
- 竹器
- 衣袖
- 门框
- 窗框
- 蒸汽
- 器物边缘
- 现场人群局部

原则：

- 轻盈
- 自然
- 非对称
- 不规则
- 有前中后景关系
- 可与镜头运动产生轻微 parallax

避免：

- 四周全部黑掉
- 圆形窥视洞
- 大面积黑前景
- 遮住关键工艺动作
- 为了“电影感”强行加入前景

---

# 12. Shot Architecture

这是 v1.1 的核心升级之一。

## 12.1 功能角色

```yaml
shot_architecture:

  functional_roles:

    environment:
      purpose:
        - 地域
        - 空间
        - 季节
        - 氛围
        - 呼吸

    human:
      purpose:
        - 表情
        - 人物关系
        - 情绪反馈

    action:
      purpose:
        - 人物正在做什么

    process:
      purpose:
        - 动作如何改变材料
        - 工艺因果

    material:
      purpose:
        - 纹理
        - 水分
        - 温度
        - 表面
        - 物理变化

    sensory:
      purpose:
        - 闻
        - 尝
        - 触摸
        - 观察
        - 使用后的反馈
```

## 12.2 核心组织原则

**环境镜头负责世界，人物镜头负责情绪，过程镜头负责因果，材质镜头负责触感。**

镜头组合不要求机械重复固定序列，但必须避免长期停留在同一种信息功能。

## 12.3 Repetition Guard

```yaml
repetition_guard:
  principle: >
    相邻镜头如果景别、主体和信息功能中有两项高度相似，
    下一镜优先改变至少一项核心视觉功能。

  avoid:
    - 连续多个仅展示人物劳动但看不清动作的中景
    - 连续多个功能相同的环境镜头
    - 连续多个只有“人物漂亮”但无新信息的镜头
```

### 重要判断

“景别变化”本身不等于“信息变化”。

例如：

中景人物采茶 → 中近景人物采茶 → 另一位人物中近景采茶

仍可能只有一个信息：

“人在茶园里采茶”。

更好的组合：

环境 → 人物 → 手部动作 → 材料反馈 → 人物互动 → 工艺状态 → 感官反馈。

---

# 13. Primary Attention Target

v1.0 的“一镜一个任务”升级为：

```yaml
shot_design:
  principle: one_primary_attention_target
  secondary_context: allowed
```

每个镜头允许同时存在人物、环境、工具和材料，但必须明确当前观众最应该看什么。

避免一个镜头同时要求多个同等权重的视觉高潮。

---

# 14. Process Visualization / Material State Machine

这是 v1.1 面向非遗、手作、传统工艺的核心升级。

```yaml
process_visualization:

  sequence:
    - initial_state
    - human_action
    - tool_or_force
    - material_response
    - visible_state_change
    - resulting_state

  continuity_rule:
    previous_result_equals_next_input: true
```

### 茶

嫩芽 → 指尖折取 → 落入竹篮 → 倒入竹匾 → 摊开 / 翻动 → 干茶 → 注水 → 舒展 → 茶汤 → 品尝反馈

### 竹编

竹条 → 弯曲 → 穿入 → 压紧 → 经纬关系形成 → 局部结构完成 → 成品

### 陶艺

湿泥 → 手按压 → 转盘旋转 → 泥壁抬升 → 器型形成 → 修整 → 成品状态

### 染布

原布 → 浸染 → 提起 → 液体滴落 → 色彩变化 → 晾晒 → 成品纹样 / 色泽

### 硬规则

工艺型内容不能只拍“人物正在制作”。

必须让观众至少看清关键的：

**动作 → 材料反馈 → 可见状态变化。**

---

# 15. 景别语言

推荐多层景别：

### Environment
地域、建筑、田园、群体空间。

### Medium / MCU
人与环境关系、人物动作、双人互动、工艺整体操作。

### Close-Up
表情、手、工具、局部动作。

### ECU / Macro
材料表面、水滴、茶叶、木屑、泥土、竹篾、液体、蒸汽、火花、纹理变化。

不要长期停留在全景与中景，也不要为了变化而机械换景别。

---

# 16. 剪辑与信息密度

**诗意不等于低信息密度。**

```yaml
editing_rhythm:
  principle:
    - 用景别变化提高信息密度
    - 用主体变化避免重复
    - 用状态变化推动剪辑
    - 用环境镜头提供呼吸
    - 用人物近景承担情绪
    - 用过程和材质特写承担信息

  avoid:
    - 单纯依赖快速运镜提高节奏
    - 连续长时间全景 / 中景
    - 快切但无新信息
```

### Runtime Reference

```yaml
runtime_reference:
  short_form_30s:
    typical_shot_count: 14-18
    typical_shot_duration_seconds: 1.3-2.2
    status: runtime_recommended
    hard_rule: false
```

---

# 17. 镜头运动

优先：

- 微推 / 微拉
- 缓慢横移
- 轻柔跟拍
- 轻微 handheld breathing
- 微小 parallax
- 自然 rack focus
- 动作匹配转场
- 物理遮挡转场

根据 Domain 可适度增加工艺动作中的轻手持、民俗活动中的跟随、群体运动中的稳定横移。

避免无意义大环绕、FPV 式炫技、高频甩镜与复杂运镜堆砌。

---

# 18. 材质系统

## 植物
叶脉、水分、叶缘、绒毛、透光、风的反馈。

## 木 / 竹
木纹、竹纤维、切削痕迹、弯曲、压紧、摩擦。

## 泥 / 陶
湿度、黏性、指纹、转盘形变、干湿变化。

## 布 / 纤维
纺织纹理、吸水、染色、褶皱、风吹反应。

## 金属
热态 / 冷态差异、锤击反馈、火光、氧化色、淬水蒸汽。

## 液体
连续水流、表面张力、波纹、气泡、滴落、蒸汽、颜色 / 浑浊度变化。

核心原则：**材质必须对动作产生真实反馈。**

---

# 19. Cultural Fidelity

```yaml
cultural_fidelity:

  style_may_invent_facts: false

  evidence_required_for:
    - 非遗名称
    - 地域归属
    - 历史起源
    - 仪式顺序
    - 工艺步骤
    - 工具用途
    - 服饰身份
    - 象征意义
    - 禁忌与礼仪

  rule: >
    风格只能增强已经确认的事实，
    不得为了视觉效果新增、删除、重排或混合真实工艺、仪式与文化含义。
```

若事实尚未确认，保持 `UNKNOWN`，必要时进入 research / factual verification。

---

# 20. Sound Identity

```yaml
sound_design:

  ambience:
    principle: 使用与当前地域、空间和时间匹配的真实环境声

  foley:
    principle: 动作声与可见动作同步

  material_sound:
    principle: 材料本身决定声音设计

  human:
    principle:
      - 保留自然呼吸
      - 轻声交流
      - 笑声
      - 劳动中的自然声音
      - 不强制对白

  spatial_behavior:
    closeup: 动作声更近、更清楚
    environment: 声场更宽、更自然
```

示例：

- 竹编：竹篾摩擦、剪切、压紧、轻敲
- 木雕：刻刀刮木、木屑、工具接触
- 打铁：铁锤、铁砧、火焰、淬水、蒸汽
- 陶艺：湿泥、转盘、水、手掌摩擦
- 织布：梭子、织机、木构件节奏
- 民俗：人群、脚步、锣鼓、空间混响、现场自然声

---

# 21. Music Direction

```yaml
music_direction:
  independent_track: true
  vocal: false
  density: low_to_medium

  principle:
    - 不压过环境声
    - 不压过工艺动作声
    - 不强制传统古风
    - 根据 Domain 调整

  pastoral_reference:
    - 柔和钢琴
    - 木质拨弦
    - 克制古筝 / 琵琶
    - 空气感笛类音色
    - 轻打击
    - 清透铃音

  craft_reference:
    - 低密度
    - 材质感节奏
    - 留出大量 Foley 空间

  folk_reference:
    runtime_required: true
```

---

# 22. 连续性系统

```yaml
continuity:

  character:
    - 身份
    - 年龄
    - 发型
    - 服饰
    - 身份相关道具

  environment:
    - 地域
    - 建筑
    - 空间布局
    - 时间
    - 光线方向

  process:
    - 材料状态
    - 材料份量
    - 湿度
    - 加工阶段
    - 工具
    - 中间产物

  cinematography:
    - 主光方向
    - 色温
    - 对比度
    - 景深语言

  sound:
    - 环境空间
    - 材料声类型
    - 动作声连续性
```

最重要：**previous_result = next_input**

---

# 23. LookDev / Pilot

## Stage A：静态 LookDev

检查主体、场景、Key Frame：

- 真人感
- 身份可信
- 材质真实
- 地域可信
- 建筑 / 植被 / 空间关系
- 色彩与空气感
- 人物与环境关系
- 光线
- 前中后景
- 景深
- Domain 是否成立

## Stage B：短 Clip Pilot

重点检查：

1. 静帧美术能否迁移到动态
2. 景深是否过浅或变平
3. 前景是否过重
4. 人物是否退化成摆拍
5. 工艺动作是否真正可读
6. 材料是否产生真实反馈
7. 环境声 / Foley 是否与动作匹配
8. 是否为了“唯美”牺牲信息密度

失败时优先修改 Shot Intent、Primary Attention Target、景别、焦点、前中后景与 Material State。

---

# 24. Production Learnings

## 更电影 ≠ 更暗
偏向真实光线 + 空气层次 + 局部深色 + 可信对比度。

## 前景 ≠ 越多越好
前景用于空间层次、观察感、视差与视觉引导。

## 唯美 ≠ 慢
信息密度不足时，优先增加动作特写、材质镜头、状态变化、人物反馈。

## 环境与动作分离
环境镜头交代世界；过程镜头交代因果；人物镜头交代情绪；材质镜头交代触感。

## 景别变化 ≠ 信息变化
必须同时检查景别、主体、信息功能。

---

# 25. 推荐镜头原型

- `pastoral_environment`
- `cultural_environment`
- `foreground_discovery`
- `luminous_portrait`
- `natural_companion`
- `hand_action`
- `process_cause_effect`
- `material_macro`
- `sensory_closeup`
- `group_ritual`
- `quiet_environment_outro`

---

# 26. 负面约束

## 视觉
不要 CG 塑料感、过度磨皮、统一网红脸、过度 HDR、全片黄色滤镜、高饱和绿色、无来源霓虹、大面积死黑、重度 Bloom。

## 摄影
不要所有题材都强制 85–135mm；不要所有镜头都极浅景深；不要全片全景 / 中景；不要无意义复杂运镜；不要旅游宣传片式大景堆叠；不要黑洞式前景。

## 人物
不要强制年轻女性；不要强制汉服；不要强制快乐；不要摆拍；不要持续直视镜头；不要空洞 AI 微笑。

## 工艺 / 民俗
不要跳过关键状态变化；不要伪造工艺流程；不要随意混用工具；不要改写仪式顺序；不要为唯美牺牲工艺可读性；不要将地域文化符号机械堆满每个镜头。

---

# 27. Production Adapter Reference

```yaml
production_modules:

  model_adapter_reference:
    image_generation: replaceable
    video_generation: replaceable
    music_generation: replaceable

  prompt_compilation:
    require_global_visual_dna: true
    require_visual_domain: true
    require_shot_intent: true
    require_primary_attention_target: true
    require_focus_target: true
    require_process_state: when_applicable
    require_material_response: when_applicable
    require_sound_direction: true

  generation_strategy:
    visual_baseline_first: true
    short_pilot_before_batch: recommended
    inspect_real_generated_media: required
    targeted_revision_over_prompt_bloat: preferred

  fixed_shot_count_is_canon: false
  fixed_duration_is_canon: false
  fixed_lens_is_canon: false
  fixed_depth_of_field_is_canon: false
  fixed_model_is_canon: false
```

---

# 28. Runtime Recommended

```yaml
runtime_recommended:

  pastoral_lifestyle:
    human_emotion_lens: 70-135mm
    material_detail: macro
    foreground: light_to_medium
    lighting:
      - morning
      - golden_hour
      - courtyard_dappled

  craft_process:
    action_lens: 50-100mm
    material_detail: macro
    depth_of_field: task_dependent
    lighting:
      - window_side_light
      - soft_morning
      - practical_light_when_real

  folk_culture:
    lens: preserve_spatial_relationships
    depth_of_field: moderate
    camera_movement: context_dependent

  short_form_process_video:
    typical_shot_count_30s: 14-18
    typical_shot_duration_seconds: 1.3-2.2
    hard_rule: false
```

---

# 29. 与其他 Style Profile 的组合边界

田园风主要负责：

> **怎么看。**

领域 Style Profile 可以负责：

> **该领域怎么讲。**

推荐组合：

- `田园风 + traditional_craft_cinematic_documentary`
  - 非遗工艺
  - 手艺人
  - 复杂材料工序

- `田园风 + humanistic_food_cinematic_documentary`
  - 地方食物
  - 料理
  - 酿造
  - 食材制作

田园风不应复制这些 Profile 的历史叙事、工艺知识或领域事实系统。

---

# 30. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: Style_Profile_田园风_v1.1_中文解析.md

style_profile:
  style_id: oriental_pastoral_cinematic_lifestyle
  version: v1.1-zh
  classification: hybrid_style_profile

  pre_content_modules:

    compatibility:
      authority: high
      preferred:
        - 田园生活
        - 古村生活
        - 农事
        - 采摘
        - 传统饮食
        - 手作
        - 非遗工艺
        - 民俗文化
        - 东方生活方式

    cultural_fidelity:
      authority: hard
      style_may_invent_facts: false
      evidence_required_for:
        - 非遗名称
        - 地域归属
        - 历史起源
        - 仪式顺序
        - 工艺步骤
        - 工具用途
        - 服饰身份
        - 象征意义

    story_direction:
      authority: medium
      value: 环境建立 → 人物进入 → 行为 / 工艺过程 → 材料状态变化 → 人物或群体反馈 → 使用 / 完成 → 环境余韵

  audiovisual_modules:

    visual_identity:
      authority: hard
      value: 真人东方自然主义田园电影感，真实材质、自然光、明确空间层次

    visual_domains:
      authority: high
      values:
        - pastoral_lifestyle
        - craft_process
        - folk_culture
        - food_tea

    lighting:
      authority: hard
      value: motivated naturalistic light；根据场景选择清晨、Golden Hour、阴天漫射、窗侧光、庭院斑驳光或真实火光

    cinematography:
      authority: hard
      value: 镜头焦段和景深服从当前信息任务；人物情绪偏中长焦，工艺操作偏标准至中长焦，材质使用 Macro，群体与仪式优先保存空间关系

    depth_of_field:
      authority: high
      value: task-dependent selective focus；人物 / 材质可浅景深，工艺与群体空间可适度增加景深

    foreground_layering:
      authority: high
      value: 轻盈、自然、不规则前景；用于空间层次和视差，不遮挡关键动作

    performance:
      authority: high
      value: 人物自然在场；情绪由当前项目选择 joyful / serene / focused / reverent / communal

    shot_architecture:
      authority: hard
      value: 环境负责世界，人物负责情绪，过程负责因果，材质负责触感；连续镜头同时检查景别、主体与信息功能变化

    shot_design:
      authority: hard
      value: one_primary_attention_target；允许二级环境与人物信息共存

    process_visualization:
      authority: hard
      value: initial_state → human_action → tool_or_force → material_response → visible_state_change → resulting_state

    process_continuity:
      authority: hard
      value: previous_result_equals_next_input

    editing_rhythm:
      authority: high
      value: 诗意不等于低信息密度；通过景别、主体和状态变化提高信息密度，环境镜头提供呼吸

    sound_design:
      authority: high
      value: 环境 / 材料 / 行为驱动；动作与 Foley 同步，特写更近，环境镜头声场更宽

    music_direction:
      authority: medium_high
      value: 独立 BGM、无人声、低至中密度，不覆盖现场环境声与工艺声音

    continuity:
      authority: hard
      value: 锁定人物、地域、空间、材料状态、工具、光向与声音空间连续性

  production_modules:

    prompt_compilation:
      require_global_visual_dna: true
      require_visual_domain: true
      require_shot_intent: true
      require_primary_attention_target: true
      require_focus_target: true
      require_process_state: when_applicable
      require_material_response: when_applicable
      require_sound_direction: true

    visual_baseline:
      required: true
      method: LookDev 静帧 → 短 Clip Pilot → 真实生成结果审查

    adapter_reference:
      replaceable: true

    fixed_shot_count_is_canon: false
    fixed_duration_is_canon: false
    fixed_lens_is_canon: false
    fixed_depth_of_field_is_canon: false
    fixed_model_is_canon: false

  provenance:
    source_documents:
      - file: Style_Profile_田园风_v1.0_中文解析.md
        version: v1.0-zh
        source_type: previous_ready_profile

      - file: Style_Profile_田园风_v1.1_中文解析.md
        version: v1.1-zh
        source_type: production_derived_upgrade
        evidence: 江南采茶、制茶、泡茶、品茗项目多轮 LookDev、视频生成、镜头节奏重构与最终成片经验，以及面向田园生活、非遗民俗与工艺品制作的扩展审查
```

---

# 31. v1.0 → v1.1 Migration Notes

升级时保持同一：

```yaml
style_id: oriental_pastoral_cinematic_lifestyle
```

版本升级为：

```yaml
version: v1.1-zh
```

建议：

- 新增 source：`Style_Profile_田园风_v1.1_中文解析.md`
- 新增 normalized：`oriental_pastoral_cinematic_lifestyle.v1.1-zh.json`
- 不覆盖 v1.0 normalized 文件
- registry 当前条目更新至 v1.1，仅在 source SHA-256、normalized schema、provenance 和测试全部通过后标记 `ready`
- v1.0 保留为历史版本，避免破坏已有项目引用

---

# 32. 一句话风格定义

> **田园风 = 以真人东方自然主义电影为视觉基础，通过任务驱动摄影、真实人物在场、环境 / 人物 / 过程 / 材质的功能化镜头架构，以及动作—材料反馈—状态变化的过程可视化，呈现田园生活、乡土文化、非遗民俗和传统工艺的真实、通透、有人情味且有触感的影像。**
