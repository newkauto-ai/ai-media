# Style Profile：田园风

> **版本**：v1.0-zh  
> **显示名称**：田园风  
> **内部风格 ID**：`oriental_pastoral_cinematic_lifestyle`  
> **分类**：`hybrid_style_profile`  
> **来源**：江南汉服田园短片多轮 LookDev、视频生成、镜头审查与成片验证  
> **核心定位**：真人东方田园电影美学 + 自然生活过程 + 诗意人物关系 + 高质感工艺细节  
> **重要判断**：该风格不是“慢节奏唯美空镜”或“古风写真”，而是以通透自然光、长焦浅景深、前景层次、自然人物表演与高信息密度生活细节共同构成的东方田园电影语言。

---

## 0. 解析结论

“田园风”的核心不是简单叠加：

- 汉服
- 茶园
- 白墙黛瓦
- Golden Hour
- 美女
- 浅景深

真正稳定、可复用的 Style Core 是：

1. **通透、明媚、低饱和的东方自然光电影质感**
2. **人物与自然环境真实共处，而不是古风写真式摆拍**
3. **85–135mm 中长焦 / 长焦 + 浅景深 + 前景虚化层次**
4. **阳光通过人物、发丝、衣料、植物和蒸汽被感知，而不是靠直接拍太阳**
5. **环境大景负责交代地域，人物中近景负责情绪，微距与极近景负责动作和材质**
6. **一个镜头只承担一个主要视觉任务**
7. **生活工序必须拆成真正可读的动作细节，而不是用漂亮中景概括**
8. **人物情绪以自然、轻松、快乐、相互陪伴为核心**
9. **环境声与动作拟音是沉浸感的重要组成；BGM 必须独立制作并给现场声音留空间**
10. **摄影机像观察生活，而不是要求人物向摄影机展示自己**

该风格尤其适合采茶、制茶、花田、传统饮食、手作、园艺、农事、江南生活、古村日常等题材。

---

# 1. 分类

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
    has_cinematography_system: true
    has_performance_system: true
    has_editing_rhythm: true
    has_sound_system: true
    has_music_direction: true
    has_process_detail_system: true
    has_location_identity: true
```

---

# 2. 风格适配范围

## 强适配

- 江南古村、徽派村落、茶园、花田、山村
- 采茶、制茶、泡茶、品茗
- 传统饮食与食材制作
- 花艺、园艺、采摘、农事
- 竹编、染布、陶艺等轻劳动传统手作
- 东方女性田园生活
- 古村生活方式短片
- 无强剧情、依靠画面与动作表达的诗意短片
- 需要同时表现“人物之美 + 环境之美 + 生活过程”的视频

## 中等适配

- 家庭料理
- 民宿生活
- 四季生活
- 轻旅行
- 中式园林
- 乡村节气
- 传统节庆中的生活片段

## 弱适配

- 都市霓虹
- 商务科技
- 高频知识口播
- 强销售广告
- 激烈动作
- 黑暗惊悚
- 重剧情反转
- 需要大量对白推动故事的视频

---

# 3. 权威级

```yaml
authority:
  topic_direction: soft
  story_structure: medium
  visual_identity: hard
  location_identity: high
  character_styling: high
  cinematography: hard
  depth_of_field: hard
  foreground_layering: high
  lighting: hard
  color: high
  performance: high
  process_detail: hard
  editing_rhythm: high
  sound_design: high
  music_direction: medium_high
  production_model: none
```

具体人物身份、地域、工艺事实和故事内容仍由当前项目决定。

Style Profile 不得因为“田园风”擅自编造：

- 历史年代
- 工艺流程
- 茶叶品种
- 地域传统
- 人物身份
- 建筑历史

---

# 4. Style Core

```yaml
style_core:
  medium: 真人超写实电影摄影
  mood:
    - 通透
    - 明媚
    - 诗意
    - 温柔
    - 轻盈
    - 自然
    - 快乐
    - 有生活气息

  visual_keywords:
    - 东方田园电影
    - 自然逆光
    - 浅景深
    - 长焦空间压缩
    - 前景虚化
    - 发丝轮廓光
    - 半透明衣料
    - 植物透光
    - 空气感
    - 自然抓拍
    - 材质微距

  avoid_mood:
    - 阴郁
    - 冷艳
    - 神秘压抑
    - 商业影楼
    - 网红写真
    - 旅游宣传片
```

---

# 5. 人物视觉

## 5.1 人物基础

人物以年轻成年东亚女性为主要视觉原型时：

- 明确成年
- 自然清秀的东方五官
- 面部比例真实
- 保留真实皮肤纹理
- 自然妆容
- 不追求夸张网红脸
- 乌黑自然长发
- 可使用半挽发、简单布花、发带等古典造型

人物美感来自：

**自然光 + 表情 + 发丝 + 动作 + 环境关系**

而不是依靠浓妆或过度精修。

## 5.2 服装

江南古典田园方向优先：

- 象牙白
- 暖白
- 浅蓝
- 灰蓝
- 淡青

材质：

- 亚麻
- 棉麻
- 轻纱
- 柔软天然布料

设计：

- 素雅
- 宽松
- 轻盈
- 生活化
- 东方传统服饰轮廓

避免：

- 奢华宫廷服饰
- 皇冠
- 大量金饰
- 高饱和刺绣
- 现代时装元素

---

# 6. 人物表演系统

## 核心原则

人物必须像正在生活，而不是正在拍摄。

```yaml
performance:
  baseline:
    - 松弛
    - 自然
    - 快乐
    - 专注
    - 轻微互动

  gaze:
    preferred:
      - 看手中的物件
      - 看植物
      - 看茶叶
      - 看同伴
      - 看正在进行的劳动
    avoid:
      - 长时间直视镜头
      - 广告式展示

  micro_expression:
    - 轻轻微笑
    - 低头笑
    - 相视一笑
    - 闻香后的舒展
    - 小幅惊喜
    - 做完事情后的满足

  physical_behavior:
    - 手指真实接触物件
    - 动作必须有开始、接触、反馈、完成
    - 衣袖和发丝受微风自然影响
```

快乐应表现为真实朋友或同伴之间的小反应。

禁止：

- 连续假笑
- 模特摆 Pose
- 大幅挥手
- 夸张转身
- 镜头前表演“快乐”

---

# 7. 地域与环境视觉

## 7.1 江南 / 徽派原型

当项目选择江南或徽州地域时，推荐地域锚点：

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
- 水岸或自然绿植

空间通常形成：

**植物前景 → 人物 / 劳动中景 → 建筑 → 山体 / 雾气远景**

## 7.2 地域真实性

建筑只负责提供地域身份，不应成为每个镜头的背景装饰。

推荐：

- 用单独环境镜头明确交代建筑与地理
- 工艺镜头不强制出现建筑
- 人物特写不强制出现完整茶园
- 微距镜头只服务当前动作和材质

### 重要规则

**不要为了证明“江南”而让所有镜头同时出现人物、茶园、白墙黛瓦和山。**

地域已经建立后，应允许镜头进入局部。

---

# 8. 光线系统

## 8.1 基本光线

首选真实自然光：

- 清晨
- Golden Hour
- 柔和侧逆光
- 柔和逆光
- 窗边自然光
- 庭院斑驳光

## 8.2 光线表现方式

不要主要通过拍太阳表达“Golden Hour”。

应通过其结果表达：

- 黑发边缘形成细腻金色发丝光
- 白色衣袖产生轻微半透明透射
- 嫩叶边缘产生黄绿色透光
- 蒸汽被光束照亮
- 白瓷出现柔和暖高光
- 人物一侧脸颊获得自然暖光

```yaml
lighting:
  key: 自然侧逆光或逆光
  fill: 环境漫反射
  shadow: 柔和青绿或灰蓝
  highlight: 暖象牙白、淡金
  contrast: medium
  bloom: subtle
  atmosphere:
    - 极细晨雾
    - 轻微浮尘
    - 自然空气透视
```

## 8.3 通透原则

“通透”不是：

- 全部提亮
- HDR 拉平
- 阴影全部打开
- 白色过曝

真正的通透来自：

**清晰的空气层次 + 柔和阴影 + 干净高光 + 真实色彩分离。**

避免：

- 大面积死黑
- 重度 vignette
- 全画面金黄滤镜
- 过量 bloom
- 白雾泛灰
- 过度 HDR

---

# 9. 色彩系统

核心色盘：

```yaml
palette:
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

调色原则：

- 低至中等饱和
- 绿色真实但不荧光
- 人肤自然
- 暖高光 + 稍冷阴影
- 黑位存在但不压死
- 高光柔和滚降

禁止：

- 高饱和草绿
- 强橙青 LUT
- 霓虹
- 全片黄色滤镜
- 冷白广告光

---

# 10. 镜头语言

## 10.1 镜头核心

首选：

- 85mm
- 100mm
- 135mm
- Macro

长焦用于：

- 人物
- 情绪
- 自然观察
- 空间压缩
- 前后景层次

微距用于：

- 手
- 植物
- 食材
- 茶叶
- 液体
- 蒸汽
- 器物
- 工艺状态变化

大广角只在有明确空间需求时使用。

---

# 11. 浅景深系统

浅景深是本风格的重要识别特征。

```yaml
depth_of_field:
  behavior: selective_focus
  foreground: strongly_soft
  subject: sharp
  secondary_people: soft
  environment: progressively_soft
  optical_feel: natural
```

每个镜头必须明确：

**当前焦点是谁 / 是什么。**

例如：

- 茶芽清晰，人物虚化
- 手指清晰，脸部柔化
- 人脸清晰，茶园柔化
- 茶汤清晰，人物完全化为背景散景

禁止所有层级同时清楚。

---

# 12. 前景遮挡与空间层次

前景遮挡是风格工具，不是目的。

可使用：

- 茶叶
- 花枝
- 树叶
- 竹器
- 衣袖
- 门框
- 窗框
- 蒸汽
- 器物边缘

原则：

- 不规则
- 自然
- 非对称
- 明暗混合
- 与镜头运动产生轻微 parallax

通常可以占画面的小到中等比例，但不得机械锁定数值。

避免：

- 四周全部黑掉
- 圆形窥视洞
- 大面积黑前景
- 遮住人物关键动作
- 为遮挡而遮挡

经过实拍式 LookDev 验证后，本风格更倾向：

**轻盈遮挡，而不是沉重窥视。**

---

# 13. 景别结构

本风格不允许长期停留在全景与中景。

推荐建立以下视觉层级：

### Environment Shot

用途：

- 地域
- 村落
- 茶园
- 季节
- 天气

### Medium / Medium Close-Up

用途：

- 人与环境关系
- 人物动作
- 双人互动

### Close-Up

用途：

- 表情
- 手
- 器物
- 局部动作

### Extreme Close-Up / Macro

用途：

- 一芽一叶
- 指尖
- 水滴
- 叶脉
- 食材纤维
- 茶汤
- 蒸汽
- 水流
- 材料状态改变

---

# 14. 工序型内容镜头规则

这是“田园风”从普通唯美视频升级为真正成片感的重要规则。

对于：

- 采茶
- 制茶
- 料理
- 手作
- 采花
- 染布
- 陶艺
- 农事

不能只拍“人物正在做某件事”的中景。

必须拆出动作细节。

例如：

```text
发现嫩芽
→ 手靠近
→ 指尖接触
→ 折下
→ 落入竹篮
→ 倒入竹匾
→ 摊开
→ 翻动
→ 成品状态
→ 使用 / 品尝
```

每个重要状态变化至少有一个能够清楚读懂动作的近景或特写。

---

# 15. 一个镜头一个任务

```yaml
shot_design:
  rule: one_primary_visual_task_per_shot

  examples:
    - 展示徽派古村
    - 看清人物笑容
    - 看清嫩芽被采下
    - 看清叶子落入竹篮
    - 看清茶叶摊开
    - 看清水冲入茶碗
    - 看清朋友相视而笑
```

禁止单镜同时要求：

- 人物漂亮
- 建筑完整
- 茶园完整
- 工艺动作完整
- 光影高潮
- 多人互动

这种设计会削弱所有信息。

---

# 16. 剪辑与信息密度

风格基线是：

**流畅，而不是慢。**

诗意不等于长镜头。

对于 20–60 秒工序型短片：

- 环境镜头数量受控
- 通过景别变化形成节奏
- 动作状态变化推动剪辑
- 特写承担信息密度
- 人物近景承担情绪
- 环境镜头提供呼吸

推荐节奏关系：

```text
细节
→ 人物
→ 环境
→ 动作
→ 极近景
→ 人物互动
→ 工艺变化
→ 微距高潮
→ 情绪
→ 环境收束
```

30 秒使用较高镜头密度可以作为运行时参考，但**镜头数量不是 Style Canon**。

实际生产中应根据：

- 动作数量
- 音乐节拍
- 信息复杂度
- 生成模型能力

决定镜头长度。

---

# 17. 镜头运动

优先：

- 微推
- 微拉
- 缓慢横移
- 轻柔跟拍
- 轻微 handheld breathing
- 微小 parallax
- rack focus
- 动作匹配转场

避免：

- 无意义大环绕
- FPV
- 高频甩镜
- 大幅摇摆
- 持续快速推进
- 为“电影感”堆砌复杂运镜

电影感主要来自：

**构图 + 景深 + 光线 + 动作 + 剪辑**

而不是运镜数量。

---

# 18. 情绪与人物关系

核心不是孤独、神秘、距离感。

本风格默认更接近：

```yaml
emotion:
  baseline:
    - 愉悦
    - 轻松
    - 陪伴
    - 好奇
    - 满足

  social_behavior:
    - 分享手中的东西
    - 相视微笑
    - 一起劳动
    - 看同伴完成动作
    - 品尝后的自然回应
```

“快乐”应是轻微而可信的。

避免变成：

- 商业广告式兴奋
- 偶像剧式夸张
- 连续大笑
- 强制治愈

---

# 19. 材质表现

必须保留真实材质。

重点包括：

### 植物

- 叶脉
- 透光
- 水分
- 叶缘
- 细小绒毛
- 微风反馈

### 布料

- 棉麻纹理
- 纱质透光
- 袖口重量
- 风吹反应

### 竹器

- 编织纹理
- 哑光
- 使用痕迹

### 陶瓷

- 白瓷柔和高光
- 轻微反射
- 真实厚度

### 液体

- 水流连续性
- 波纹
- 表面张力
- 蒸汽
- 茶汤透明度

不要塑料质感。

---

# 20. 自然声与拟音

声音属于风格核心。

```yaml
sound_design:
  ambience:
    - 鸟鸣
    - 微风
    - 树叶
    - 茶树
    - 庭院环境
    - 远处自然环境

  foley:
    - 叶片折取
    - 茶叶摩擦
    - 竹篮
    - 竹匾
    - 石板脚步
    - 衣料
    - 水流
    - 倒茶
    - 茶杯
    - 木桌

  human:
    - 极轻自然笑声
    - 必要时模糊交谈气息

  behavior:
    - 动作与声音同步
    - 特写时动作声更近
    - 环境镜头声场更宽
```

不要过度 ASMR。

不要人为把所有细节音放大。

---

# 21. BGM 系统

BGM 与视频生成声音规划必须分离。

视频生成本身优先生成：

- 环境音
- Foley
- 人物自然声音

音乐作为独立资产后期加入。

```yaml
music_direction:
  independent_track: true
  vocal: false

  mood:
    - 通透
    - 清新
    - 温柔
    - 东方
    - 轻盈
    - 有流动感

  density: low_to_medium

  instrumentation_reference:
    - 柔和钢琴
    - 木质拨弦
    - 轻打击
    - 克制古筝
    - 克制琵琶
    - 空气感笛类音色
    - 清透铃音

  avoid:
    - 大编制史诗
    - 沉重古装剧配乐
    - 强鼓点
    - EDM
    - 悲情二胡主奏
    - 过度古风
```

音乐应主动给：

- 鸟鸣
- 水声
- 茶叶声
- 器皿声

留出频率与动态空间。

---

# 22. 连续性系统

必须跟踪：

```yaml
continuity:
  character:
    - 脸部身份
    - 年龄
    - 发型
    - 发饰
    - 服装
    - 配色

  environment:
    - 地域
    - 建筑
    - 茶园或田园结构
    - 光线方向
    - 时间

  process:
    - 原料状态
    - 原料数量
    - 湿度
    - 加工阶段
    - 器具

  cinematography:
    - 主光方向
    - 色温
    - 对比度
    - 景深语言
```

工序型内容尤其必须保持：

**前一步结果 = 后一步输入。**

---

# 23. LookDev 方法

本风格强烈建议先进行 Style LookDev，而不是直接批量生成。

## 第一阶段：静态风格基准

优先验证：

### 主角

检查：

- 东方真人感
- 肤质
- 发型
- 汉服材质
- 自然表情

### 场景

检查：

- 茶园 / 田园
- 徽派建筑
- 地域可信度
- 色彩
- 空气感

### Key Frame

检查：

- 人物 + 环境关系
- 浅景深
- 前景
- 光影
- 情绪

## 第二阶段：短视频 Pilot

先做一个短 Clip。

重点检查：

1. 静帧美术是否能够迁移到动态视频
2. 景深是否在运动后变平
3. 前景遮挡是否过重
4. Golden Hour 是否变成统一黄滤镜
5. 人物是否从生活状态退化成摆拍
6. 视频是否因为追求唯美而缺少动作信息

如果失败：

**优先修改镜头任务与画面关系，不要简单继续增加 Prompt 形容词。**

---

# 24. 实际生产中验证出的关键纠偏

## 24.1 “更电影”不等于“更暗”

曾验证：

过度强调：

- deep shadows
- dark foreground
- voyeuristic framing

容易让画面变闷、压抑。

本 Style 更适合：

**柔和阴影 + 通透空气 + 局部深色层次。**

## 24.2 前景不是越多越好

前景用于：

- 建立空间
- 增加景深
- 制造偶然观察感

不是用于：

- 把主体框成洞
- 遮住动作
- 让画面变暗

## 24.3 唯美不等于慢

过长的全景和中景会导致：

- 信息密度低
- 工序不可读
- 节奏松散

解决方式不是更快运镜，而是：

**增加特写与状态变化。**

## 24.4 环境与动作分开

正确：

```text
一镜交代茶园
一镜交代古村
一镜表现人物
一镜表现手
一镜表现嫩芽
一镜表现水流
```

错误：

```text
每一个镜头都同时要求
人物 + 茶园 + 古村 + 工艺 + 光影
```

---

# 25. 推荐镜头原型库

以下是可复用的镜头原型，而不是固定分镜。

### pastoral_environment

长焦压缩田园、村落和远山。

### foreground_discovery

通过轻微虚化植物发现人物。

### luminous_portrait

侧逆光人物近景，发丝与衣料透光。

### natural_companion

双人或多人自然交流。

### hand_action

手与材料真实接触。

### material_macro

植物、食材、茶叶、布料、陶瓷、竹器微距。

### physical_transition

倾倒、散开、翻动、注水、蒸汽等状态变化。

### sensory_closeup

闻、尝、触摸、观察。

### quiet_environment_outro

人物缩小，让环境重新成为结尾主体。

---

# 26. 负面约束

## 视觉

- 不要动漫
- 不要 CG 塑料感
- 不要过度磨皮
- 不要网红脸
- 不要现代影棚灯
- 不要过度 HDR
- 不要高饱和绿色
- 不要霓虹色
- 不要整体黄滤镜
- 不要大面积死黑
- 不要重度 Bloom

## 镜头

- 不要全片都是全景和中景
- 不要所有景物同时清晰
- 不要旅游宣传片式大景堆叠
- 不要无意义复杂运镜
- 不要连续慢镜头
- 不要黑洞式前景遮挡

## 人物

- 不要摆拍
- 不要长时间看镜头
- 不要僵硬站立
- 不要表情空洞
- 不要夸张表演
- 不要连续人工笑容

## 内容

- 不要为了“田园”而堆满所有地域符号
- 不要跳过关键工序动作
- 不要用中景代替所有细节
- 不要工艺状态不连续

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
    require_shot_intent: true
    require_focus_target: true
    require_process_state: when_applicable
    require_sound_direction: true

  generation_strategy:
    visual_baseline_first: true
    short_pilot_before_batch: recommended
    inspect_real_generated_media: required
    targeted_revision_over_prompt_bloat: preferred
```

具体模型、版本、分辨率、平台与 Prompt 语法不属于 Style Core。

---

# 28. Runtime 推荐值

以下为 `runtime_recommended`，不是永久硬规则：

```yaml
runtime_recommended:
  lenses:
    portrait: 85-135mm
    detail: macro

  depth_of_field:
    portrait: shallow
    detail: very_shallow

  lighting:
    preferred:
      - morning
      - golden_hour
      - side_backlight

  shot_rhythm:
    process_video: medium_fast
    environment: slower
    macro_action: concise

  shot_distribution:
    environment: limited
    medium_closeup: frequent
    closeup: frequent
    extreme_closeup_macro: frequent

  foreground:
    amount: light_to_medium
    style: irregular_natural

  music:
    density: low_to_medium
    vocal: false
```

---

# 29. 缺失与开放项

```yaml
missing_or_partial:
  exact_historical_period: runtime
  exact_region: runtime
  exact_character_identity: runtime
  exact_costume_design: runtime
  exact_process_facts: external_source_required
  exact_music_bpm: runtime
  exact_shot_count: runtime
  exact_clip_duration: runtime
```

Style Profile 不锁死这些内容。

---

# 30. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: Style_Profile_田园风_v1.0_中文解析.md

style_profile:
  style_id: oriental_pastoral_cinematic_lifestyle
  version: v1.0-zh
  classification: hybrid_style_profile

  pre_content_modules:
    compatibility:
      authority: high
      preferred:
        - 江南田园
        - 茶园
        - 古村生活
        - 农事
        - 采摘
        - 传统饮食
        - 手工艺
        - 东方生活方式

    story_direction:
      authority: medium
      value: 环境建立 → 人物进入 → 具体劳动过程 → 材质与状态变化 → 人物互动 → 使用或品尝 → 环境余韵

    content_guardrails:
      authority: hard
      value:
        - 不因风格编造历史与工艺事实
        - 地域和工序由当前项目提供
        - 风格不得强制添加古风剧情

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 真人东方田园电影感，通透自然光，低至中饱和青绿与暖金，真实材质

    character_visual:
      authority: high
      value: 自然东方真人、素雅服装、真实肤质、自然发丝与轻盈布料

    environment_identity:
      authority: high
      value: 地域环境通过独立环境镜头建立，江南模式以白墙黛瓦、马头墙、茶园、青山薄雾为主要锚点

    lighting:
      authority: hard
      value: 清晨或 Golden Hour 自然侧逆光，通过发丝、衣料、叶片、蒸汽和器物表现光

    palette:
      authority: high
      value: 象牙白、嫩茶绿、低饱和青绿、灰蓝、黛灰、淡金

    cinematography:
      authority: hard
      value: 85–135mm 长焦为主，Macro 表现材质；浅景深、选择性对焦、自然前景遮挡与轻微空间压缩

    depth_of_field:
      authority: hard
      value: 单镜只保留一个主要焦点层，其余前后景递进虚化

    foreground_layering:
      authority: high
      value: 使用植物、竹器、衣袖、窗框、蒸汽等形成轻盈、不规则、非对称的自然前景层次

    performance:
      authority: high
      value: 人物松弛、快乐、自然，专注于劳动和同伴，不以镜头为表演对象

    process_detail:
      authority: hard
      value: 工序必须拆解为接近、接触、动作、材料反馈与完成状态，并使用近景、极近景或微距表现

    shot_design:
      authority: hard
      value: 一个镜头一个主要视觉任务；环境、人物、动作、材质与情绪分镜承担

    editing_rhythm:
      authority: high
      value: 流畅而非拖慢，通过景别变化与状态变化提高信息密度，环境镜头提供必要呼吸

    sound_design:
      authority: high
      value: 保留鸟鸣、风、植物、脚步、材料、竹器、水流、器皿及自然人物声，并与动作同步

    music_direction:
      authority: medium_high
      value: BGM 独立制作，无人声、轻盈东方现代电影感、低至中密度，并给环境声与 Foley 留空间

    continuity:
      authority: hard
      value: 锁定人物身份、服装、地域空间、光向，以及工序材料的前后状态

  production_modules:
    visual_baseline:
      required: true
      method: LookDev 静帧 → 短 Clip Pilot → 真实生成结果审查

    prompt_strategy:
      value:
        - 先定义 Shot Intent
        - 明确 Focus Target
        - 明确景别
        - 明确前中后景关系
        - 明确光源效果
        - 工序镜头明确材料状态变化
        - 避免通过增加形容词修复结构性镜头问题

    adapter_reference:
      replaceable: true

    fixed_shot_count_is_canon: false
    fixed_duration_is_canon: false
    fixed_model_is_canon: false

  provenance:
    source_documents:
      - file: Style_Profile_田园风_v1.0_中文解析.md
        version: v1.0-zh
        source_type: production_derived_style_profile
        evidence: 多轮江南采茶、制茶、泡茶、品茗短视频 LookDev 与成片迭代

    extracted_modules:
      - field: visual_identity
        extraction_type: production_validated

      - field: cinematography
        extraction_type: production_validated

      - field: process_detail
        extraction_type: production_validated

      - field: editing_rhythm
        extraction_type: production_validated

      - field: performance
        extraction_type: production_validated

      - field: sound_design
        extraction_type: production_validated

      - field: music_direction
        extraction_type: production_validated
```

---

# 31. 一句话风格定义

> **田园风 = 通透自然光下的东方真人田园电影，以长焦浅景深和轻盈前景构建诗意空间，用快乐自然的人物关系承载情绪，用近景、极近景和微距把采摘、料理、手作等生活过程真正拍清楚。**
