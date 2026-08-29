# Style Profile：高能卡点运镜与产品 TVC 展示

> **版本**：v1.0-zh  
> **源文档**：`高能卡点运镜展示.md`  
> **内部风格 ID**：`dynamic_beat_showcase_with_product_tvc`  
> **文档分类**：`mixed`  
> **解析原则**：源文档实际包含两套互斥视听体系——高能卡点与产品 TVC。本 Profile 保留一个来源入口，但将两套体系拆为独立 `style_variant`；运行时必须二选一，禁止混用。

---

## 0. 解析结论

这份资料不是一个统一风格，而是两个方向相反的展示 Profile：

1. **高能卡点动感展示**：冷青高对比、快速推拉、硬切、节拍同步、运动模糊、故障与畸变点缀。
2. **产品 TVC 高级展示**：莫兰迪低饱和、柔光、平滑环绕、卖点微距、叠化与轻音乐。

两者的运镜、调色、转场、音乐和特效规则互斥。产品主体应先由用户选择模式；非产品主体默认更适合高能卡点，但仍需检查单张参考图是否足以支持多角度运动。

## 1. 模式门控

```yaml
mode_gate:
  required: true
  style_variants:
    - style_variant_id: teto_dynamic_showcase
      display_name: 高能卡点动感展示
    - style_variant_id: premium_product_tvc
      display_name: 产品 TVC 高级展示
  mixing_allowed: false
```

- 产品类：必须明确选择高能卡点或产品 TVC。
- 建筑、风景、动物、人物、车辆：默认只加载高能卡点适配规则。
- 选定模式后，另一模式的调色、运镜、转场、音频和特效全部卸载。
- 单张图片无法提供真实背面、遮挡区或完整三维几何；任何 360° 表述都只能作为生成目标，不能承诺真实还原。

## 2. 输入与主体分类

支持主体：

- 产品静物
- 建筑场景
- 风景外景
- 动物宠物
- 人物人像
- 车辆交通

输入至少包含一张清晰参考图。分析时记录主体类型、外观锁、背景质量、视觉焦点和可见卖点。原文的“像素级单点锚点”可作为生产追踪参考，但对于动物、人脸、透明物、反光物和大场景，区域或语义特征通常比单像素更稳健；因此永久 Profile 采用“锚点区域 + 语义特征”原则。

## 3. 权威与路由

```yaml
authority:
  reference_subject_identity: hard
  mode_selection: hard
  visual_identity: hard
  cinematography: hard
  editing_rhythm: hard
  sound_direction: medium
  production_tracking_threshold: low
  production_model: none

routing:
  pre_content_modules:
    load:
      - subject_type_compatibility
      - mode_gate
      - reference_coverage_risk
      - background_quality_gate
  audiovisual_modules:
    conditional_load:
      teto_dynamic_showcase:
        - high_contrast_cool_grade
        - accelerated_camera_motion
        - beat_cutting
        - restrained_glitch_effects
        - subject_type_camera_rules
      premium_product_tvc:
        - muted_product_grade
        - smooth_camera_motion
        - selling_point_macro
        - soft_transition
        - ambient_music
  production_modules:
    load:
      - anchor_tracking_reference
      - bpm_timing_reference
      - effect_parameter_reference
      - model_adapter_reference
      - super_resolution_reference
```

# A. 高能卡点动感展示

## 4. 适配范围

### 强适配

- 车辆、机车、建筑、地标、运动人物与潮流产品
- 需要快速建立主体、节拍爆发和多角度冲击的短展示
- 已有清晰音乐节拍或允许独立生成强节奏音乐

### 弱适配

- 需要精准产品色、包装文字与 Logo 的证据型画面
- 人脸近距离超广角、动物快速非刚体动作
- 单张图片只展示主体一面，却要求真实完整背面
- 医疗、教育、奢侈品等更依赖信任和阅读的内容

## 5. 视觉身份

- 冷青中间调、高对比、深暗部与明亮高光。
- 粗颗粒胶片感作为轻到中度纹理，不覆盖主体细节。
- 快速运镜时前景和背景可有运动模糊，主体锚点区域保持清楚。
- 特效只在节拍和高潮节点短暂出现，不持续污染全片。
- 主体真实颜色应被保护，不能因冷青调色发生产品偏色。

“暗部纯黑压死无灰阶”和“画面边缘绝对锐利”属于过度极端的来源表述。永久 Profile 改为：深暗部保留必要结构，主体核心清晰，边缘允许符合镜头运动的自然模糊。

## 6. 两段式节奏

### 建立段

- 先交代主体完整轮廓、环境和锚点。
- 运镜较慢，特效极少，为后续爆发提供对比。
- 具体时长由音乐前奏、总时长和主体类型决定。

### 高速蒙太奇段

- 运镜可用急推、急拉、横移甩镜、俯冲、仰冲和短弧急停环绕。
- 相邻镜头交替运动方向，避免连续重复。
- 节拍越快，单镜越短；弱拍允许短暂放缓制造空间拉扯。
- 高潮节点可短暂使用白闪、色散、球面或四角形变，但主体保护区不得变形。
- 精确时码与特效强度由当前音乐分析和后期时间线决定，不固化为 11 秒、13.5 秒、16 秒。

## 7. 主体类型镜头规则

- 产品：平视微俯、材质和标志微距、小范围贴物环绕；避免大广角远景。
- 车辆：低位贴地、车灯轮毂和车身曲线、平行跟车与冲刺推拉。
- 动物：与眼睛齐平、脸部和毛发特写、贴地跟随；不做垂直怼脸俯冲。
- 建筑：低角度仰拍、结构纵深和线条特写；保持透视比例。
- 风景：高空广角、天际线、航拍推进与有限环绕；不落地微距。
- 人物：平视或微仰、面部与半身为主；限制超广角近距离畸变。

## 8. 音乐与卡点

- 音乐作为独立轨道，先分析速度、前奏、重拍、高潮和关键瞬态。
- 剪辑切点与重拍、底鼓、踩镲或人声段落建立映射。
- 特定歌词和固定 93 BPM 预设仅属于来源示例，不进入通用 Profile。
- 用户没有音乐时，可生成强节奏电子音乐，但风格、速度和强度应先与主体定位匹配。

## 9. 高能模式负面约束

- 不承诺单张图片可真实还原完整三维背面
- 不用持续畸变、频闪和色散替代主体展示
- 不让人脸、动物或产品结构在高速运动中变形
- 不以硬切和白闪破坏可读文字、Logo 或产品证据
- 不让冷青调色改变真实商品颜色
- 不把固定节拍时码、像素阈值和特效参数当作风格本体

# B. 产品 TVC 高级展示

## 10. 适配范围

### 强适配

- 美妆、护肤、香氛、数码、皮具、鞋服、食品与健康产品
- 需要材质、包装、品牌标志和功能部件清晰呈现的广告短片
- 适合柔光、慢节奏和高级灰背景的单品展示

### 弱适配

- 需要强动作、追逐、爆发卡点或故障美学的产品
- 参考图无法辨认包装文字、卖点或真实颜色
- 需要功能演示但只有静态正面图

## 11. 视觉身份

- 低饱和莫兰迪色系与高级灰基底。
- 顶光或前侧顶光为主的柔和漫反射光。
- 高光柔和不过曝，阴影保留轻微层次。
- 极轻胶片颗粒可选，不应明显可见。
- 产品真实色、Logo、纹理、比例和包装文字优先于背景风格。
- 背景根据品类选择哑光渐变、石膏、织物、金属、玻璃、木纹或低饱和自然色。

## 12. 三段式节奏

### 全景铺垫

- 产品与环境全貌，缓慢推近或横移。
- 无明显特效，先建立品牌气质与空间。

### 卖点展示

- 中景、材质特写、Logo 和功能部件微距交替。
- 每个核心卖点留出足够阅读和识别时间。
- 微距镜头可静定锁焦，避免运动影响文字与纹理。

### 收尾

- 缓慢拉远或回到产品正面英雄镜头。
- 叠化或淡出，最后一帧保持清楚稳定。

## 13. 运镜、转场与声音

- 允许缓慢环绕、平滑推近、微距停留、缓慢拉远和平行横移。
- 运动采用匀速或缓入缓出，不出现爆发加速和手持抖动。
- 转场使用轻叠化或淡入淡出，禁止硬切、白闪和跳剪。
- 背景音乐舒缓、轻商务、钢琴或环境音乐，无强节拍。
- 有旁白时音乐降低存在感，不能掩盖产品信息。

## 14. 产品真实性与连续性

```yaml
continuity:
  required: true
  lock:
    - product_shape_and_proportion
    - logo_position_and_spelling
    - packaging_text_when_legible
    - material_and_finish
    - true_color
    - selling_point_location
    - lighting_direction
```

- 背景替换后必须检查边缘、接地投影、受光方向、色温和主体结构。
- 对证据型产品画面，不可用生成模型补造看不见的接口、包装背文或功能部件。
- Logo 和包装文字不可仅凭像素级锚点判断，还需语义与拼写核对。

## 15. TVC 模式负面约束

- 不使用冷青强对比、彩色闪烁、球面畸变、液化和色散
- 不使用硬切、跳剪、手持抖动和高速甩镜
- 不把产品表面过度磨皮或锐化成塑料
- 不让背景颜色污染商品真实色
- 不让慢环绕造成 Logo、包装文字或几何结构漂移
- 不把固定音量、镜头数量和 2 像素阈值升级为永久 Style Core

## 16. 来源冲突与降级项

```yaml
known_source_conflicts:
  - 原文总时长为 18 秒，但未上传音频时一处写“蒙太奇段固定 30 秒”
  - 高速 BPM 表多处把蒙太奇可用时长写为 30 秒，与 18 秒总长冲突
  - 原文既要求建立段匀速前推，又在高能全局规则中禁用匀速运镜
  - 单点锚点全程偏差不超过 2 像素无法由生成模型稳定保证，更适合作为后期追踪 QC 目标
  - 一张参考图生成 360 度完整视角会补造不可见区域，不能称为真实一致性
  - 模型与会员分辨率描述存在重复和自相矛盾，属于易变适配器信息
  - TVC 一处写旁白时 BGM“回避至 -6dB”，方向含义不清，运行时应按人声可懂度重新混音

production_adapter_reference:
  replaceable: true
  source_mentions:
    - Seedance 2.5
    - Nano Banana Pro
    - Suno 5
    - Mureka 8
    - MediaKit
    - Final_Video_Spec.md
```

## 17. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 高能卡点运镜展示.md
style_profile:
  style_id: dynamic_beat_showcase_with_product_tvc
  version: 1.0-zh
  classification: mixed
  pre_content_modules:
    subject_classification: required
    mode_gate: required
    reference_coverage_risk: required
  audiovisual_modules:
    style_variants:
      teto_dynamic_showcase:
        visual_identity: cool_high_contrast_kinetic
        cinematography: accelerated_multi_direction
        editing: beat_synchronized_hard_cut
        effects: restrained_peak_only
      premium_product_tvc:
        visual_identity: muted_soft_light_premium
        cinematography: smooth_selling_point_oriented
        editing: dissolve_and_fade
        effects: minimal
    continuity: semantic_anchor_region_and_subject_lock
  production_modules:
    bpm_parameters: runtime_only
    tracking_threshold: qc_reference
    effect_parameters: runtime_only
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 高能卡点运镜展示.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: teto_dynamic_showcase
        method: normalized
      - module: premium_product_tvc
        method: normalized
      - module: source_conflicts
        method: direct
```
