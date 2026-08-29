# Style Profile：超写实未来科幻风格族

> **版本**：v1.0-zh  
> **源文档**：`未来科幻真人电影.md`  
> **内部风格 ID**：`photoreal_future_scifi_family`  
> **解析原则**：该文档不是单一风格，而是四个可选视觉域加一个默认基线；运行时只加载一个域，禁止把冲突的光线、材质和介质全文叠加。

---

## 0. 解析结论

该文档应归类为 **超写实真人科幻风格族 + 资产连续性规范 + 生产手册**。共同风格核心是：可信物理材质、有来源的电影光线、受控饱和度、清楚空间尺度、真人表演和非赛博朋克基线。

四个域分别是：硬核深空探索、史诗太空歌剧、废土遗迹科幻、异星有机生态。它们共享“真实、克制、物理可信”，但色彩、材质、空间和环境介质不同，必须单选或由剧情显式分域。

## 1. 分类与兼容性

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - series_bible
    - production_playbook
  full_series_canon: false
```

### 强适配

- 未来探索、文明遗迹、生存困境、异星生态和技术伦理
- 人物与环境关系明确、需要真实材质与空间逻辑的短片
- 可按段落稳定维护人物、场景、光源和物理介质的项目

### 弱适配

- 以霓虹城市、赛博义体、全息界面为核心卖点的赛博朋克
- 纯抽象视觉、卡通科幻、游戏 CG 炫技或高饱和合成器波
- 世界观逻辑和人物关系尚未确认，却要求直接生成复杂场面的项目

## 2. 共同视觉基线

- 真人电影感与照片级可信材质
- 真实皮肤、织物、金属、玻璃、石材、尘土、水汽和环境反射
- 所有光源有明确来源，避免无来源彩色泛光
- 深黑位、受控饱和度、清晰叙事空间
- 科幻感来自结构、功能、尺度、材料和环境，而非默认霓虹

## 3. 四个视觉域

### 硬核深空探索

- 航空工业结构、可维护舱段、仪表和实用点光源
- 磨损钛合金、高反光宇航服、真实反射与失重微尘
- 冷色高反差、幽闭、低噪、压迫

### 史诗太空歌剧

- 极简与粗野主义巨型建筑、负空间、严格轴线与几何构图
- 异星自然光、庄严阴影、风化石材、哑光厚重金属和防沙织物
- 肃穆、静默、低饱和的史诗尺度

### 废土遗迹科幻

- 黄沙、植被、时间和天气侵蚀的科技遗迹
- 刺眼日光、沙尘漫反射、锈蚀钢铁、磨损皮革和干裂表面
- 去饱和暖黄、土褐、灰色，苍茫而悲壮

### 异星有机生态

- 有内部规律的有机建筑、植物、真菌和湿润生态
- 黏滑组织、半透明叶脉、水滴、角质鳞片与折射
- 局部柔和且有生物来源的发光，神秘、危险但有生命力

## 4. 上游内容与角色关系

- 泛化“科幻电影”需求不自动选择具体域，使用共同默认基线。
- 先明确主角身份、核心事件、世界观逻辑、人物关系、共同目标和冲突。
- 开场可用冲突、异常或悬念建立钩子；是否反转由当前故事决定。
- 视觉域不得覆盖用户已确认的人物、场景和世界观事实。

## 5. 角色、资产与连续性

- 有参考图时，面容、发型、体型、服装和身份特征是硬锁。
- 人物、道具和场景资产应分开维护；白底资产只锁主体，不承载完整环境。
- 场景资产要锁定空间结构、主体位置、比例、材质、天气、时间和光源方向。
- 四视图应表现同一空间的连续视角，不得生成四个不同地点。
- 前镜视频仅在动作或构图连续性高度依赖时引用，不能替代角色和场景资产。

## 6. 镜头、表演与剪辑

- 开场优先中景、近景或特写建立人物与异常；宏大空间镜头只在需要交代尺度时使用。
- 表演保持真人物理与情绪可读性，不用游戏角色式夸张动作。
- 每个段落可作为完整的生成单元，但 10–15 秒和段落数是适配参数，不是风格硬规则。
- 转场优先直接切、动作匹配、光线延续和环境声桥。
- 调色、介质与声音必须随所选域保持一致。

## 7. 声音方向

- 硬核深空：机械环境声、舱体低鸣、受控静默
- 太空歌剧：低频空间感、风沙、庄严而克制的音乐
- 废土遗迹：粗粝风声、砂砾摩擦、远处结构声
- 异星生态：湿润反射、水滴、黏性有机运动和陌生生物声
- 具体音乐与旁白在源文档中定义不足，不从其他 Profile 自动补入。

## 8. 负面约束

- 禁止把霓虹灯、高饱和紫粉蓝、全息投影、赛博义体和雨夜街道当默认未来感
- 禁止把四种视觉域混成一套冲突风格
- 禁止人物、场景、光源方向、天气和材质跨段漂移
- 禁止卡通、动漫、游戏 CG 和塑料化 3D
- 禁止无来源生物发光污染整个环境
- 禁止随机文字、字幕、水印和界面乱码

## 9. 可替换生产参考

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    aspect_ratio: "16:9"
    duration: "60-90s"
    segment_duration: "10-15s"
    image_models: ["GPT Image 2", "Nano Banana Pro", "Midjourney V7"]
    video_model: "Seedance 2.5"
    image_resolution_examples: ["2K", "4K"]
    video_resolution: "480p"
```

源文档把特定模型分配、英文提示词例外、2×2 场景网格和生成顺序写得很细；它们属于当前生产适配层。永久 Profile 只保留资产职责、空间连续性和视觉域选择规则。

## 10. 缺失项与可靠度

```yaml
missing_or_partial:
  narration_style: 缺失
  music_system: 缺失
  dialogue_voice: 缺失
  detailed_performance: 部分
  factual_world_canon: 缺失

reliability:
  common_visual_baseline: very_high
  domain_visual_dna: very_high
  continuity: high
  cinematography: medium_high
  sound: medium
  production_parameters: medium
```

## 11. 机器可读摘要

```yaml
style_profile:
  style_id: photoreal_future_scifi_family
  version: "1.0-zh"
  classification: hybrid_style_profile
  pre_content_modules:
    required_decisions: [世界观逻辑, 主角身份, 人物关系, 核心事件, 视觉域]
    default_domain: 超写实科幻电影共同基线
  audiovisual_modules:
    global_visual_dna: 真人电影感、可信材质、有来源光线、受控饱和度
    visual_domains:
      - hard_space_exploration
      - epic_space_opera
      - wasteland_ruin_scifi
      - alien_organic_ecology
    anti_cyberpunk_baseline: true
    continuity: 锁定人物、空间、材质、天气、时间与光向
  production_modules:
    adapter_reference: replaceable
    load_one_visual_domain_only: true
  provenance:
    source_documents:
      - file: 未来科幻真人电影.md
        sha256: 41872BBA2930DEFFC5A984D5AF802D4C551C4B40DADBEC0CF9068130756EC4EF
    extracted_modules:
      - module: 共同视觉基线与四个视觉域
        extraction: normalized
      - module: 资产、模型、网格、时长与提示词格式
        extraction: direct
        routed_to: production_modules
```
