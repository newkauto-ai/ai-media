# Style Profile：巨构慢燃粗野主义科幻

> **版本**：v1.0-zh  
> **源文档**：`维伦纽瓦导演美学风格电影.md`  
> **内部风格 ID**：`monumental_slow_burn_brutalist_scifi`  
> **解析原则**：创作者姓名与具体作品只保留在来源说明，不作为运行时提示词依赖；把导演模仿请求拆解为可见、可听、可执行的空间、光线、材质、表演与声音规则。

---

## 0. 解析结论

该文档应归类为 **叙事风格手册 + 强视听 Style Profile + 高度模型绑定的生产手册**。稳定核心是：慢燃叙事、个体与巨构的极端尺度对照、粗野主义与未来考古、低饱和色彩、逆光剪影、大气介质、克制微表演、单一缓慢运镜、低频音景与关键静默。

源文档含大量极精细数值，例如人物面积低于 1%、1:100 尺度、眼睑 8–12Hz、毫秒级吞咽时序、0.1x 运镜、固定镜头比例和声频/dB。它们多数是生产假设，不能当作已验证的导演规律或跨模型硬规则。

## 1. 分类与适配

```yaml
classification:
  primary: hybrid_style_profile
  secondary:
    - narrative_style_bible
    - production_playbook
  full_series_canon: false
```

### 强适配

- 宿命、权力、文明遗迹、孤独探索、神圣启示与存在困境
- 需要巨构、荒原、工业遗迹或压迫性空间表达主题的科幻
- 对白克制、画面承担主要叙事、节奏允许长时间凝视的内容

### 弱适配

- 喜剧、轻快生活、快节奏爽片、密集对白和信息口播
- 必须依靠高饱和霓虹、复杂 UI 或连续快速动作的题材
- 规模很小、空间无法承担隐喻功能的日常情节

### 兼容性闸门

若故事本身包含个体与制度、环境、文明或未知力量的张力，可用巨构、留白和低频声场强化。若必须凭空加入末世、神殿、沙漠或宿命主题才能成立，则判定为 `mismatch`。

## 2. 上游内容与叙事

- 推荐慢燃弧线：压抑 → 逼近 → 爆发或静默。
- 优先用视觉隐喻而非解释性对白：阴影吞没人物、孤身穿越荒原、光束揭示遗迹。
- 角色可以带有符号性，但不能牺牲当前脚本已锁定的人性动机。
- “悲壮宿命、神圣空灵、冷酷绝望”可作为情绪子方向，不强制每次三选一。

## 3. 权威级

```yaml
authority:
  topic_direction: soft
  narrative_arc: medium_high
  visual_identity: hard
  scale_and_space: hard
  color_and_light: hard
  material_system: hard
  cinematography: hard
  performance: high
  sound_design: hard
  narration_style: high
  production_numbers: low
  production_model: none
```

## 4. 视觉身份与空间语法

- 极简、粗野主义和纪念碑式巨型空间
- 巨大负空间、严格轴线、深消失点与受控对称
- 人物在画面中显得脆弱渺小，但具体比例按镜头可读性决定
- 建筑边界可作为刚性框景，收束视线并隐藏杂乱外围
- 未来考古感来自风化、侵蚀、遗迹和功能不完全可知的结构，不来自堆叠霓虹科技符号

## 5. 色彩、光线、大气与材质

### 通用规则

- 低饱和、受控强调色、深黑位和高反差
- 逆光、剪影、狭缝光与明显的明暗切割
- 雾、尘、沙、雨或微粒作为空间尺度和光束的可见介质
- 局部发光必须有物理来源，并限制色彩外溢

### 三个情绪色域

- 神圣空灵：冷钢蓝、雾银、深靛阴影、狭缝体积光与微尘
- 悲壮宿命：去饱和琥珀、赭石、焦土棕、烈阳与风沙
- 冷酷绝望：铅灰、浓黑、低饱和锈褐、冷雨和湿混凝土

### 材质

- 裸露混凝土、模板拼缝、尘粒沉积、氧化层和雨水痕迹
- 风化石材、古代雕刻、微裂纹与不均匀浮雕表面
- 厚重哑光金属、结构锈蚀、磨损防护服和高质量垂坠织物
- 材质细节必须稳定，不能在运镜中闪烁、融化或滑动

## 6. 角色、微表演与声音形象

- 表演克制：锁定凝视、吞咽、喉部轻微紧绷、缓慢呼吸、下眼睑细微颤动。
- 这些动作应服务当前情绪，不得每个镜头机械重复。
- 长袍或厚织物呈现质量、惯性和重力阻尼，避免轻飘高频乱舞。
- 声音可强调胸腔共鸣、干燥摩擦、受压气息和停顿，但具体音高、Hz、dB 与声带参数由当前演员或语音适配器验证。
- 对话短、破碎、留白多；是否使用内心独白由脚本决定。

## 7. 镜头语言与节奏

- 超广角或全景用于尺度，中近景用于角色压力和微表演。
- 优先中轴对称、双侧会聚线、低机位仰视与大面积留白。
- 运镜缓慢、沉稳、单一方向；推荐极慢推进、有限横摇或绝对静止。
- 运动镜头可采用“静止建立 → 缓慢运动 → 静止落点”的节奏。
- 禁止急推、急拉、手持抖动、混合多方向运镜与无动机快速剪辑。
- 源文档的 70/20/10 运镜分配和 15°–30° 横摇范围仅作视觉开发测试起点。

## 8. 声音、旁白与音乐

- 低沉弦乐持续音、原始低频打击、工业低鸣、空灵无词吟唱可按子方向选择。
- 环境声应与介质一致：风沙摩擦、金属呻吟、冷雨、水滴、空旷混响。
- 巨物显现、审判式台词或启示瞬间可设置突然静默，让声音真空成为结构事件。
- 旁白低沉、克制、回忆录式，使用短句和有意义停顿。
- 人声必须清楚，背景低频与环境噪声在后期避让；具体频段和衰减值不固化为风格身份。

## 9. 连续性

- 锁定角色外观、场景空间、巨构尺度、光源方向、介质状态和材质磨损。
- 四宫格场景参考只是资产布局形式，视频应输出单一统一画面，不得把网格带入成片。
- 不要求连续镜头永远使用同一四宫格分区；应根据镜头空间意图建立明确、可追踪的视角状态。
- 前镜视频只在动作或构图连续性真正需要时引用。

## 10. 负面约束

- 禁止高饱和霓虹污染、无来源彩光和默认赛博朋克化
- 禁止巨构尺度漂移、几何融化、材质闪烁与人物比例膨胀
- 禁止把所有角色都演成相同的凝视、吞咽和颤抖模板
- 禁止快切、摇晃、复合运镜和无动机镜头炫技
- 禁止依赖创作者姓名或具体影片名执行模仿

## 11. 可替换生产参考与已识别风险

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    image_model: "GPT Image 2"
    video_model: "Seedance 2.5"
    resolution: "480p"
    typical_shot_duration: ["8s", "12s"]
    image_layouts: ["16:9 人物三视图", "4:3 场景四宫格"]
```

风险与冲突：

- “每次生成任何资产都暂停”是流程控制，不是风格。
- 毫秒级微表情、固定 Hz、1:100 尺度和固定画面占比未经真实模型/演员验证，标记为 `runtime_recommended` 或视觉开发假设。
- 源文档一面要求场景无人物，另一面又给出人与巨构比例；应分别用于纯场景资产和最终镜头。
- 源文档要求字幕后期渲染，同时部分提示词要求 `no subtitles`；本 Profile 解释为生成素材无随机字幕，最终字幕由项目需求决定。

## 12. 缺失项与可靠度

```yaml
missing_or_partial:
  factual_director_research: 未提供外部核验
  fixed_character_canon: 缺失
  dialogue_semantics: 缺失
  validated_micro_expression_timing: 缺失
  validated_audio_mix_values: 缺失

reliability:
  visual_identity: very_high
  scale_and_space: very_high
  color_and_material: high
  cinematography: high
  sound_direction: high
  precise_numeric_rules: low
```

## 13. 机器可读摘要

```yaml
style_profile:
  style_id: monumental_slow_burn_brutalist_scifi
  version: "1.0-zh"
  classification: hybrid_style_profile
  pre_content_modules:
    preferred_themes: [宿命, 权力, 文明遗迹, 孤独探索, 神圣启示]
    preferred_arc: [压抑, 逼近, 爆发或静默]
  audiovisual_modules:
    visual_identity: 低饱和巨构、粗野主义、未来考古与大气介质
    scale_and_space: 个体渺小、巨构压迫、轴线与深消失点
    performance: 克制微表演与受压呼吸
    cinematography: 单一缓慢运镜与长时间凝视
    sound: 低频音景、介质拟音与结构性静默
  production_modules:
    adapter_reference: replaceable
    precise_numeric_rules: runtime_recommended
    creator_name_runtime_dependency: false
  provenance:
    source_documents:
      - file: 维伦纽瓦导演美学风格电影.md
        sha256: 075DA7BFA553CCDE0C37589126CFE6EE0FB7834E1AB5803CDF623F5E76101F74
    extracted_modules:
      - module: 叙事、空间、光线、材质、表演、镜头与声音
        extraction: normalized
      - module: 模型、数值、画幅、暂停与提示词语法
        extraction: direct
        routed_to: production_modules
```
