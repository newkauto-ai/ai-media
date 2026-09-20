---
fixture_only: false
library_status: pending_review
style_profile:
  style_id: dreamy_garden_poetic_healing
  display_name: 梦幻园林诗意治愈风
  version: "v1.1-zh"
  classification: audiovisual_style_profile
---

# Style Profile：梦幻园林诗意治愈风

> **版本**：v1.1-zh  
> **内部风格 ID**：`dreamy_garden_poetic_healing`  
> **分类**：`audiovisual_style_profile`  
> **定位**：东方诗意场景绘画 / 江南园林与田园治愈叙事 / 半写实手绘背景美术  
> **核心要求**：换场景不换画风；换人物不换人物造型语言；换环境不换色彩、笔触与细节层级。  
> **关键生产约束**：抑制高频纹理和碎点噪声；Style 不覆盖 Canon；已批准画面优先成为后续拆分与改比例的视觉权威。  
> **对齐规范**：AI Media `Unified Style Profile Library Contract v1.0`

---

## 0. 风格结论

“梦幻园林诗意治愈风”以**东方诗意栖居、清透空气感、克制半写实人物、自然观察式构图、统一手绘场景语言**为核心。

它不是古风海报，不是通用日系治愈动画，也不是高反差电影概念图。目标是让观众感到：

> 这是一处真实可居、被温柔理想化的东方世界。

核心公式：

> **东方诗意场景 + 清透空气感 + 柔和手绘背景美术 + 克制半写实人物 + 自然观察构图 + 低噪点材质**

视觉关键词：

- 江南园林、白墙黛瓦、月洞门、湖池、柳树、花木、远山
- 田园溪流、村落、石桥、水岸、山谷、春夏植物
- 蓝灰雨巷、少量暖灯、湿润空气、轻雾
- 清澈蓝天、奶油白、灰绿、青绿、柔粉、暖杏
- 半写实东方场景插画
- 手绘背景美术
- 柔和漫射光
- 空气透视
- 自然观察感
- 轻微旧画册 / 模拟绘画柔化质感
- 克制细节
- 低高频噪声

---

## 1. 风格适配范围

### 强适配
- 江南园林、古典庭院、水乡、湖畔、茶舍、月洞门
- 山水田园、乡村小径、溪流、石桥、村落、花田边缘
- 春日、初夏、雨后、黄昏、蓝调时刻、月夜
- 单人静观、双人漫步、家庭或朋友的轻叙事
- 人与猫狗等动物的安静互动
- 治愈、浪漫、怀旧、诗意生活、理想栖居
- 以环境氛围为主、人物为叙事点缀的短片

### 弱适配
- 持续高速战斗
- 强烈赛博朋克、工业硬科幻
- 大量霓虹、高对比夜景
- 重口恐怖、血腥、废墟压迫
- 高饱和商业海报
- 夸张搞笑卡通
- 需要人物大头特写连续推进的偶像型短片

### Style Compatibility Gate
若题材可保留以下四项，则可使用本风格：

1. 环境具有可呼吸的空间；
2. 光线可处理为柔和自然光或克制暖光；
3. 人物可以自然比例、克制表演呈现；
4. 场景细节可以被概括，而非依赖高频写实材质。

若项目必须依赖高反差、超锐利材质、密集粒子、卡通夸张比例，则标记 `STYLE-CONTENT MISMATCH`。

---

## 2. 风格权威级

```yaml
authority:
  visual_identity: hard
  color_system: hard
  light_system: hard
  texture_and_noise_control: hard
  character_proportion: hard
  animal_stylization: hard
  composition_grammar: hard
  cinematography: hard
  environment_motion: medium_high
  performance: medium_high
  sound_design: medium
  music_direction: medium
  story_theme: low
  dialogue_semantics: none
  production_model: none
```

本风格主要拥有**视听表达权**，不拥有题材与剧本语义所有权。用户当轮明确要求、Series Canon 和 Frozen Script 高于普通风格偏好。

---

# 3. Style Core：七条硬原则

## 3.1 统一美术语言
无论园林、田野、雨巷、湖畔、人物还是动物，都必须属于同一套绘画系统：

- 同一明度体系
- 同一笔触粒度
- 同一细节密度
- 同一半写实程度
- 同一空气透视
- 同一色彩克制度

**禁止题材变化导致画风切换。**

例如：
- 园林切到田园后，不得变成通用“日系治愈动画海报”。
- 女性切到男性角色后，不得变成二次元古风立绘。
- 加入猫狗后，不得突然萌化成卡通宠物。

## 3.2 清透、明亮、空气化
“通透”不是简单提亮，而是同时满足：

- 天空干净、开阔
- 高亮区域有清洁感
- 中间调不过度堆积
- 远景更淡、更薄、更蓝灰
- 植物之间留有空气缝隙
- 暗部保持材质、不堵黑
- 水面带天空色，不成为厚重墨绿
- 白墙、云、远山、水面形成呼吸节奏
- 白墙、水面、天空承担克制的环境提亮
- 不用整画面奶灰、米灰雾化伪造柔和感

目标：

> 近景清晰但不脏，中景柔和，远景轻薄，空气真实存在。

## 3.3 抑制高频纹理和碎点噪声
这是本风格的**硬约束**。

### 地面
石板、土路、墙面和木结构采用大块面表达：

- 保留整体色差
- 保留必要缝隙
- 保留少量苔藓
- 保留轻微湿润感
- 禁止密集砂粒
- 禁止大量微裂纹
- 禁止碎点高光
- 禁止镜面式湿地反射
- 禁止局部锐化产生“砂纸感”

### 植物
- 以树冠、草丛、花团为主要单位
- 叶片只在视觉焦点附近少量分化
- 花朵不铺满独立小点
- 避免“满屏碎花点 + 叶片噪声”

### 水体
- 反射是柔和色块与宽笔触
- 波纹稀疏、方向统一
- 避免密集高频闪点

### 服装 / 毛发
- 纹样和发丝分组表达
- 不逐根绘制
- 不添加无意义亮点颗粒

核心标准：

> 远看有丰富度，近看仍是绘画概括，而不是材质扫描。

## 3.4 环境优先，人物为叙事点缀
- 环境面积通常大于人物面积
- 人物是空间中的生活者，不是“贴在背景上的立绘”
- 人物服装色与场景色相协调
- 人物轮廓清晰，但不能比建筑、天空、水面锐利多个等级
- 宠物是关系点，不是卖萌焦点

## 3.5 自然观察感优先于海报感
允许：
- 建筑被画框裁切
- 树枝进入前景遮挡
- 人物偏离中心
- 局部元素不完整
- 非对称平衡
- 前景自然形成框景
- 月洞门、桥、门窗形成“景中景”

避免：
- 主体永远居中
- 人物 + 狗正面走来 + 山 + 云形成模板式中心构图
- 每个对象都完整展示
- 所有视觉元素围绕主角做完美放射
- 过度对称

## 3.6 Style Lock / Style Fingerprint
LookDev 获得人工接受后，必须冻结并跨图复用同一个 `style_fingerprint`，至少包含：

- medium
- edge_softness
- saturation
- value_range
- atmospheric_depth
- foliage_granularity
- texture_noise
- character_stylization
- skin_rendering
- fabric_rendering
- reflection_behavior
- camera_observation_level

Contact Sheet、系列独立图、拆分图与比例扩展不得只靠“重新写一段相似提示词”维持风格。若 fingerprint 中的媒介、饱和度或细节密度明显变化，视为 `STYLE DRIFT`。

## 3.7 Style Does Not Overwrite Canon
- Style 负责“怎么画”，不决定具体人物必须是什么体型、发型或身份特征。
- 当存在 Source Canon / Series Canon 时，角色体态、地点身份和 Canon 文字优先于 Profile 默认值。
- 禁止把不同角色统一美型化、瘦削化或套用同一肩颈、腰胯、面孔模板。
- 通用 Profile 不硬编码任何具体文学人物姓名、固定住所事实或牌匾文本。

---

# 4. 视觉身份

## 4.1 绘画媒介感
基础媒介：

- 高质量二维数字手绘
- 背景美术式绘制
- 半写实东方插画
- 柔和绘画边缘
- 宽色块 + 局部细化
- 轻微模拟绘画 / 旧画册柔化质感
- 哑光表面

不要变成：
- 真人照片
- 超写实摄影
- 3D 渲染
- 塑料感 CG
- 游戏概念图式硬锐化
- 通用动漫截图
- 厚重油画
- 过度水彩晕染

## 4.2 细节策略
细节采用**非均匀分布**：

- 主视觉附近：中等细节
- 次要区域：概括
- 远景：低细节
- 天空：大色块
- 植物：群组化
- 地面：宽笔触
- 人物：面部和手部足够准确，但服装纹理克制

---

# 5. 色彩系统

## 核心色盘

### 主色
- 清透柔蓝
- 蓝绿
- 灰绿
- 柳绿
- 暖白 / 奶白
- 浅石灰
- 深灰黛瓦色

### 辅助色
- 柔粉
- 杏粉
- 珊瑚粉
- 暖杏
- 蜜桃云霞
- 少量暖金

### 限制色
- 大面积高饱和黄
- 荧光绿
- 鲜艳正红
- 深黑
- 高饱和电蓝
- 大面积橙黄发光

### 色彩关系
- 整体高明度、中低饱和
- 绿色偏自然灰绿，而不是塑料翠绿
- 蓝色清澈但稍柔化
- 粉色偏花瓣与云霞，不偏荧光
- 暖色作为小面积情绪点
- 夜景以蓝灰为主体，暖灯只作局部点缀

---

# 6. 光线系统

## 6.1 日景
优先：
- 柔和晴日天光
- 漫射光
- 白墙反射光
- 树间漏光
- 轻微斑驳光
- 水面柔和反光
- 花树边缘轻透光

避免：
- HDR
- 强烈轮廓光
- 电影级硬光束
- 大面积金色神光
- 所有物体都带外发光

## 6.2 黄昏 / 夜景
- 天空仍保留蓝灰层次
- 暖窗、灯笼是小面积情绪点
- 商店内部不做大面积橙黄光墙
- 光源外溢克制
- 湿地只保留局部柔和反光
- 暗部不能堵黑

## 6.3 雨景
- 蓝灰空气
- 轻雾
- 雨线细而稀
- 石板轻湿，不做镜面
- 水体反光集中在河道 / 池面
- 避免地面长条橙色高亮

---

# 7. 建筑与环境设计

## 7.1 园林 / 水乡
推荐元素：

- 白墙黛瓦
- 月洞门
- 木窗、木栏
- 石桥
- 水池、湖泊、溪流
- 垂柳
- 桃 / 梅 / 樱类柔粉花树
- 石板小径
- 小亭、小楼
- 远山、薄雾

建筑要有生活尺度，不堆叠“所有古风元素”。

## 7.2 田园 / 野外
田园场景仍需保持相同美术语言：

- 乡村土路或简化石路
- 小溪
- 低矮石桥
- 白墙村舍
- 山谷
- 稻田或普通农田
- 树木、草坡、少量野花
- 空旷天空

避免：
- 夸张动画大云
- 大面积黄色花海抢色
- 满地密集小花
- 人物成为中心偶像组合

## 7.3 泛化原则
可扩展至：

- 江南园林
- 山间村落
- 水乡雨巷
- 湖畔居所
- 田园溪谷
- 古镇街巷
- 茶园、竹林、山路

但每次只选择少数主要母题，不做元素合集。

## 7.4 Location Identity System
当项目存在地点 Canon 时，每个地点必须提供并遵守：

- `architecture_signature`
- `botanical_signature`
- `spatial_signature`
- `material_signature`
- `mood_signature`

可选补充 `required_motifs` 与 `forbidden_substitutions`。禁止把有明确地点身份的竹院、田园、雪景、夜景或历史场所自动替换成通用“花树 + 小桥 + 亭 + 湖”的漂亮江南园林。

## 7.5 Motif Budget
- 每个镜头只保留 2–4 个主母题。
- 桥、亭、月洞门、花树、水面不要求同时出现。
- 花木密度必须服从地点、季节、天气与叙事，不把“花多”当成风格一致。
- 同组多格图至少一半镜头不得重复相同核心母题组合。
- 风格一致来自 fingerprint、媒介、色彩和空间语言，不来自元素复制。

---

# 8. 人物设计

## 8.1 成人比例
默认基线：

- **7.5–8 头身**
- 头部略小
- 肩宽自然
- 腰线清晰
- 腿部自然平衡
- 服装不能把人体比例完全吞没
- 全身角色脚部落地明确
- `body_type` 必须按角色设定区分，可为纤细、匀称、丰腴或健朗
- 存在 Source Canon / Series Canon 时，Canon 覆盖默认体态
- 面部宽窄、肩宽、腰胯与肢体厚度必须与角色设定一致

禁止：
- 六头身成人
- 大头小身
- Q 版
- 少年漫画式夸大眼睛
- 偶像立绘比例漂移
- beauty normalization
- 把全体角色统一成同一种瘦削古风美人模板

## 8.2 面部
- 东方青年自然面孔
- 五官细腻但不动漫化
- 眼睛不过大
- 高光克制
- 鼻唇结构存在但柔化
- 表情轻微、自然
- 避免“乙女游戏角色感”

## 8.3 服装
- 中式传统或传统倾向服装可用
- 颜色融入场景
- 低饱和
- 纹样稀疏
- 宽袖、裙摆、衣角提供自然动态
- 避免复杂金线、密集刺绣、舞台戏服感

## 8.4 表演
优先：

- 静观
- 慢走
- 转头
- 轻微微笑
- 看水、看花、看远方
- 与同行者短暂对视
- 与动物轻互动
- 手持扇、书、花束、篮子等简单道具

避免：
- 夸张大笑
- 强 pose
- 偶像式凝视镜头
- 长时间正面站桩

## 8.5 Fabric Drape System
衣褶必须由重力、身体支撑与地面接触共同驱动：

- 一级大褶决定重量和方向，二级次褶补充结构，只保留少量微褶
- 丝绸、纱、棉麻等材质使用不同褶皱尺度与软硬度
- 站立、坐姿、倚靠、躺卧分别遵循实际接触点
- 躺卧衣料必须表现压、堆、拖、展开的重量关系

禁止：

- 重复三角褶
- 等距平行折线
- 几何图案式复制
- 左右近似镜像的褶皱结构

---

# 9. 动物设计

动物保持自然写生式简化：

- 体态真实
- 头身正常
- 眼睛自然
- 毛发大块分组
- 动作生活化
- 不额外拟人化

猫狗可以提供治愈感，但禁止：

- 大眼萌化
- Q 版
- 夸张笑脸
- 卡通短腿比例
- 过密毛发高频纹理
- 抢夺画面主视觉

---

# 10. 构图语言

## 10.1 三层空间

默认保持：

1. **前景框景层**：树枝、花叶、墙角、窗框、石栏等
2. **主体生活层**：人物、道路、水岸、建筑主要立面
3. **远景空气层**：远山、村落、天空、雾气

深度通过：

- 遮挡
- 饱和度递减
- 对比递减
- 细节递减
- 色温变化
- 轻微视差

而不是依赖极端景深虚化。

## 10.2 竖屏 9:16
常用：

- 上部留天空或树冠
- 中部承载人物与主建筑
- 下部用道路 / 水岸形成引导
- 主体不要贴边
- 画面保留呼吸区

## 10.3 景中景
可使用：

- 月洞门
- 门窗
- 桥洞
- 树冠间隙
- 廊道
- 水面倒影

用于建立第二视觉层，但避免每个镜头都使用。

---

# 11. 镜头语言

## 11.1 总体倾向
镜头像“温柔观察者”，而不是炫技摄影机。

关键词：

- 观察
- 克制
- 呼吸
- 缓慢进入
- 自然遮挡
- 轻微视差
- 空间先于人物
- 人物融入环境

## 11.2 推荐景别

### 环境大全景 / 全景
用于建立园林、村落、溪谷、湖畔空间；人物可以较小。

### 环境主导全身 / 中远景
这是本风格最重要的叙事景别：

- 人物漫步
- 两人同行
- 人与动物互动
- 人物停留于桥、门、岸边

### 中景
用于：
- 轻对话
- 转头
- 手持花束 / 书 / 扇
- 柔和关系推进

### 特写
只作为稀缺镜头：
- 手触花枝
- 猫抬头
- 水滴
- 书页
- 衣角
- 灯笼轻晃

## 11.3 摄影机高度
默认：

- 眼平
- 略低于眼平
- 轻微高位用于展示水面、庭院布局

避免无理由极端俯拍 / 仰拍。

## 11.4 镜头运动
优先：

- 缓慢推近
- 缓慢拉远
- 轻柔横移
- 与人物同速慢跟
- 树叶前景轻遮挡产生视差
- 沿水岸或小径缓慢推进

允许偶尔：
- 从植物后方显露主体
- 轻微弧线移动
- 低速升降

禁止：
- 快速甩镜
- 无动机环绕
- 持续无人机式飞越
- 高频变焦
- 大幅晃动手持
- 机械匀速、无缓入缓出

## 11.5 镜头节奏
推荐：

> 环境建立 → 人物进入 / 动作 → 小细节 → 情绪停顿 → 空间回收

镜头不应持续制造“高能点”，而应保留静观与呼吸。

---

# 12. 环境运动

## 风
- 柳枝轻摆
- 发丝少量飘动
- 袖口、裙摆缓慢响应
- 草叶方向存在局部差异

## 水
- 小尺度连续波纹
- 倒影柔和变化
- 溪流有低速方向性
- 雨滴形成稀疏涟漪

## 花与叶
- 少量花瓣即可
- 避免满屏粒子
- 花瓣运动有风向和重量

## 云与雾
- 缓慢
- 低对比
- 不使用高速翻涌特效

---

# 13. 雨夜与暖光特别规则

雨夜可用，但必须避免滑向“电影霓虹夜景”。

### 必须
- 蓝灰冷环境
- 小面积暖灯
- 薄雾
- 石板轻湿
- 河面 / 水面承担主要反光
- 远景暖光点逐渐减弱

### 禁止
- 地面镜面化
- 大量长条橙色反射
- 商铺整墙发光
- 黑位压死
- 灯笼数量过多
- 暖色占据大面积画面

---

# 14. 声音设计

本风格声音以“空间真实 + 治愈克制”为原则。

推荐环境声：

- 轻风
- 柳叶摩擦
- 鸟鸣
- 溪水
- 水面细波
- 木窗轻响
- 远处人声
- 雨滴
- 脚步踩石板 / 土路
- 猫狗轻叫
- 衣料摩擦

声音不要层层铺满，应留安静。

---

# 15. 音乐方向

若使用音乐：

### 情绪
- 清澈
- 温柔
- 宁静
- 轻浪漫
- 怀旧
- 轻微向往

### 乐器
- 钢琴
- 木质拨弦
- 长笛 / 轻木管
- 轻弦乐
- 少量古筝 / 琵琶作为东方点缀
- 清透铃音

### 原则
- 不浓重古风
- 不史诗
- 不大编制煽情
- 不盖住环境声
- 不依赖知名音乐人名字

---

# 16. 生产提示词编译规则

## 16.1 永久视觉 Prompt Core

```text
poetic East-Asian scenic illustration,
refined hand-painted background art,
restrained semi-realistic character design,
airy and luminous atmosphere,
clear softened blue and blue-green palette,
warm white, muted gray-green, soft pink and peach accents,
soft diffused natural light,
atmospheric depth,
broad painterly color masses,
simplified foliage groups,
matte surface,
subtle analog softness,
restrained micro-detail,
natural observational composition,
unified art language across people, animals, architecture and environment,
luminous value separation,
clear atmospheric depth without milky haze,
depth-dependent contrast reduction,
character-specific natural body morphology,
no beauty-normalized body template,
gravity-driven irregular fabric folds,
source-grounded location identity,
scene-specific botanical density,
limited motif budget,
preserve approved visual fingerprint across the series
```

## 16.2 人物约束

```text
natural adult proportions,
7.5–8 heads tall,
slightly smaller head,
natural shoulders,
long balanced legs,
subtle East-Asian facial features,
restrained expression,
integrated into the environment,
not anime-protagonist styling
```

## 16.3 高频噪声抑制

```text
broad simplified surfaces,
low micro-texture,
no granular stone texture,
no dense speckles,
no micro-cracks,
no noisy reflective dots,
no excessive individual leaves,
no excessive tiny flowers,
no gritty surface detail,
no over-sharpening
```

## 16.4 雨景约束

```text
gently wet pavement,
subtle broken local reflections,
visible stone slabs,
blue-gray rainy atmosphere,
small restrained warm lights,
no mirror-like ground,
no long orange reflection streaks,
no large glowing storefront
```

## 16.5 Canonical Text Integrity
- 非必要文字默认不生成；禁止自动角标、场景标题、诗句和装饰性伪书法。
- Canon 牌匾、店招、题字必须 exact match；任一错字即 `TEXT FAIL`。
- 首选生成空白牌匾，再用独立文字层覆盖正确汉字。
- 若必须直接生成文字，需做逐字视觉复核；失败时只修牌匾，不重画全场景。

## 16.6 Approved Frame Lock
用户表达“锁定这一版”“保持这一版”“拆成独立图”“只改比例”“不改变画风/构图”时，自动启用 `approved_frame_lock: true`。

处理优先级：

1. 原图裁切或 panel extraction
2. 保留锁定像素的精准 outpaint
3. 局部编辑
4. 最后才允许 prompt-based regeneration

锁定状态下不得把已批准画面重新解释成“相似的新图”。

## 16.7 Multi-panel / Contact Sheet Policy
- Contact Sheet 只承担 LookDev、Storyboard、视觉比较和风格一致性测试。
- 某格获批后，最终资产优先抽取该格；仅在比例不足时 outpaint。
- 独立图必须保留获批 panel 的人物身份、style fingerprint、palette、光线与构图核心。
- Contact Sheet 通过不等于单格高分辨率、手部、面部或 Canon 文字已经通过最终验收。

---

# 17. 负面约束

## 风格漂移
- 禁止通用日系动画海报感
- 禁止角色立绘插入背景
- 禁止动漫大眼
- 禁止 Q 版
- 禁止游戏概念图硬锐化
- 禁止 3D 塑料感
- 禁止真人摄影感

## 材质与噪点
- 禁止颗粒石材
- 禁止微裂纹堆积
- 禁止碎点高光
- 禁止满地小花点
- 禁止逐叶高频描绘
- 禁止毛发逐根锐化
- 禁止高频水面闪点
- 禁止全画面统一高细节

## 色彩
- 禁止大面积荧光绿
- 禁止高饱和黄花海主导
- 禁止大片正红
- 禁止大面积橙光
- 禁止极深黑位
- 禁止 HDR

## 构图
- 禁止海报式永远居中
- 禁止每个元素完整展示
- 禁止无意义强对称
- 禁止模板化“人物正面走来 + 狗 + 大山 + 大云”

## 光影
- 禁止大面积外发光
- 禁止过强轮廓光
- 禁止所有灯都产生长反射
- 禁止夜景变成霓虹氛围

## Canon、衣褶与系列一致性
- 禁止 generic ancient-garden substitution
- 禁止 identical slender-beauty body template
- 禁止 repeated geometric fabric folds
- 禁止 equal-spaced pleats
- 禁止 global gray-beige haze
- 禁止 decorative pseudo-Chinese text
- 禁止 invented labels
- 禁止 automatic corner captions
- 禁止每个场景重复 bridge-pavilion-flower formula

---

# 18. 风格漂移检测

### A. 人物
- 是否 7.5–8 头身？
- 头是否过大？
- 是否开始动漫化？
- 是否像独立角色立绘？
- 服装是否比环境精细过多？

### B. 环境
- 是否仍清透？
- 植物是否过密？
- 天空是否变成夸张动画大云？
- 远景是否足够轻？
- 是否出现高频纹理？

### C. 色彩
- 黄绿是否过强？
- 暖橙是否面积过大？
- 黑位是否过重？
- 蓝绿、奶白、柔粉是否仍占主导？

### D. 地面与水
- 地面是否镜面化？
- 是否出现碎点反光？
- 水面是否变成高频闪烁？
- 石板是否仍以宽块面呈现？

### E. 构图
- 是否有自然观察感？
- 是否又回到标准海报模板？
- 人物是否压过环境？
- 是否有足够呼吸区？

### F. Canon 与角色差异
- 是否按角色 Canon 保留体型、肩宽、腰胯和肢体厚度差异？
- 是否发生统一瘦削化或美型模板化？
- 地点是否保留 architecture / botanical / spatial / material / mood signature？

### G. 衣褶与文字
- 衣褶是否由重力和接触点驱动？
- 是否出现重复三角褶、等距平行或镜像几何结构？
- Canon 文字是否 exact match？是否出现不需要的角标、诗句或伪书法？

### H. 系列与批准画面
- 同系列的 medium、saturation、detail density 是否继承冻结 fingerprint？
- 多格地点是否重复相同花树、桥、亭、水面组合？
- 已批准画面在拆分或改比例时是否被重新生成而漂移？

若任意 2 个以上核心项失败，标记：

```text
STYLE DRIFT — REGENERATE OR CORRECT
```

---

# 19. 连续性状态

```yaml
continuity_state:
  character:
    identity:
    age_range:
    body_proportion:
    face_style:
    hairstyle:
    costume:
    position:
    gaze:
    expression:
    wetness:

  animal:
    species:
    coat_pattern:
    body_scale:
    position:
    action:

  environment:
    location_type:
    architecture_language:
    season:
    weather:
    time_of_day:
    sky_palette:
    foliage_palette:
    water_state:
    ground_wetness:
    light_direction:

  visual:
    detail_density:
    saturation_level:
    noise_level:
    atmospheric_depth:

  style_fingerprint:
    medium:
    edge_softness:
    saturation:
    value_range:
    atmospheric_depth:
    foliage_granularity:
    texture_noise:
    character_stylization:
    skin_rendering:
    fabric_rendering:
    reflection_behavior:
    camera_observation_level:

  canon:
    character_canon:
    location_canon:
    canonical_text:
```

其中 `body_proportion`、`detail_density`、`noise_level`、`atmospheric_depth` 与冻结后的 `style_fingerprint` 是必须跨镜头跟踪的关键状态；Canon 始终作为运行时输入，不写死进通用 Profile。

---

# 20. 生产层适配

## 图像生成
优先流程：

1. 场景 LookDev
2. 冻结 style fingerprint
3. 角色 Canon / 体型差异测试
4. 人物 + 场景融合测试
5. 地点 signature 与 motif budget 测试
6. 衣褶、Canonical Text 与 Contact Sheet 测试
7. 雨景 / 夜景变体测试

不要一开始堆所有元素。

## 视频生成
图生视频时重点保护：

- 人物自然比例
- 面部克制
- 建筑结构
- 低噪点表面
- 水体宽波纹
- 植物群组化运动
- 灯光面积
- 远景空气透视

若视频模型自动增加颗粒、雨滴高光或地面反光，应主动压低。

## Remotion / 后期
适合：

- 缓慢推拉
- 分层轻视差
- 雾气轻移动
- 树叶轻摆
- 少量花瓣
- 水面柔波

不建议：

- 过量粒子
- 镜头震动
- 高频光斑
- 大量 bloom
- 过强锐化
- 颗粒叠加

---

# 21. 冲突处理

```text
用户当轮明确要求
> Series Canon
> Frozen Script
> 本 Style Profile
> 默认 Audiovisual Director
> Production Adapter
```

规则：

- 不静默修改剧情语义
- 不为“更漂亮”牺牲风格一致性
- 不为“更高清”增加高频噪声
- 不为“更电影感”增加大面积 glow / HDR
- 不为“更可爱”破坏人物与动物比例
- 若用户明确要求高饱和、卡通化或电影高反差，应视为本轮风格覆盖，而不是悄悄混合

---

# 22. v1.1 静态 LookDev 回归定义

以下 A–F 仅作为通用回归结构，不携带任何具体文学人物、地点或牌匾 Canon。静态定义完整不等于真实视觉已通过；真实输出仍需人工连续审阅，Profile 在此之前保持 `pending_review`。

## Case A — 园林人物与空气层次
- 远景对比、饱和度和细节明显低于近景。
- 人物与环境属于同一渲染语言。
- 无高频地砖、叶片或花点噪声。

## Case B — Canon 体型差异
- 同一 fingerprint 下覆盖 slender、fuller、sturdy 三种运行时 Canon。
- 三者保持同一 Style，但不得收敛为同一瘦削美型模板。

## Case C — 躺卧人物衣褶
- 重力与地面接触决定衣料压、堆、拖、展开。
- 无重复三角褶、等距折线或镜像几何结构。

## Case D — 四种地点身份
- 每个地点提供五项 signature，并能通过环境识别地点性格。
- 至少一半 panel 不重复同一核心母题组合。

## Case E — Canon 汉字
- exact match；任一错字为 `TEXT FAIL`。
- 直接生成不稳定时可切换为空牌匾 + 后期精确文字层。

## Case F — Contact Sheet 到独立图
- 获批 panel 优先 extraction / crop，必要时才 outpaint。
- 人物身份、palette、medium、fingerprint 和构图核心不得漂移。
- 不以重新文生图替代已批准视觉资产。

---

# 23. 机器可读 Normalized Style Profile

```yaml
style_profile:
  style_id: dreamy_garden_poetic_healing
  display_name: 梦幻园林诗意治愈风
  version: v1.1-zh
  classification: audiovisual_style_profile

  pre_content_modules:
    compatibility:
      authority: low
      preferred:
        - 江南园林
        - 山水田园
        - 水乡生活
        - 治愈日常
        - 诗意古风轻叙事
        - 人与动物温柔互动
      weak_for:
        - 高速战斗
        - 重口恐怖
        - 赛博朋克
        - 高饱和商业海报
        - 夸张卡通喜剧

  audiovisual_modules:
    visual_identity:
      authority: hard
      medium:
        - 二维数字手绘
        - 半写实东方场景插画
        - 背景美术式绘制
        - 哑光表面
        - 轻微模拟绘画柔化
      identity:
        - 东方诗意栖居
        - 清透空气感
        - 自然观察构图
        - 环境优先
        - 人物克制
        - 统一美术语言
      avoid:
        - 通用日系动画海报
        - 真人摄影
        - 3D塑料感
        - 游戏概念图硬锐化
        - 角色立绘贴背景

    color_system:
      authority: hard
      primary:
        - 清透柔蓝
        - 蓝绿
        - 灰绿
        - 柳绿
        - 奶白
        - 暖白
      accent:
        - 柔粉
        - 杏粉
        - 暖杏
        - 少量暖金
      restricted:
        - 大面积高饱和黄
        - 荧光绿
        - 大面积正红
        - 大面积橙黄发光
        - 深黑

    light_system:
      authority: hard
      daylight:
        - 柔和漫射天光
        - 白墙反射光
        - 树间漏光
        - 水面柔和反光
      dusk_night:
        - 蓝灰环境
        - 小面积暖灯
        - 暗部保留材质
      avoid:
        - HDR
        - 强外发光
        - 大面积轮廓光
        - 镜面湿地反射

    airiness_system:
      authority: hard
      require:
        - clean_highlights
        - separated_midtones
        - depth_based_contrast_falloff
        - depth_based_saturation_falloff
        - visible_air_gaps
        - reflective_lift_from_sky_water_or_white_surfaces
      avoid:
        - global_milky_haze
        - muddy_midtones
        - blocked_dark_regions
        - uniformly_dense_foliage

    texture_and_noise_control:
      authority: hard
      rule: 抑制高频纹理和碎点噪声
      ground:
        - 大块面石板或土路
        - 少量缝隙
        - 稀疏苔藓
        - 轻微湿润
      foliage:
        - 树冠群组
        - 草丛群组
        - 花团群组
      water:
        - 宽笔触反射
        - 低频波纹
      prohibit:
        - 颗粒石材
        - 密集微裂纹
        - 碎点高光
        - 满屏独立小花
        - 逐叶高频描绘
        - 逐根毛发锐化
        - 水面密集闪点
        - 全画面统一高细节

    character_system:
      authority: hard
      default_adult_proportion: 7.5-8_heads
      body_type_policy: character_specific
      canon_override: required_when_available
      beauty_normalization: prohibited
      allow_body_variation:
        - slender
        - balanced
        - fuller
        - sturdy
      head_scale: slightly_small
      shoulder_width: natural
      legs: natural_balanced
      face: 东方青年自然五官，细腻但不动漫化
      expression: 克制自然
      wardrobe: 低饱和、传统或传统倾向、融入环境
      role_in_frame: narrative_accent_not_dominant

    fabric_drape_system:
      authority: hard
      principles:
        - gravity_driven
        - contact_point_driven
        - hierarchical_fold_scale
        - material_specific
        - pose_specific
      prohibit:
        - repeated_triangle_folds
        - equal_spacing_folds
        - geometric_fold_pattern
        - mirrored_fold_structure

    location_identity_system:
      authority: hard
      source_canon_first: true
      required_signature_fields:
        - architecture_signature
        - botanical_signature
        - spatial_signature
        - material_signature
        - mood_signature
      generic_garden_substitution: prohibited

    motif_budget:
      authority: medium_high
      major_motifs_per_shot: 2-4
      repeated_signature_combo_across_series: avoid
      scene_specific_botanical_density: required

    animal_system:
      authority: hard
      stylization: natural_simplified
      prohibit:
        - 大眼萌化
        - Q版
        - 夸张笑脸
        - 高频毛发

    composition_grammar:
      authority: hard
      layers:
        - 前景框景层
        - 主体生活层
        - 远景空气层
      preferred:
        - 非对称平衡
        - 自然遮挡
        - 建筑局部裁切
        - 景中景
        - 环境面积大于人物
      avoid:
        - 海报式永远居中
        - 无意义强对称
        - 每个对象完整展示
        - 模板式人物正面走来

    cinematography:
      authority: hard
      camera_role: 温柔观察者
      shot_priority:
        - 环境大全景
        - 环境主导全身
        - 中远景
        - 克制中景
        - 稀缺细节特写
      movement:
        - 缓慢推近
        - 缓慢拉远
        - 轻柔横移
        - 同速慢跟
        - 前景视差
        - 低速弧线移动
      avoid:
        - 快速甩镜
        - 高频变焦
        - 无动机环绕
        - 持续无人机炫技
        - 大幅手持晃动
        - 机械匀速

    environment_motion:
      authority: medium_high
      wind: subtle_visible
      water: soft_continuous
      petals: sparse
      fog: slow
      clouds: slow

    performance:
      authority: medium_high
      principle: 小动作、轻视线、自然停顿
      preferred:
        - 慢走
        - 静观
        - 转头
        - 轻微微笑
        - 与同行者短暂对视
        - 与动物轻互动

    sound_design:
      authority: medium
      preferred:
        - 风
        - 叶片摩擦
        - 鸟鸣
        - 溪水
        - 雨滴
        - 脚步
        - 木窗
        - 猫狗轻叫
      density: sparse

    music_direction:
      authority: medium
      emotional_core:
        - 清澈
        - 温柔
        - 宁静
        - 轻浪漫
        - 怀旧
      instruments:
        - 钢琴
        - 木质拨弦
        - 长笛
        - 轻弦乐
        - 少量古筝
        - 少量琵琶
        - 清透铃音
      avoid:
        - 浓重古风
        - 史诗编制
        - 过度煽情

  production_modules:
    prompt_core:
      authority: hard
      positive_semantics:
        - poetic East-Asian scenic illustration
        - refined hand-painted background art
        - restrained semi-realistic character design
        - airy and luminous atmosphere
        - broad painterly color masses
        - simplified foliage groups
        - restrained micro-detail
        - natural observational composition
        - unified art language
        - luminous value separation
        - clear atmospheric depth without milky haze
        - depth-dependent contrast reduction
        - character-specific natural body morphology
        - no beauty-normalized body template
        - gravity-driven irregular fabric folds
        - source-grounded location identity
        - scene-specific botanical density
        - limited motif budget
        - preserve approved visual fingerprint across the series
      negative_semantics:
        - no granular stone texture
        - no dense speckles
        - no micro-cracks
        - no noisy reflective dots
        - no excessive individual leaves
        - no excessive tiny flowers
        - no over-sharpening
        - no anime protagonist proportions
        - no mirror-like wet pavement
        - no large glowing storefront
        - no generic ancient-garden substitution
        - no identical slender-beauty body template
        - no repeated geometric fabric folds
        - no equal-spaced pleats
        - no global gray-beige haze
        - no decorative pseudo-Chinese text
        - no invented labels
        - no automatic corner captions
        - no repeated bridge-pavilion-flower formula across every scene

    style_fingerprint:
      freeze_after_lookdev_acceptance: true
      fields:
        - medium
        - edge_softness
        - saturation
        - value_range
        - atmospheric_depth
        - foliage_granularity
        - texture_noise
        - character_stylization
        - skin_rendering
        - fabric_rendering
        - reflection_behavior
        - camera_observation_level

    canonical_text_integrity:
      default_nonessential_text: omit
      canonical_text: exact_match_required
      preferred_workflow:
        - blank_signboard_in_base_image
        - post_overlay_exact_text
      direct_generation_requires_review: true
      wrong_character_result: TEXT_FAIL
      invented_decorative_text: prohibited

    approved_frame_lock:
      trigger_phrases:
        - 锁定这一版
        - 保持这一版
        - 拆成独立图
        - 只改比例
        - 不改变画风
        - 不改变构图
      priority:
        - crop_or_extract
        - outpaint_preserving_locked_pixels
        - local_edit
        - regeneration_last
      prompt_regeneration_when_lock_active: avoid

    multi_panel_policy:
      contact_sheet_role:
        - lookdev
        - storyboard
        - comparison
        - style_consistency_test
      final_asset_policy:
        - extract_approved_panel
        - preserve_identity
        - preserve_style_fingerprint
        - outpaint_only_when_required

    continuity_required:
      - character.body_proportion
      - character.face_style
      - animal.body_scale
      - environment.sky_palette
      - environment.foliage_palette
      - visual.detail_density
      - visual.noise_level
      - visual.atmospheric_depth
      - style_fingerprint.medium
      - style_fingerprint.saturation
      - style_fingerprint.foliage_granularity

    quality_gate:
      fail_if:
        - 人物头身比例明显低于自然成人比例
        - 地面出现密集颗粒或碎点反光
        - 画面转向通用动漫海报
        - 黄绿或橙光大面积失控
        - 环境被人物完全压制
        - 夜景黑位堵死
        - 植物或水体出现全画面高频细节
        - 存在明确角色 Canon，却被统一瘦削化或美型模板化
        - 衣褶出现重复三角形、等距平行或明显几何复制
        - 地点存在 Canon，但场景退化为通用江南园林
        - 多格图中多个地点重复同一花树+桥+亭模板
        - 画面整体被奶灰或米灰雾化，丢失清透空气层次
        - 夜景暖灯或水面反光面积过大，抢占主视觉
        - Canon 牌匾或题字存在任一错字
        - 非必要场景出现自动生成的标题、诗句或装饰文字
        - 已批准画面在拆分或改比例时被重新生成并导致视觉漂移
        - 同一系列输出的 medium、saturation 或 detail density 明显变化

    lookdev_regression_cases:
      - case_id: A
        focus: garden_character_airiness
        pass_criteria:
          - depth_falloff_visible
          - unified_character_environment_rendering
          - no_high_frequency_ground_or_foliage_noise
      - case_id: B
        focus: canon_body_type_variation
        pass_criteria:
          - one_style_multiple_body_types
          - no_slender_beauty_normalization
      - case_id: C
        focus: reclining_fabric_drape
        pass_criteria:
          - gravity_and_contact_driven_folds
          - no_repeated_geometric_folds
      - case_id: D
        focus: location_identity_variation
        pass_criteria:
          - five_signature_fields_present
          - motif_combinations_not_repeated_across_majority
      - case_id: E
        focus: canonical_chinese_text
        pass_criteria:
          - exact_match_or_TEXT_FAIL
          - blank_signboard_overlay_fallback_available
      - case_id: F
        focus: approved_panel_to_final_asset
        pass_criteria:
          - extraction_or_outpaint_before_regeneration
          - identity_palette_medium_and_fingerprint_preserved

    model_adapter_reference:
      replaceable: true
      model_syntax_locked: false

  provenance:
    source_documents:
      - file: 本对话中的风格参考图与多轮生成验证
        extraction: direct_visual_analysis_and_iterative_validation
        period: 2026-09-18_to_2026-09-20
      - file: ai-media_梦幻园林诗意治愈风_v1.1_升级Short-Spec.md
        extraction: production_experience_short_spec
        period: 2026-09-20
      - file: Style_Profile_梦幻园林诗意治愈风_v1.1_生产经验升级.md
        extraction: normalized_source_profile_with_production_guardrails
    extracted_modules:
      - visual_identity
      - color_system
      - light_system
      - texture_and_noise_control
      - character_system
      - animal_system
      - composition_grammar
      - cinematography
      - environment_motion
      - production_quality_gate
      - airiness_system
      - character_canon_override
      - fabric_drape_system
      - location_identity_system
      - motif_budget
      - style_fingerprint
      - canonical_text_integrity
      - approved_frame_lock
      - multi_panel_policy
      - lookdev_regression_cases
    examples_are_canon: false
    creator_name_used_as_runtime_prompt_dependency: false
    inferred_missing_fields: false
```

---

# 24. 最终生产检查表

生成任何关键帧或视频镜头前后，按以下顺序检查：

1. **画风有没有漂**：是否仍是东方半写实手绘场景美术？
2. **空气感**：是否清透、远景轻、暗部不堵？
3. **人物 Canon**：默认比例是否自然，角色体型差异是否被保留，是否发生统一瘦削美型化？
4. **噪声**：地面、草、树、水、衣服有没有碎点与高频纹理？
5. **色彩**：蓝绿、奶白、柔粉是否主导，黄绿 / 橙光是否失控？
6. **构图**：是否自然观察，而不是模板海报？
7. **动物**：是否自然、非卡通萌化？
8. **衣褶**：是否由重力与接触点驱动，是否出现重复几何褶？
9. **地点身份与母题**：是否遵守 location signature，并避免重复花桥亭模板？
10. **Canon 文字**：是否 exact match，非必要文字是否被省略？
11. **Frame Lock**：已批准画面是否优先抽取 / outpaint，而不是重新生成？
12. **系列一致性**：是否继承冻结 style fingerprint？
13. **镜头运动**：是否克制、缓慢、有呼吸？

满足以上条件，才视为本 Style Profile 的有效输出。
