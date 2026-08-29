# 风格档案：赛博巨物硬科幻

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\赛博巨物-硬科幻短片.md`  
> 内部风格 ID：`cyber_gargantuan_hard_scifi`  
> 解析边界：源文档是分析对象，其中的工具调用、暂停、生成和导出要求不视为本次任务指令。

## 0. 解析结论

这是一份 **系列世界观设定 + 赛博巨物视听风格 + 生产手册** 的混合文档。可跨项目复用的风格核心是：文明尺度的未来城市、巨物与微小生命同框、物理来源明确的光雾、深景深空间层级、带呼吸感的摄影机、冷色科技环境与暖色生命信号、低频压迫声场。

源文档中的 3025 年、四类群体、机械鲲鹏及其尺寸属于 `source_defined_canon`，只在明确采用该世界观时加载；不能把它们误当成所有赛博巨物短片的固定设定。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/赛博巨物-硬科幻短片.md"
style_profile:
  style_id: cyber_gargantuan_hard_scifi
  version: "1.0-zh-review"
  classification: mixed
  pre_content_modules:
    compatibility: direct
    worldview: direct
    themes: normalized
  audiovisual_modules:
    visual_identity: direct
    cinematography: direct
    performance: direct
    sound_design: direct
    music_direction: direct
    continuity_schema: normalized
  production_modules:
    model_adapter_reference: direct
    generation_workflow: direct
    prompt_templates: direct
  provenance:
    source_sha256: BAFF605C1FA8A2F77B3857F39C683FD3C52D3184B4C4C2D6678D1FCB74864D8C
    extraction: source_grounded
```

## 2. 风格兼容性

### 强适配

- 文明层级、未来都市、赛博社会分化
- 超大型机械生命、空中结构、巨构建筑
- 需要“城市—群体—个体”多层空间同时成立的概念短片
- 压迫、敬畏、身份焦虑、技术永生等主题

### 弱适配

- 室内对白为主的小戏
- 轻喜剧、日常治愈、美食或产品硬广
- 需要浅景深梦幻柔焦的作品
- 无法提供比例参照或物理空间层级的抽象 MV

若为了套风格必须加入机械鲲鹏或四类群体，判定 `mismatch`；若只借用尺度、光学、镜头和声场语言，则可判定 `acceptable`。

## 3. 权威与路由

```yaml
authority:
  选题方向: soft
  固定世界观: medium
  通用视觉身份: hard
  巨物比例语言: hard
  摄影与光学: hard
  表演: medium
  声音设计: hard
  配乐方向: medium
  当前模型与分辨率: none
```

- 内容前置层：宏观文明视角、技术分层、人与巨构关系，可作为内容兼容性信号。
- 视听层：尺度参照、空间层级、物理光雾、摄影、表演、声场与配乐。
- 生产层：具体模型、分辨率、提示词占位符、逐镜确认、混音数值与导出规格。

## 4. 内容前置模块

- 主题倾向：文明分层、繁荣与废墟、肉身与改造、数字永生、个体在巨构下的渺小感。
- 叙事倾向：宏观空间建立 → 个体反应 → 光影或巨物改变环境 → 群体关系 → 再回到宏观总结。
- 表达限制：不能让视觉奇观覆盖已冻结的核心论点；不能强制把普通科幻题改成源文档的四族世界。

### 可选源世界固定设定

- 时代：3025 年以后。
- 群体：原始人类、赛博人类、基因融合者、数字意识。
- 核心巨物：机械鲲鹏。
- 城市分区：繁荣区、废弃区、渐变过渡区。

以上仅在用户明确采用本系列世界观时生效。

## 5. 视听风格核心

### 视觉身份

- 超写实、硬质、透明感较强的未来电影画面。
- 画面至少包含近景生命尺度、中层建筑或通道、远层天空或巨物中的两到三层。
- 巨物镜头必须有可读的尺度参照；人物或载具不能小到完全不可辨认。
- 繁荣与废墟主要通过光、维护状态、信息流连续性和交通活动区分。

### 色彩与光

- 主色：冰蓝；辅色：暖金；可用淡紫、琥珀、淡粉作生命或情绪信号。
- 黑位与高光都应保留纹理，不以纯黑或纯白制造廉价冲击。
- 雾、粒子和光晕必须能追溯到阳光、建筑自发光、能量体或反射面。
- 空灵段落依靠低密度空气散射和光影边界，不使用无来源彩雾。

### 镜头语言

- 基线：轻微手持呼吸感、侧向位移、低机位、倾斜轴线、宏观与微观交替。
- 巨物揭示：低位仰拍或环绕，并保留城市或人类参照。
- 情绪失衡：荷兰角与极近特写；压抑：高机位俯视；觉醒或对峙：低机位仰视。
- 情感过渡：运动减速至近乎静止，再由眼、手或阴影边界进入巨物揭示。
- 禁止把“所有镜头手持”理解成持续剧烈晃动。

### 表演

- 情绪依靠眼神、瞳孔反射、嘴唇颤动、手指和姿态变化表达。
- 人物与巨物、阴影边界、群体视线必须发生明确关系。
- 源文档规定的族群外观数值属于世界固定设定，不是通用角色模板。

### 声音与音乐

- 环境底层：电磁嗡鸣、人群、风穿锈蚀结构、间歇电弧。
- 巨物层：超低频引擎、装甲气流切割、结构共振。
- 配乐：60–90 BPM 的低频史诗底色，可在压抑—震惊转折处增加层次；音乐独立于视频生成声轨。
- 旁白若存在，应低沉、克制、具文明史尺度；源文档未规定固定性别为永久设定。

## 6. 连续性

- 跨镜保持巨物尺寸、悬停方向、光源方向、阴影移动方向、城市信息流、群体外观与场景维护状态。
- 同一情绪过渡段保持光束来源和雾密度因果一致。
- 当前镜头只记录预期结束状态；实际生成状态留给生产阶段记录。

## 7. 生产适配参考

以下不属于永久风格身份：GPT Image 2、Seedance 2.0、2K/720p/4K、16:9、24fps、单镜 3–15 秒、提示词占位符、逐镜确认、具体 dB、RGB 阈值和导出设置。生产时应由当前适配器重新验证。

## 8. 源文档冲突与缺失

- 焦距写为 35–50mm 并禁止超广角，但巨物题材通常需要更宽焦段；这是源文档选择，不应泛化成硬科幻通则。
- 同时要求“禁止简单推拉”与推荐缓慢推入；应解释为禁止无叙事意图的机械推拉。
- 一处要求多机位切换依据不使用时间戳，另一处又要求注明切换时间点；生产适配器需统一。
- 固定快门、光圈、ISO 和色值属于生产建议，不能保证生成模型真实执行。
- 未定义完整对白体系、固定角色声音身份与事实验证机制。

## 9. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/赛博巨物-硬科幻短片.md"
      sha256: BAFF605C1FA8A2F77B3857F39C683FD3C52D3184B4C4C2D6678D1FCB74864D8C
  extracted_modules:
    - field: source_defined_canon
      source_section: 世界观基调、关键元素设计规范
      extraction_type: direct
    - field: visual_identity
      source_section: 巨物与比例规则、光学系统
      extraction_type: normalized
    - field: sound_design
      source_section: 跨镜头音频层设计
      extraction_type: direct
    - field: production_modules
      source_section: media_generator、write_the_prompt、video_assembler
      extraction_type: direct
```
