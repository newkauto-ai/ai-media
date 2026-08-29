# Style Profile：新品品牌情绪 TVC 生产框架

> **版本**：v1.0-zh  
> **源文档**：`新品视觉TVC广告宣传.md`  
> **内部风格 ID**：`brand_emotion_tvc_framework`  
> **解析原则**：该文档是跨高奢、时尚、运动、汽车和 3C 的商业生产框架，不是假定所有品牌共享一套视觉风格；每个项目必须从真实参考图和品牌信息生成独立视觉 DNA。

---

## 0. 解析结论

该文档应归类为 **商业广告生产手册 + 视觉反推框架 + 项目级风格生成器**。它最有价值的不是固定色彩或镜头，而是：证据优先的视觉反推、品牌/代言人/产品/场景关系、材质与结构精度、商业表达四目标、全局资产复用和片段连续性。

它不能直接作为单一永久 Style Profile 使用。高奢、运动、汽车和 3C 的光线、材质、节奏与性能表达差异很大；运行前必须从当前素材建立 `visual_dna` 和 `brand_constraints`。

## 1. 文档分类与输入闸门

```yaml
classification:
  primary: production_playbook
  secondary:
    - series_bible
    - audiovisual_style_profile
  full_series_canon: false
```

### 输入闸门

- 至少需要场景调性参考，才能反推项目级视觉 DNA。
- 代言人并非所有新品 TVC 的必需项；只有项目明确使用代言人时才要求人物参考。
- 产品结构需要精确展示时，应提供可靠产品图或产品证据。
- 品牌名、Logo、产品标签和传播主张必须获得用户授权或可靠来源。
- 输入不足时可以做缺口诊断，但不得伪造品牌分析、人物身份、产品结构和广告主张。

## 2. 项目级视觉 DNA

每次运行应从真实素材提取：

- 媒介类型与成像逻辑
- 人物身份、姿态、妆发和服装结构
- 产品名称、比例、部件、材质、表面工艺和识别点
- 场景前中后景、坐标、遮挡、透视和运动路径
- 主光、辅光、轮廓光、环境反射与体积介质
- 主色、辅色、强调色、品牌色与产品真实色
- 构图骨架、负空间、视觉重心和品牌留白
- 动作潜力、声音潜力、商业记忆点与连续性接口

无法确认的材料、制式或结构必须标为推定，不能写成事实。

## 3. 商业表达四目标

每个项目和主要片段都应检查：

1. 代言人或主角气质是否清楚。
2. 品牌世界是否通过环境、光线、色彩、材质和镜头成立。
3. 产品欲望是否来自真实结构、材质、功能或使用关系。
4. 品牌记忆是否形成可识别的视觉或声音锚点。

没有代言人的项目不应为了填满框架虚构代言人；对应目标可改为“目标用户或产品人格”。

## 4. 领域差异

### 高奢与时尚

- 重点是廓形、剪裁、面料、缝线、皮革、金属件、宝石与姿态控制。
- 光线服务材质高光和人物气质，避免空泛“高级感”。

### 运动

- 重点是功能材料、受力、身体动作、鞋底接触和性能节奏。
- 速度必须有动作因果与地面反馈。

### 汽车

- 重点是车身比例、前脸、灯组、轮毂、腰线、玻璃、漆面反射、道路接触和速度方向。
- 禁止跨镜改变车型结构。

### 3C

- 重点是屏幕比例、边框、机身厚度、倒角、按键、接口、镜头模组、材料层级与交互状态。
- 屏幕文字、界面和功能展示必须有授权与准确依据。

## 5. 镜头与节奏框架

- 首段尽快建立可识别的品牌或产品钩子。
- 大景建立品牌世界，中近景建立人物与产品关系，微距突出材料和工艺。
- 运镜可使用推进、拉远、跟随、环绕和甩镜，但应服务产品结构与情绪。
- 转场优先动势匹配、物理遮挡、几何重合、光影延续、声音桥和节拍延续。
- 长镜头宜承担中段情绪或材料观察，不机械放在片头片尾。
- “每 3 秒重点、每 7 秒高潮、每 30 秒 10–24 镜”是源文档投放节奏假设，不能作为所有品牌的永久硬规则。

## 6. 材质、色彩与真实产品锁

- 产品固有色必须与受光色、反射色分开记录。
- 材质至少描述基底、表面、边缘、纹理、反射、磨损、透明度和工艺。
- 人物与产品的接触关系必须符合尺寸、重量、握持和受力。
- Logo、文字、屏幕和标签不应由生成模型自由发挥。
- 产品证据锁优先于项目风格；风格不得改变键位、接口、镜头模组、灯组、轮毂或结构比例。

## 7. 声音与音乐

- 物理声音与材质对应：皮革、金属扣、轮胎、电机、屏幕交互、衣料和空间反射。
- 音乐曲线服务品牌情绪和产品核心展示时刻，不固定某种配器。
- 有旁白或对白时必须逐字保留已确认文本，并对背景音乐和高频音效做避让。
- 源文档默认保留视频原声且不生成独立音频，但实际应由项目选择，不能固化。

## 8. 资产与连续性

- 代言人、产品、场景和跨片段重复元素应作为全局资产维护，不按单镜重复生成。
- 一次性动作、转场瞬间和临时氛围不应注册成永久资产。
- 人物锁：面部、体型、发型、妆造、服装和姿态气质。
- 产品锁：结构、比例、材质、颜色、表面状态和品牌识别点。
- 跨片段锁：动作方向、镜头速度、光向、色彩、声音尾音、节拍和产品高光。

## 9. 负面约束

- 禁止未经授权 Logo、品牌字样、产品标签、随机文字和水印
- 禁止人物身份漂移、脸部和手部畸形
- 禁止产品、车辆和 3C 结构变形或界面乱码
- 禁止为填模板新增未确认人物、道具、场景和功能
- 禁止用空泛“高级、梦幻、电影感”替代可见物理细节
- 禁止无动机黑白场、渐隐渐显和破坏连续性的转场

## 10. 来源内部冲突与风险

- 依赖关系写成“阶段 2 → 阶段 1”，与实际先视觉分析再品牌分析的顺序相反。
- 源文档既要求“必须代言人”，又声称覆盖广泛新品 TVC；本 Profile 将代言人改为条件性要求。
- “1000 词 JSON”和“每表约 1000 字”是信息量目标，不是质量保证。
- 源文档禁止“破裂、切割、爆破”等词，会误伤真实产品功能或叙事；本 Profile 只禁止无依据的破坏性视觉，不屏蔽合法事实表达。
- 固定 30 秒片段和固定节奏可能与平台、品牌、预算和当前模型能力冲突。

## 11. 可替换生产参考

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    image_model: "GPT Image 2"
    video_model: "Seedance 2.5"
    video_resolution: "480p"
    segment_duration: "30s"
    shots_per_segment: "10-24"
    rhythm_heuristics: ["3s 视觉重点", "7s 高潮"]
```

## 12. 缺失项与可靠度

```yaml
missing_or_partial:
  fixed_visual_identity: 不适用
  fixed_color_palette: 不适用
  fixed_music_identity: 不适用
  brand_facts: 依赖用户输入
  product_truth: 依赖产品证据
  platform_strategy: 依赖当前项目

reliability:
  visual_reverse_engineering_framework: high
  commercial_expression_framework: high
  product_material_rules: high
  continuity: high
  universal_timing_rules: low
  single_style_identity: not_applicable
```

## 13. 机器可读摘要

```yaml
style_profile:
  style_id: brand_emotion_tvc_framework
  version: "1.0-zh"
  classification: production_playbook
  pre_content_modules:
    required_inputs: [场景调性参考, 品牌授权信息, 产品证据_如需精确展示]
    conditional_inputs: [代言人参考, 产品图, 品牌色, 材质参考]
    commercial_goals: [主体气质, 品牌世界, 产品欲望, 品牌记忆]
  audiovisual_modules:
    visual_identity: 由当前项目 visual_dna 决定
    domain_variants: [高奢时尚, 运动, 汽车, 3C]
    material_truth: 产品结构与真实色优先于风格
    cinematography: 服务品牌关系、产品细节与情绪曲线
    sound: 材质拟音、项目级音乐与必要人声避让
  production_modules:
    adapter_reference: replaceable
    fixed_timing_heuristics_are_canon: false
    unauthorized_brand_generation: blocked
  provenance:
    source_documents:
      - file: 新品视觉TVC广告宣传.md
        sha256: 7E0005D5BAD536DD55362CB2EDB86C284ECA3EBD9F73F7519D46E74631F30413
    extracted_modules:
      - module: 视觉反推、商业表达、材质、资产与连续性
        extraction: normalized
      - module: 固定模型、时长、镜头数、提示词和流程
        extraction: direct
        routed_to: production_modules
```
