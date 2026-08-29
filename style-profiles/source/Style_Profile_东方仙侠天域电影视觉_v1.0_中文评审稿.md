# Style Profile：东方仙侠天域电影视觉

> **版本**：v1.0-zh-review  
> **内部风格 ID**：`eastern_xianxia_celestial_cinema`  
> **分类**：`pure_visual_style`  
> **库状态**：`pending_review`  
> **实施状态**：人工审阅已通过；Phase C 正式 source、normalized JSON 与 registry 条目已创建，状态保持 `pending_review`  
> **研究基线**：[`liyue-aigc/xianxia-visual-director@bd886174`](https://github.com/liyue-aigc/xianxia-visual-director/commit/bd886174f4d84659f2381c4f5baa610003c5bdda)  
> **重建原则**：学习可观察的视觉规律与镜头语言，以 AI 自媒体现有 Schema、权限和中文表达独立重建；外部仓库仅作 `inspiration_only` 研究来源。

---

## 0. 评审结论

这是一份**环境与空间优先的东方仙侠电影视觉 Profile**。它不把风格等同于白玉宫殿、云海、朱柱或某一套固定构图，而是用十项稳定的 Global Visual DNA 和三个按场景职责启用的 Visual Domains，解决以下视觉问题：

- “宏大、史诗”只有形容词，没有画面内尺度证据；
- 仙界只有一座孤殿漂在云里，没有可居住、可通行的文明空间；
- 灰雾、全局橙金和平均高饱和吞掉材质与远景；
- 中式装饰贴在无结构巨物上，形成主题乐园或通用 CGI；
- 为了展示全貌自动使用航拍，削弱观众置身巨构之下的敬畏；
- 人物、衣袂、发丝、云雾和光向跨镜不一致。

它负责**环境尺度、空间拓扑、建筑语言、光色材质、人物作为环境信号时的视觉规则和连续性锁**。它不拥有 Topic Thesis、角色身份、剧情动作、历史事实、声音、旁白、音乐、模型语法或生成流程。

---

## 1. 机器摘要

```yaml
review_artifact:
  phase: phase_c_registered
  review_approved: true
  formal_library_entry_exists: true
  library_status: pending_review
  intended_source_file: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md
  intended_normalized_file: eastern_xianxia_celestial_cinema.v1.0-zh.json
  source_sha256: AFEB9DDC77E9997DEEF150AB9CB28DE7D174ADB8AB028991E5EE7985BD6391E7

style_profile:
  style_id: eastern_xianxia_celestial_cinema
  version: 1.0-zh-review
  classification: pure_visual_style
  pre_content_modules:
    compatibility: independent_reconstruction
    content_boundaries: independent_reconstruction
  audiovisual_modules:
    visual_identity: independent_reconstruction
    global_visual_dna: independent_reconstruction
    visual_domains: independent_reconstruction
    environment: independent_reconstruction
    cinematography: independent_reconstruction
    performance: independent_reconstruction
    continuity_schema: independent_reconstruction
    sound_design: null
    voice_system: null
    music_direction: null
  production_modules:
    adapter_rules: null
    output_specs: runtime_only
    named_qa_failures: independent_reconstruction
  provenance:
    source_type: local_independent_reconstruction
    inspiration_only_commit: bd886174f4d84659f2381c4f5baa610003c5bdda
```

---

## 2. 分类与适配范围

### 2.1 分类判断

```yaml
classification:
  primary: pure_visual_style
  secondary: []
  full_series_canon: false

flags:
  has_topic_direction: false
  has_story_direction: false
  has_character_archetypes: false
  has_visual_system: true
  has_camera_language: true
  has_performance_system: conditional_environment_only
  has_sound_system: false
  has_voice_system: false
  has_music_system: false
  has_prompt_templates: false
  has_model_specific_rules: false
```

### 2.2 强适配

- 东方仙侠、东方神话、天界文明、神域城市和悬空建筑；
- 需要敬畏、神圣、辽阔、明透或巨构压迫的环境型镜头；
- 天门、仙城、云港、藏经阁、观星台、神树书阁、天河、悬空宫阙等世界观空间；
- 需要在 16:9 与 9:16 中保持同一视觉身份的短视频项目；
- 需要环境基线支持后续多镜头连续性的项目。

### 2.3 条件适配

- 强动作项目：本 Profile 提供空间与环境基底，动作语法由独立动作 Profile 或当前 Beat 决定；
- 人物特写或对白：只继承色温、材质、服装结构和背景 Domain 身份，不强制微小人物或完整环境层级；
- 地理总览：允许明确要求的高位视角，不强制观者低位；
- 历史或经典文本题材：建筑、服饰、器物和礼制仍由事实来源或 Series Canon 决定；
- 暗黑或水墨媒介：必须先确定主视觉身份，不能把多个色彩和材质系统平均混合。

### 2.4 弱适配

- 现代写实都市、纯工业科幻、产品静物、室内口播和极简信息图；
- 严格历史复原但没有仙侠转译需求的项目；
- 只需要人物表演、看不见环境身份的近景序列；
- 需要全片持续手持、混乱透视或刻意低清脏污影像的项目。

---

## 3. 权威级与覆盖顺序

视觉、声音和 BGM 的现有优先级继续是：

```text
current_user_override > Series Canon > selected Style Profile > runtime_recommended
```

本 Profile 内部按决策域分权：

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
    - 角色身份、外观与当前动作
    - 历史、地理、器物与礼制事实
    - 建筑功能与人物安全语义
    - 用户明确机位、焦段、构图和画幅
    - 当前 Beat 的景别、动作、时长与运动

  runtime_only:
    - 图像或视频模型语法
    - 参考图绑定方法
    - 像素尺寸、分辨率、seed 与平台参数
    - 调用数量、成本、重试和停止条件
```

若新加载的 Style 规则会改变已冻结的脚本语义，输出 `UPSTREAM-CONSTRAINT-LATE` 或 `FLAG-CONFLICT`，不静默重写脚本。

---

## 4. Global Visual DNA

### 4.1 关系化巨物尺度

“宏大”必须由可见关系成立。环境建立镜头应从以下证据中选择足够支持当前构图的组合：

- 已知大小的人与门洞、柱列、平台、桥梁或树木直接比较；
- 结构延伸出画面或跨越云层、峡谷、水系和城区；
- 重复构件随纵深有规律递减；
- 近处巨型框架、人物承载面、主结构、从属空间和极远终点形成尺度断层；
- 城市通过连通城区、交通、庭院、水系和极远聚落证明文明范围。

具体证据数量和比例按镜头决定，不把研究来源中的数字变成逐像素硬阈值。

### 4.2 单一主导空间几何

每个环境镜头只选择一个主导阅读系统：

- 单点纵深；
- 对称轴；
- 对角线引导；
- 框景揭示；
- 曲线流动；
- 纵向上升；
- 横向层叠。

辅助元素必须服从主几何，不同时制造多个消失点、多个等强奇观或互相冲突的阅读路径。

### 4.3 结构可信的东方幻想建筑

- 先建立梁、柱、屋面、基座、平台厚度、连接、承重和人可通行关系；
- 再把飞檐、斗拱、纹样、漆木、矿物色和金属边缘集中在可读区域；
- 巨型表面保持简洁、安静、有重量，不把所有尺度都铺满同密度装饰；
- 允许悬浮大陆、云上基础、天河和超现实结构，但透视、重力、材质与光线必须内部一致；
- 东方识别来自空间秩序和构造语言，不是欧式城堡、现代摩天楼或混凝土巨物贴一层中式屋顶。

### 4.4 携带空间信息的开放区域

天空、门洞、庭院、水面、云隙、桥下、平台间空隙和远方天光用于：

- 显示层级和距离；
- 暴露悬空结构和高度；
- 提供轮廓、光值和云层变化；
- 让密集城市仍有可读交通和空间间隔。

开放区域不是空白画布，也不是均匀灰雾。其占比由构图和叙事需要决定。

### 4.5 高明度与选择性色彩

- 大面积天空、云、水、浅石、玉和远景使用高明度、中低纯度基底；
- 朱红、矿物绿、群青、衣饰或窄幅金属高光只在少量关键区域提高纯度；
- 白石、玉、云和皮肤保持材质区别，不被统一橙金染色；
- 暗部保持蓝灰、青灰、紫灰或材质本色，可读而不死黑；
- 远景逐步降低对比和纯度，但不能退化成无色灰幕。

### 4.6 有来源的电影光

- 每镜明确一个主光来源、方向、软硬、色温和遮挡关系；
- 环境填充与主光形成可解释的冷暖关系；
- 薄雾、体积光和光晕只依附门槛、云边、瀑布、水汽或结构边缘；
- 光斑和星芒只在光学上有理由时出现，不作为装饰层；
- 不用全局大平光、无来源轮廓光或发光材质覆盖建筑结构。

### 4.7 分层透明空气

- 近处更重、更清晰、对比更强、细节更多；
- 距离增加时轮廓、对比、纯度和细节逐层减弱；
- 局部薄雾可以分层，但不能包裹整个世界；
- 云海高度、云隙方向和远景可见度跨连续镜头保持可解释变化。

### 4.8 可区分的材质行为

- 石：重量、颗粒、切面、风化和边缘磨损；
- 玉：矿物纹理、适度透光、抛光边缘，不是统一塑料；
- 漆木：颜色深度、木纹、磨损边缘和克制反射；
- 铜与金属：厚度、锈蚀或磨亮凸缘，不是满面金色涂层；
- 水：表面张力、折射、反射破碎和连续流向；
- 丝与薄纱：褶皱、重量、透光和统一风向；
- 云与雾：有体积、层次、光照和流向，不是平面烟雾贴图。

### 4.9 幻想世界内部物理一致

世界可以违反现实，但同一镜头和连续镜头中的透视、光向、风向、流体、重力、结构受力和材质响应必须一致。奇观不能以破坏建筑几何、人物比例或环境连续性为代价。

### 4.10 环境连续性优先

Global Visual DNA 只锁一次，后续按镜头继承：

- 建筑结构族与关键几何；
- 地貌、水系、云层高度和远景锚点；
- 主光方向、天气和空气透明度；
- 材质家族与色彩层级；
- 人物服装结构、发丝、披帛和统一风向；
- 既有破损、湿度、积水、道具和环境动态状态。

---

## 5. Visual Domains

一个项目只加载脚本真正需要的 Domain。三个 Domain 共用 Global Visual DNA，但拥有不同的空间承诺与禁项。

### 5.1 `luminous_celestial_landmark`｜明透仙境地标

**核心承诺**：围绕一个可辨识的仙界地点或地标，建立明亮、清澈、材质丰富且具有旅行或静观感的环境。

```yaml
visual_domain:
  id: luminous_celestial_landmark
  spatial_grammar:
    - 一个主地标
    - 一条主导接近或观看路径
    - 近景框架、承载面、地标、轻量从属空间与终端远景
  scale:
    - 人物、台阶、门洞、树木或桥梁提供可读比较
    - 地标可部分出画，但不强制巨构压顶
  light_field:
    - 清晰高空天光
    - 有方向的柔和日光或雨后光
    - 开放而有色的阴影
  geometry:
    - 单体仙阁、天门、祭台、神树书阁、观星台或悬空藏经阁
  materials:
    - 浅石、玉、漆木、铜、水、丝、植物与云
  distinguishing_prohibitions:
    - 不自动扩展为高密度城市
    - 不增加多个同等主地标
    - 不重复固定白玉长廊或月门构图
```

### 5.2 `inhabited_divine_civilization`｜可居住神域文明

**核心承诺**：天域像一个有人居住、可通行、可运行的文明，而不是孤立宫殿散落在云中。

```yaml
visual_domain:
  id: inhabited_divine_civilization
  spatial_grammar:
    - 一个统治城区、神圣轴线或城市冠部
    - 两个以上从属空间组
    - 可见交通、庭院、水系、街巷、云港或廊桥连接
    - 极远聚落、高层天域或终端天光
  scale:
    - 城区范围、人物通行面、重复结构和极远聚落共同证明
    - 密度不能替代尺度关系
  light_field:
    - 城区间保持空气、庭院、门洞、桥下和云隙
    - 深景深优先，远景仍可读
  geometry:
    - 轴线升阶、层叠浮空大陆、岛屿网络、环形神域或云崖城市
  materials:
    - 同一建筑家族内保持材质层级和局部装饰规则
  distinguishing_prohibitions:
    - 不退化为一座主殿加空白云海
    - 不形成没有连接关系的建筑散点
    - 不用连续屋顶铺满画面而消灭空间
    - 不让所有城区拥有相同对比、细节和视觉权重
```

### 5.3 `threshold_megastructure_revelation`｜门槛巨构揭示

**核心承诺**：观众位于巨构之下或门槛附近，通过遮挡、出画、结构断层和远方终点感到敬畏、神圣或压迫。

```yaml
visual_domain:
  id: threshold_megastructure_revelation
  spatial_grammar:
    - 近处门槛、柱列、檐下、崖壁或平台边缘
    - 人物承载面与小尺度环境人物
    - 被裁切、遮挡或延伸出画的主巨构
    - 较轻的从属天域
    - 清楚的极远终点
  scale:
    - 人与开口、柱体、桥梁、平台或远域形成尺度断层
    - 裁切本身不能作为唯一尺度证据
  light_field:
    - 门槛内外明暗分区
    - 低角度侧光或逆光
    - 局部薄雾揭示结构，不吞没建筑
  geometry:
    - 压顶结构、门槛窥视、桥入不可达空间、垂直断裂或结构切面
  materials:
    - 巨型表面简洁厚重，细节集中在人可读阈值
  distinguishing_prohibitions:
    - 不默认完整展示主建筑
    - 不默认鸟瞰、航拍或地图视角
    - 不把人物放大成前景英雄
    - 不把开放边缘变成所有镜头无条件硬锁
```

---

## 6. 镜头语言

### 6.1 镜头意图优先于镜头标签

```yaml
camera_intent:
  divine_awe_or_pressure:
    preferred: 人眼高度或低位，平视或轻微仰视，主结构位于中上部
    lens_logic:
      - 远距离中长焦压缩城区与巨构
      - 保持足够距离的广角用于门槛、桥梁、柱列和结构底部

  immersive_exploration:
    preferred: 接近人眼高度，沿桥、廊、阶、庭院或水系建立运动路径
    lens_logic:
      - 中等焦段保持建筑可信
      - 广角只在有清楚前景框架和纵深路径时使用

  geographic_overview:
    preferred: 只有用户或脚本明确需要城区分布、浮岛关系或交通拓扑时使用高位镜头
    restriction: 不因画面宏大、含云海或含城市而自动航拍
```

镜头距离、机位高度、倾角和焦段必须分开记录；“远距离”“大全景”或宽画幅不等于高机位。

### 6.2 景别职责条件化

| 镜头职责 | 必须继承 | 可以放宽 |
|---|---|---|
| 场景 LookDev / 建立镜头 | 尺度证据、空间层级、东方结构、材质与光色层级 | 固定数字阈值 |
| Key Frame / 情节镜头 | 当前动作、角色与道具连续性、主光、天气、材质身份 | 完整城市拓扑、微小人物 |
| 人物近景 / 对话 | 角色 Canon、服装材质、色温、背景 Domain 特征 | 巨物尺度证明、完整环境层级、深景深 |
| 动作镜头 | 动作因果、方向、空间可读性、环境身份 | 克制静态人物、低运动、完整远景 |
| 地理总览 | 城区连接、地貌、水系、空间拓扑 | 观者必须位于巨构之下的情绪规则 |

### 6.3 基线运动

本 Profile 不定义视频模型动作语法。视觉运动只描述导演意图：

- 环境建立：固定、缓推、缓拉、缓慢横移或小幅升降；
- 探索：沿明确空间路径移动，避免无目的环绕；
- 巨构揭示：从门槛、遮挡或低位承载面揭示主结构；
- 风、云、水、衣袂和薄雾遵循统一方向与速度层级；
- 当前 Beat 若需要快速动作、震颤或环绕，由动作 Profile 与 Video Production 决定。

---

## 7. 画幅适配

画幅改变阅读路径，不改变 Style Core，也不推断图片数量。

```yaml
aspect_behavior:
  "16:9": 横向展开环境、建筑与从属空间；保持一个主视觉和清楚远景
  "21:9": 强化横向层叠、边缘框景和远方延展；避免平均散布多个地标
  "4:3": 强化庄严、古典、对称或稳定轴线；避免角落拥挤
  "3:2": 强化自然电影剧照感、非对称三分和可信镜头位置
  "4:5": 纵向堆叠人物承载面、主体结构和天光；控制侧边裁切
  "9:16": 建立自下而上的纵向阅读路径；只表示一张竖屏画面，不推断九宫格或系列图
```

具体像素尺寸、平台比例参数和生成语法属于 Skill 4 Adapter。

---

## 8. 人物、服装与环境表演

### 8.1 环境人物

- 在建立镜头中，人物可作为尺度、生活和通行信号；
- 默认使用虚构成年人，背向或斜后方，动作平静且与环境发生关系；
- 人物大小由镜头职责决定，不写死统一画面占比；
- 城市活动可增加远方人物，但不能变成无身份黑色剪影铺满空间。

### 8.2 仙衣语言

- 服装先有可读的结构、重量、层次和主色；
- 薄纱、披帛和长衣提供受控的空气感，不遮挡人物轮廓和通行关系；
- 头发、衣袖、后摆、披帛、旗幡、云雾和水面响应同一主风向；
- 具体朝代、身份、纹样、配饰和颜色由 Series Canon 或当前项目决定。

### 8.3 表演边界

环境人物以观看、行走、停驻、登阶、交谈或操作既有设施等低复杂度动作证明世界正在运行。人物近景、对白情绪和动作高潮不由本 Profile 固定。

---

## 9. 连续性 Schema

```yaml
continuity_schema:
  environment:
    - visual_domain_id
    - 建筑结构族与关键几何
    - 主地标、统治城区或主巨构身份
    - 地貌、水系、桥梁和交通连接
    - 云层高度、云隙、雾区与远景可见度
    - 主光方向、色温、天气和时段
    - 材质家族、湿度、磨损和反射状态

  character_in_environment:
    - 人物数量、尺度与位置
    - 服装结构、主色、发型和配饰
    - 观看方向、行进方向和动作阶段
    - 发丝、衣袖、后摆与披帛风向

  dynamic_media:
    - 主风向与强度
    - 云、雾、水、瀑布和旗幡方向
    - 既有积水、破损、落物和环境变化

  camera:
    - 镜头职责
    - 机位高度、距离、倾角和焦段
    - 主导空间几何与运动方向
```

Skill 3 只规划 `expected_end_state`；Skill 4 才能记录真实生成后的 `actual_end_state`。

---

## 10. 负面约束与命名失败

### 10.1 通用负面约束

- 不用“宏大、史诗”替代可见尺度关系；
- 不把所有建筑、人物、云和山体压在同一深度平面；
- 不用均匀灰雾、死黑阴影或全局橙金制造仙气；
- 不让多个地标、透视系统和高对比色同时争夺主视觉；
- 不把巨型建筑表面铺满同密度装饰；
- 不使用塑料玉石、统一镜面材质或无重量结构；
- 不把航拍当作规模感的默认答案；
- 不在环境镜头中默认人物正面英雄化、人物过大或服装多向乱飘；
- 不重复固定白玉长廊、朱柱、月门和同一人物组合来冒充风格稳定；
- 不自动加入现代 UI、霓虹赛博城、欧式城堡、文字、Logo 或水印。

### 10.2 `named_qa_failures`

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

这些是本地 QA 标签，不等于已经通过真实模型 A/B 验证。

---

## 11. 声音、旁白与音乐

研究对象主要定义单张环境视觉和图片提示词，没有可验证的完整声音、旁白或音乐系统。因此：

```yaml
sound_design:
  authority: none
  value: null

voice_system:
  authority: none
  value: null

music_direction:
  authority: none
  value: null
```

具体项目若需要风、水、城市、衣料、建筑空间声或东方配乐，由 Audiovisual Director 根据 Frozen Script 与当前 Domain 生成 `runtime_recommended` 方案，不能写成来源硬规则；BGM 继续保持独立轨道。

---

## 12. Production 边界

```yaml
production_modules:
  asset_prompt_templates: null
  first_frame_templates: null
  video_prompt_templates: null
  adapter_rules: null
  model_adapter_reference: null
  output_specs: runtime_only
  generation_workflow: null
  named_qa_failures: source_profile_defined
```

- 不保存模型名、平台 flag、分辨率、seed、调用数量、价格、重试或生成动作；
- 不复制外部 Skill 的提示词顺序或模板；
- Video Production 可从 Style Blueprint 编译当前模型提示词，但不改变永久 Style Core；
- Phase B 不输出 `主角`、`场景`、`Key Frame` 可执行提示词，也不调用任何模型。

---

## 13. 与现有 Profile 的冲突矩阵

| 现有 Profile | 重叠域 | 主要冲突 | 建议路由 |
|---|---|---|---|
| `high_energy_ink_wash_wuxia_animation` | 东方环境、山水、人物与动作 | 水墨媒介和高能动作会改变明透材质与环境镜头 | 先选主视觉媒介；若水墨为主，本 Profile 仅提供空间拓扑与连续性 |
| `dark_eastern_mythic_ruins` | 东方巨物、神话、低机位与空间压迫 | 暗黑低饱和废墟与本 Profile 高明度明透基线冲突 | 不自动混用色彩、材质和光系统；按项目选择一个主环境身份 |
| `classical_landscape_wuxia_cinema` | 山水留白、框景、人物点景 | 古典写意三层空间与神域文明/巨构域可能争夺构图 | 古典山水作为主媒介时，本 Profile 只补可见尺度和天域结构，不强制城市密度 |
| `ritualized_chinese_epic_color` | 东方建筑、史诗尺度、强构图 | 单一主色统治与本 Profile 高明度选择性色彩冲突 | 选择一个主色系统；仪式 Profile 可负责表演与自然媒介 |
| `expressive_fantasy_wuxia_action_family` | 奇幻武侠空间和动作镜头 | 动作景别与环境建立镜头职责不同 | 本 Profile 负责环境基线，动作 Profile 负责动作与时间语法 |
| `dark_luminous_chinese_celestial_palace` | 仙宫、巨构、低运动、环境人物 | 暗宫明境与三层空间规则和本 Profile 明透多域系统部分重叠 | 不自动合并；具体项目比较后选一个环境 Profile，或只保留互补字段 |

首版不实现多个 Profile 的权重混合。若两个 Profile 在同一决策域给出不同 hard 规则，标记 `UNRESOLVED` 并返回人工选择。

---

## 14. 来源映射与 provenance

### 14.1 研究来源

- [README](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/README.md)
- [SKILL.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/SKILL.md)
- [visual-dna.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/visual-dna.md)
- [xianxia-master-rules.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/xianxia-master-rules.md)
- [aspect-ratios.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/aspect-ratios.md)
- [composition-color-light.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/composition-color-light.md)
- [celestial-realm-route.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/celestial-realm-route.md)
- [eastern-sky-megastructure-style.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/eastern-sky-megastructure-style.md)
- [celestial-grand-realm-canon.md](https://github.com/liyue-aigc/xianxia-visual-director/blob/bd886174f4d84659f2381c4f5baa610003c5bdda/xianxia-visual-director/references/celestial-grand-realm-canon.md)

### 14.2 字段映射

| 本地字段 | 研究线索 | 本地处理 |
|---|---|---|
| `global_visual_dna` | 尺度、空间、建筑、色彩、光线、空气、材质 | 独立重组为十项跨视频视觉规则 |
| `visual_domains` | 地标、聚居天域、苍穹巨构和独立原典路由 | 重组为三个首版 Domain；安静大境不在首版单列 |
| `cinematography` | 构图、镜头意图、焦段与画幅适配 | 改为按镜头职责条件启用 |
| `performance` | 环境人物、仙衣和风向 | 仅保留环境人物与连续性，不拥有近景表演 |
| `continuity_schema` | 人物、服装、材质、天气、光向和环境状态 | 扩展为视频可继承字段，不记录生成结果 |
| `named_qa_failures` | 上游失败修正与审计清单 | 独立转写为本地 QA 标签 |
| 声音、旁白、音乐 | 来源缺乏完整可验证系统 | 保持 `null` |
| 模型、模板与生成流程 | 外部 Skill 的产品行为 | 不进入本 Profile |

### 14.3 拟议 provenance

```yaml
provenance:
  source_documents:
    - type: local_independent_reconstruction
      file: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md
      sha256: AFEB9DDC77E9997DEEF150AB9CB28DE7D174ADB8AB028991E5EE7985BD6391E7
    - type: inspiration_only
      url: https://github.com/liyue-aigc/xianxia-visual-director
      commit: bd886174f4d84659f2381c4f5baa610003c5bdda
      observed_date: 2026-08-25

  extracted_modules:
    - field: pre_content_modules
      extraction_type: inferred_structure_only
    - field: audiovisual_modules
      extraction_type: inferred_structure_only
    - field: production_modules
      extraction_type: inferred_structure_only

  examples_are_canon: false
  external_runtime_dependency: false
```

---

## 15. 缺失项、风险与待决问题

### 15.1 缺失项

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

### 15.2 当前风险

- 研究对象以单张环境图为主，视频连续性字段属于本地结构化扩展，尚未经过真实视频验证；
- 尺度、空气、人物和开放边缘不应恢复为所有镜头固定数字硬锁；
- 三个 Domain 若同时启用，会产生提示词膨胀和构图竞争；每个项目应只加载实际需要的 Domain；
- 现有 `dark_luminous_chinese_celestial_palace` 仍处于 `pending_normalization`，正式注册前应做一次字段级重复度复核；
- 当前没有真实模型 A/B，不能宣称本 Profile 已减少返工或提高成片质量。

### 15.3 人工审阅决议

1. 采用 `东方仙侠天域电影视觉 / eastern_xianxia_celestial_cinema`；
2. 首版只保留三个 Visual Domains；
3. 低机位、微小人物、深景深、开放边缘和巨构裁切维持条件规则；
4. 声音、旁白、音乐和剪辑节奏保持 `null`；
5. 批准 Phase C 正式入库，但库状态保持 `pending_review`。

---

## 16. Phase C 机器结构快照

以下结构已经落实到正式 source、normalized JSON 和 registry 条目；权威机器文件以正式入库版本为准：

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md

style_profile:
  style_id: eastern_xianxia_celestial_cinema
  version: 1.0-zh
  classification: pure_visual_style

  pre_content_modules:
    compatibility:
      authority: medium
      preferred:
        - 东方仙侠环境与世界观展示
        - 神域城市、悬空宫阙、天门和天域文明
      conditional:
        - 强动作、人物近景、地理总览和历史题材
    content_boundaries:
      authority: hard
      value: 不拥有 Topic Thesis、角色 Canon、事实、剧情动作或对白

  audiovisual_modules:
    visual_identity:
      authority: hard
      value: 关系化巨物尺度、结构可信的东方幻想建筑、高明度选择性色彩、有来源光线、透明分层空气和可区分材质
    global_visual_dna:
      authority: hard
      value:
        - 关系化巨物尺度
        - 单一主导空间几何
        - 结构可信的东方幻想建筑
        - 携带空间信息的开放区域
        - 高明度与选择性色彩
        - 有来源的电影光
        - 分层透明空气
        - 可区分的材质行为
        - 幻想世界内部物理一致
        - 环境连续性优先
    visual_domains:
      authority: hard_after_selection
      value:
        - luminous_celestial_landmark
        - inhabited_divine_civilization
        - threshold_megastructure_revelation
    environment:
      authority: high
      value: 按选定 Domain 组织空间拓扑、建筑结构、空气和尺度证据
    cinematography:
      authority: high
      value: 镜头意图决定机位、距离、倾角和焦段；人物近景、动作与总览按职责放宽环境规则
    performance:
      authority: conditional
      value: 环境人物动作克制，人物、服装与环境微动遵循统一风向
    sound_design:
      authority: none
      value: null
    voice_system:
      authority: none
      value: null
    music_direction:
      authority: none
      value: null
    continuity_schema:
      authority: hard
      track:
        - visual_domain_id
        - 建筑结构与关键几何
        - 地貌、水系、交通和远景锚点
        - 云层、雾区、天气、光向和时段
        - 材质、湿度、磨损和反射状态
        - 人物位置、服装结构、动作阶段和风向

  production_modules:
    asset_prompt_templates: null
    first_frame_templates: null
    video_prompt_templates: null
    model_adapter_reference: null
    output_specs: runtime_only
    generation_workflow: null
    named_qa_failures:
      - scale_claim_without_visible_reference
      - flattened_depth_or_missing_terminal_distance
      - solitary_palace_in_undifferentiated_clouds
      - generic_or_structurally_implausible_eastern_architecture
      - uniform_haze_or_muddy_grade
      - global_warm_cast_erases_material_identity
      - plastic_or_undifferentiated_materials
      - aerial_map_when_viewer_subordination_is_required
      - costume_or_environment_wind_discontinuity

  provenance:
    source_documents:
      - type: local_independent_reconstruction
        file: Style_Profile_东方仙侠天域电影视觉_v1.0_中文解析.md
        sha256: AFEB9DDC77E9997DEEF150AB9CB28DE7D174ADB8AB028991E5EE7985BD6391E7
      - type: inspiration_only
        url: https://github.com/liyue-aigc/xianxia-visual-director
        commit: bd886174f4d84659f2381c4f5baa610003c5bdda
        observed_date: 2026-08-25
    extracted_modules:
      - field: pre_content_modules
        extraction_type: inferred_structure_only
      - field: audiovisual_modules
        extraction_type: inferred_structure_only
      - field: production_modules
        extraction_type: inferred_structure_only
```

---

## 17. Phase C 停止状态

```yaml
phase_b_status:
  review_draft_created: true
  review_approved: true
phase_c_status:
  source_created: true
  normalized_json_created: true
  registry_updated: true
  registry_status: pending_review
  source_sha256: AFEB9DDC77E9997DEEF150AB9CB28DE7D174ADB8AB028991E5EE7985BD6391E7
  profile_fully_synced_to_plugin: false
  source_present_in_plugin_due_concurrent_sync: true
  plugin_reinstalled_for_phase_c: false
  media_generated: false
  next_gate: phase_d_sync_or_project_lookdev
```
