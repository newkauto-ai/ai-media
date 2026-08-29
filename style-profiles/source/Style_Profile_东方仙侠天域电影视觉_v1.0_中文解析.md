# Style Profile：东方仙侠天域电影视觉

> **版本**：v1.0-zh  
> **内部风格 ID**：`eastern_xianxia_celestial_cinema`  
> **分类**：`pure_visual_style`  
> **库状态**：`pending_review`  
> **批准依据**：Phase B 中文评审稿已获用户通过  
> **研究基线**：[`liyue-aigc/xianxia-visual-director@bd886174`](https://github.com/liyue-aigc/xianxia-visual-director/commit/bd886174f4d84659f2381c4f5baa610003c5bdda)  
> **来源关系**：本文件为 AI 自媒体独立编写的正式 source；外部仓库只作为 `inspiration_only` 研究线索，不是运行依赖。

---

## 0. Style Core

这是一份**环境与空间优先的东方仙侠电影视觉 Profile**。核心不是固定白玉宫殿、朱柱、月门、云海或某一套构图，而是：

> 以可见尺度关系、清楚空间拓扑、结构可信的东方幻想建筑、高明度选择性色彩、有来源的电影光、可区分材质和跨镜连续性，构成可居住、可延展、可连续拍摄的天域环境。

本 Profile 负责环境尺度、空间文明、建筑语言、光色材质、环境人物视觉和连续性锁。它不拥有 Topic Thesis、Frozen Script、角色 Canon、历史事实、对白、声音、旁白、音乐、模型语法或生成流程。

## 1. 分类与适配

```yaml
classification:
  primary: pure_visual_style
  full_series_canon: false

flags:
  has_visual_system: true
  has_camera_language: true
  has_environment_performance: conditional
  has_sound_system: false
  has_voice_system: false
  has_music_system: false
  has_prompt_templates: false
  has_model_specific_rules: false
```

### 强适配

- 东方仙侠、东方神话、天界文明、神域城市和悬空建筑；
- 需要敬畏、神圣、辽阔、明透或巨构压迫的环境型镜头；
- 天门、仙城、云港、藏经阁、观星台、神树书阁、天河和悬空宫阙；
- 需要在横屏和竖屏中保持同一环境视觉身份的短视频项目；
- 需要环境基线支持多镜头连续性的项目。

### 条件适配

- 强动作：只提供环境基底，动作语法由当前 Beat 或动作 Profile 决定；
- 人物特写或对白：只继承色温、材质、服装结构与背景 Domain，不强制微小人物和完整环境层级；
- 地理总览：用户或脚本明确需要城区分布时允许高位镜头；
- 历史题材：建筑、服饰、器物与礼制由事实来源或 Series Canon 决定；
- 暗黑或水墨媒介：先确定一个主视觉身份，不平均混合多个色彩和材质系统。

### 弱适配

- 现代写实都市、纯工业科幻、产品静物、室内口播和极简信息图；
- 没有仙侠转译需求的严格历史复原；
- 看不见环境身份的连续人物近景；
- 全片持续手持、混乱透视或刻意低清脏污影像。

## 2. Pre-Content 边界

```yaml
pre_content_modules:
  compatibility:
    authority: medium
    preferred:
      - 东方仙侠环境与世界观展示
      - 神域城市、悬空宫阙、天门和天域文明
      - 敬畏、神圣、辽阔或巨构压迫的环境型镜头
    conditional:
      - 强动作
      - 人物近景
      - 地理总览
      - 历史题材
    avoid:
      - 现代写实都市
      - 纯工业科幻
      - 产品静物与室内口播

  content_boundaries:
    authority: hard
    value:
      - 不拥有 Topic Thesis 或 Frozen Script
      - 不定义角色身份、剧情动作、事实或对白
      - 不把视觉方便当成内容改写理由
```

若新加载规则会改变已冻结语义，标记 `UPSTREAM-CONSTRAINT-LATE` 或 `FLAG-CONFLICT`，不静默改写脚本。

## 3. 权威级

```yaml
authority:
  hard:
    - global_visual_identity
    - eastern_construction_logic
    - material_family_and_response
    - palette_hierarchy
    - motivated_light_and_atmosphere
    - selected_visual_domain_identity
    - continuity_locks

  conditional:
    - viewer_subordinate_camera
    - tiny_environment_scale_figures
    - deep_focus
    - open_edge_monumentality
    - cropped_or_occluded_megastructure
    - dense_inhabited_realm
    - complete_environment_depth_chain

  current_project_overrides:
    - Topic Thesis 与 Frozen Script
    - 角色 Canon、当前动作与道具状态
    - 历史、地理、器物与礼制事实
    - 建筑功能与人物安全语义
    - 用户明确机位、焦段、构图与画幅
    - 当前 Beat 的景别、时长与运动

  runtime_only:
    - 模型语法与参考图绑定
    - 像素尺寸、分辨率、seed 与平台参数
    - 调用数量、成本、重试与停止条件
```

覆盖顺序继续遵守：

```text
current_user_override > Series Canon > selected Style Profile > runtime_recommended
```

## 4. Global Visual DNA

### 4.1 关系化巨物尺度

“宏大”必须由画面关系成立。环境建立镜头从以下证据中选择适合当前构图的组合：

- 人与门洞、柱列、平台、桥梁或树木直接比较；
- 结构延伸出画面或跨越云层、峡谷、水系和城区；
- 重复构件随纵深规律递减；
- 近处框架、人物承载面、主结构、从属空间与极远终点形成尺度断层；
- 城市通过连通城区、交通、庭院、水系和极远聚落证明文明范围。

不把人物比例、空间层数或证据数量写成所有镜头统一的逐像素硬阈值。

### 4.2 单一主导空间几何

每个环境镜头选择一个主要阅读系统：单点纵深、对称轴、对角线引导、框景揭示、曲线流动、纵向上升或横向层叠。辅助元素服从主几何，不制造多个消失点或多个等强奇观。

### 4.3 结构可信的东方幻想建筑

- 先建立梁、柱、屋面、基座、平台厚度、连接、承重和通行关系；
- 再把飞檐、斗拱、纹样、漆木、矿物色和金属边缘集中在可读区域；
- 巨型表面简洁、安静、有重量，不铺满同密度装饰；
- 允许悬浮大陆、云上基础和天河，但透视、重力、材质和光线保持内部一致；
- 东方识别来自空间秩序与构造语言，不是欧式城堡、现代摩天楼或混凝土巨物贴中式屋顶。

### 4.4 携带空间信息的开放区域

天空、门洞、庭院、水面、云隙、桥下、平台间空隙和远方天光用于显示层级、悬空高度、轮廓和光值变化。开放区域不是空白或均匀灰雾，占比按构图和叙事决定。

### 4.5 高明度与选择性色彩

- 天空、云、水、浅石、玉和远景以高明度、中低纯度为基底；
- 朱红、矿物绿、群青、衣饰或窄幅金属高光只在关键区域提高纯度；
- 白石、玉、云和皮肤保持材质区别，不受统一橙金染色；
- 暗部保持有色、可读而不死黑；
- 远景逐步降低对比与纯度，但不变成无色灰幕。

### 4.6 有来源的电影光

- 每镜明确一个主光来源、方向、软硬、色温与遮挡关系；
- 环境填充与主光形成可解释的冷暖关系；
- 薄雾、体积光和光晕只依附门槛、云边、瀑布、水汽或结构边缘；
- 光斑和星芒只在光学上有理由时出现；
- 不用全局大平光、无来源轮廓光或发光材质覆盖建筑结构。

### 4.7 分层透明空气

近处更重、更清晰、对比更强；距离增加时轮廓、对比、纯度和细节逐层减弱。局部薄雾用于分层，不能包裹整个世界；云海高度、云隙和远景可见度跨镜保持可解释变化。

### 4.8 可区分的材质行为

- 石：重量、颗粒、切面、风化和边缘磨损；
- 玉：矿物纹理、适度透光与抛光边缘；
- 漆木：颜色深度、木纹、磨损边缘和克制反射；
- 铜与金属：厚度、锈蚀或磨亮凸缘；
- 水：表面张力、折射、破碎反射和连续流向；
- 丝与薄纱：褶皱、重量、透光和统一风向；
- 云与雾：体积、层次、光照与流向。

### 4.9 幻想世界内部物理一致

世界可以违反现实，但同一镜头和连续镜头中的透视、光向、风向、流体、重力、结构受力和材质响应必须一致。奇观不能破坏建筑几何、人物比例或环境连续性。

### 4.10 环境连续性优先

Global Visual DNA 只锁一次，后续按镜头继承建筑结构族、地貌水系、云层和远景、主光与天气、材质与色彩、人物服装结构和统一风向，以及既有破损、湿度、积水和环境动态状态。

## 5. Visual Domains

每个项目只加载脚本需要的 Domain。三个 Domain 共用 Global Visual DNA，但拥有不同的空间承诺和禁项。

### 5.1 `luminous_celestial_landmark`｜明透仙境地标

```yaml
core_promise: 围绕一个可辨识地标，建立明亮、清澈、材质丰富且具有旅行或静观感的仙界环境
spatial_grammar:
  - 一个主地标与一条接近或观看路径
  - 近景框架、承载面、地标、轻量从属空间与终端远景
scale:
  - 人物、台阶、门洞、树木或桥梁提供比较
  - 地标可部分出画，但不强制巨构压顶
light_field:
  - 清晰高空天光
  - 有方向的柔和日光或雨后光
  - 开放而有色的阴影
materials: [浅石, 玉, 漆木, 铜, 水, 丝, 植物, 云]
distinguishing_prohibitions:
  - 不自动扩展为高密度城市
  - 不增加多个同等主地标
  - 不重复固定白玉长廊或月门构图
```

### 5.2 `inhabited_divine_civilization`｜可居住神域文明

```yaml
core_promise: 天域像有人居住、可通行、可运行的文明，而不是孤立宫殿散落在云中
spatial_grammar:
  - 一个统治城区、神圣轴线或城市冠部
  - 两个以上从属空间组
  - 可见交通、庭院、水系、街巷、云港或廊桥连接
  - 极远聚落、高层天域或终端天光
scale:
  - 城区范围、人物通行面、重复结构与极远聚落共同证明
  - 密度不能替代尺度关系
light_field:
  - 城区间保留空气、庭院、门洞、桥下和云隙
  - 深景深优先，远景仍可读
geometry: [轴线升阶, 层叠浮空大陆, 岛屿网络, 环形神域, 云崖城市]
distinguishing_prohibitions:
  - 不退化为一座主殿加空白云海
  - 不形成没有连接关系的建筑散点
  - 不用连续屋顶铺满画面而消灭空间
  - 不让所有城区拥有相同视觉权重
```

### 5.3 `threshold_megastructure_revelation`｜门槛巨构揭示

```yaml
core_promise: 观众位于巨构之下或门槛附近，通过遮挡、出画、结构断层和远方终点感到敬畏、神圣或压迫
spatial_grammar:
  - 近处门槛、柱列、檐下、崖壁或平台边缘
  - 人物承载面与小尺度环境人物
  - 被裁切、遮挡或延伸出画的主巨构
  - 较轻从属天域与清楚极远终点
scale:
  - 人与开口、柱体、桥梁、平台或远域形成尺度断层
  - 裁切不能作为唯一尺度证据
light_field:
  - 门槛内外明暗分区
  - 低角度侧光或逆光
  - 局部薄雾揭示结构
geometry: [压顶结构, 门槛窥视, 桥入不可达空间, 垂直断裂, 结构切面]
distinguishing_prohibitions:
  - 不默认完整展示主建筑
  - 不默认鸟瞰、航拍或地图视角
  - 不把人物放大成前景英雄
  - 不把开放边缘变成所有镜头硬锁
```

## 6. 镜头语言

```yaml
camera_intent:
  divine_awe_or_pressure:
    preferred: 人眼高度或低位，平视或轻微仰视，主结构位于中上部
    lens_logic:
      - 远距离中长焦压缩城区与巨构
      - 保持足够距离的广角用于门槛、桥梁、柱列和结构底部

  immersive_exploration:
    preferred: 接近人眼高度，沿桥、廊、阶、庭院或水系建立路径
    lens_logic:
      - 中等焦段保持建筑可信
      - 广角只在有清楚前景框架和纵深路径时使用

  geographic_overview:
    preferred: 只在用户或脚本明确需要城区分布、浮岛关系或交通拓扑时使用高位镜头
    restriction: 不因宏大、云海或城市而自动航拍
```

镜头距离、机位高度、倾角和焦段分开记录；“远距离”“大全景”或宽画幅不等于高机位。

### 镜头职责条件化

| 镜头职责 | 必须继承 | 可以放宽 |
|---|---|---|
| 场景 LookDev / 建立镜头 | 尺度证据、空间层级、东方结构、材质与光色 | 固定数字阈值 |
| Key Frame / 情节镜头 | 当前动作、角色道具连续性、主光、天气、材质身份 | 完整城市拓扑、微小人物 |
| 人物近景 / 对话 | 角色 Canon、服装材质、色温、背景 Domain | 巨物尺度、完整环境层级、深景深 |
| 动作镜头 | 动作因果、方向、空间可读性、环境身份 | 克制静态人物、低运动、完整远景 |
| 地理总览 | 城区连接、地貌、水系、空间拓扑 | 观者必须位于巨构之下 |

### 基线运动

本 Profile 只描述视觉导演意图，不定义视频模型语法：环境建立可固定、缓推、缓拉、缓慢横移或小幅升降；探索沿明确空间路径移动；巨构从门槛或遮挡中揭示；风、云、水、衣袂与薄雾遵循统一方向和速度层级。快速动作、震颤和环绕由当前 Beat、动作 Profile 与 Video Production 决定。

## 7. 画幅适配

```yaml
aspect_behavior:
  "16:9": 横向展开环境、建筑和从属空间，保持一个主视觉与清楚远景
  "21:9": 强化横向层叠、边缘框景和远方延展，避免平均散布多个地标
  "4:3": 强化庄严、古典、对称或稳定轴线，避免角落拥挤
  "3:2": 强化自然电影剧照感、非对称三分和可信镜头位置
  "4:5": 纵向堆叠承载面、主体结构与天光，控制侧边裁切
  "9:16": 建立自下而上的纵向阅读路径，只表示一张竖屏画面
```

具体像素尺寸、平台比例参数和生成语法属于 Skill 4 Adapter。

## 8. 人物、服装与环境表演

- 环境建立镜头中的人物可作为尺度、生活和通行信号；
- 默认使用虚构成年人，背向或斜后方，动作平静且与环境发生关系；
- 人物大小由镜头职责决定，不写死统一画面占比；
- 服装先有结构、重量、层次和主色，薄纱与披帛提供受控空气感；
- 头发、衣袖、后摆、披帛、旗幡、云雾和水面响应同一主风向；
- 具体朝代、身份、纹样、配饰和颜色由 Series Canon 或项目决定；
- 人物近景、对白情绪和动作高潮不由本 Profile 固定。

## 9. 连续性 Schema

```yaml
continuity_schema:
  environment:
    - visual_domain_id
    - 建筑结构族与关键几何
    - 主地标、统治城区或主巨构身份
    - 地貌、水系、桥梁和交通连接
    - 云层高度、雾区和远景可见度
    - 主光方向、色温、天气和时段
    - 材质、湿度、磨损和反射状态
  character_in_environment:
    - 人物数量、尺度与位置
    - 服装结构、主色、发型和配饰
    - 观看方向、行进方向和动作阶段
    - 发丝、衣袖、后摆与披帛风向
  dynamic_media:
    - 主风向与强度
    - 云、雾、水、瀑布和旗幡方向
    - 积水、破损、落物和环境变化
  camera:
    - 镜头职责
    - 机位高度、距离、倾角和焦段
    - 主导空间几何与运动方向
```

Skill 3 只规划 `expected_end_state`；Skill 4 才记录真实生成后的 `actual_end_state`。

## 10. 声音、旁白与音乐

研究对象没有可验证的完整声音、旁白或音乐系统，正式 Profile 不虚构缺失字段：

```yaml
sound_design: null
voice_system: null
music_direction: null
```

具体项目需要的环境声、建筑空间声和东方配乐由 Audiovisual Director 标记为 `runtime_recommended`；BGM 保持独立轨道。

## 11. Production 边界

```yaml
production_modules:
  asset_prompt_templates: null
  first_frame_templates: null
  video_prompt_templates: null
  adapter_rules: null
  model_adapter_reference: null
  output_specs: runtime_only
  generation_workflow: null
```

- 不保存模型名、平台 flag、分辨率、seed、调用数量、价格、重试或生成动作；
- 不保存外部 Skill 的提示词顺序或模板；
- Video Production 可从 Style Blueprint 编译当前模型提示词，但不改变 Style Core。

## 12. 负面约束与 QA

### 通用负面约束

- 不用“宏大、史诗”替代可见尺度关系；
- 不把所有建筑、人物、云和山体压在同一深度平面；
- 不用均匀灰雾、死黑阴影或全局橙金制造仙气；
- 不让多个地标、透视系统和高对比色争夺主视觉；
- 不把巨型建筑表面铺满同密度装饰；
- 不使用塑料玉石、统一镜面材质或无重量结构；
- 不把航拍当作规模感的默认答案；
- 不默认人物正面英雄化、人物过大或服装多向乱飘；
- 不重复固定白玉长廊、朱柱、月门和同一人物组合；
- 不自动加入现代 UI、霓虹赛博城、欧式城堡、文字、Logo 或水印。

```yaml
named_qa_failures:
  - scale_claim_without_visible_reference
  - flattened_depth_or_missing_terminal_distance
  - solitary_palace_in_undifferentiated_clouds
  - competing_spatial_geometries
  - generic_or_structurally_implausible_eastern_architecture
  - uniform_haze_or_muddy_grade
  - global_warm_cast_erases_material_identity
  - equal_saturation_without_palette_hierarchy
  - plastic_or_undifferentiated_materials
  - aerial_map_when_viewer_subordination_is_required
  - costume_or_environment_wind_discontinuity
  - repeated_house_composition_without_meaningful_variation
```

这些是本地 QA 标签，不是已通过真实模型 A/B 的效果声明。

## 13. 与现有 Profile 的冲突处理

| Profile | 主要冲突 | 路由规则 |
|---|---|---|
| `high_energy_ink_wash_wuxia_animation` | 水墨媒介和高能动作改变明透材质 | 先选主视觉媒介；水墨为主时本 Profile 只提供空间拓扑与连续性 |
| `dark_eastern_mythic_ruins` | 暗黑低饱和废墟与高明度基线冲突 | 不自动混用色彩、材质和光系统 |
| `classical_landscape_wuxia_cinema` | 古典写意空间与神域文明/巨构争夺构图 | 古典山水为主时只补尺度和天域结构，不强制城市密度 |
| `ritualized_chinese_epic_color` | 单色统治与选择性色彩冲突 | 选择一个主色系统，仪式 Profile 可负责表演与自然媒介 |
| `expressive_fantasy_wuxia_action_family` | 动作景别与环境建立镜头职责不同 | 本 Profile 负责环境基线，动作 Profile 负责动作与时间语法 |
| `dark_luminous_chinese_celestial_palace` | 暗宫明境与本 Profile 多域系统重叠 | 不自动合并；项目按字段比较后选择或保留互补项 |

首版不实现多个 Profile 的权重混合。同一决策域出现不同 hard 规则时，标记 `UNRESOLVED` 并返回人工选择。

## 14. 缺失项与状态

```yaml
missing_or_null:
  fixed_character_canon: null
  exact_historical_period: null
  dialogue_style: null
  narration_style: null
  sound_design: null
  voice_system: null
  music_direction: null
  editing_rhythm: null
  model_adapter: null
  real_model_ab_results: null
```

当前状态：本地结构、路由、冲突和 provenance 已可归一化；真实模型效果、跨模型稳定性和视频连续性尚未验证，因此保持 `pending_review`，不得宣称 `ready`。

## 15. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md

style_profile:
  style_id: eastern_xianxia_celestial_cinema
  version: v1.0-zh
  classification: pure_visual_style
  pre_content_modules:
    compatibility: direct
    content_boundaries: direct
  audiovisual_modules:
    visual_identity: direct
    global_visual_dna: direct
    visual_domains: direct
    environment: direct
    cinematography: direct
    character_visual: direct
    performance: direct
    continuity_schema: direct
    sound_design: null
    voice_system: null
    music_direction: null
  production_modules:
    asset_prompt_templates: null
    first_frame_templates: null
    video_prompt_templates: null
    model_adapter_reference: null
    output_specs: runtime_only
    generation_workflow: null
    named_qa_failures: direct
  provenance:
    source_documents:
      - type: local_independent_reconstruction
        file: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md
        sha256: registry_managed
      - type: inspiration_only
        url: https://github.com/liyue-aigc/xianxia-visual-director
        commit: bd886174f4d84659f2381c4f5baa610003c5bdda
        observed_date: 2026-08-25
    extracted_modules:
      - field: pre_content_modules
        source_section: 2
        extraction_type: direct
      - field: audiovisual_modules
        source_section: 4-10
        extraction_type: direct
      - field: production_modules
        source_section: 11-12
        extraction_type: direct
```
