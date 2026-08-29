# Style Profile：参考视频结构复刻

> **版本**：v1.0-zh  
> **源文档**：`复刻视频.md`  
> **内部风格 ID**：`reference_video_structural_remake`  
> **文档分类**：`production_playbook`（主）+ `mixed`（次）  
> **解析原则**：本 Profile 没有固定视觉风格；它从当前参考视频提取结构、镜头、节奏和声音关系，再替换主题内容。参考视频是运行时证据，不是永久系列 Canon。

---

## 0. 解析结论

这是一套**参考条件型复刻工作流**，不是一套独立美学。它的稳定核心是：完整拆解参考视频的叙事节拍、剪辑点、镜头类型、机位、运镜、关键帧和音频结构；再用新的角色、产品或主题替换内容，同时保持原片的结构关系与节奏逻辑。

“复刻”应理解为结构与视听机制迁移，不等于逐像素复制。原文提供了模型、提示词和生成顺序，但这些均属于可替换生产层。

## 1. 适配范围

### 强适配

- 已提供清晰参考视频，并希望迁移镜头结构或节奏
- 广告、短剧情、产品展示、MV 或口播包装的结构重制
- 需要保留关键构图、剪辑节拍和声音层次的新主题版本

### 弱适配

- 没有参考视频，只提供模糊文字描述
- 要求一比一复制受保护角色、品牌资产、独特音乐或演员声音
- 参考片过长、镜头过密，但生产预算和时长未定义
- 新主题与参考片动作结构明显不兼容

## 2. 权威与路由

```yaml
authority:
  reference_structure: hard
  reference_cinematography: hard
  reference_editing_rhythm: hard
  reference_visual_style: medium
  replacement_subject_identity: hard
  content_semantics: none
  production_model: none

routing:
  pre_content_modules:
    load:
      - reference_compatibility
      - replacement_mapping
      - rights_and_identity_gate
  audiovisual_modules:
    load:
      - shot_decomposition
      - keyframe_composition
      - cinematography_transfer
      - editing_rhythm_transfer
      - sound_structure_transfer
      - continuity
  production_modules:
    load:
      - reference_asset_binding
      - generation_workflow_reference
      - model_adapter_reference
```

## 3. 参考视频拆解

每个叙事节拍应记录：

- 时间范围，单段不超过约 30 秒
- 场景、背景及其动态
- 角色、物体、动作、表演和对白
- 景别、机位角度、镜头运动与内部剪切
- 标志性构图和关键参考帧
- 环境声、对白、旁白、音乐和情绪变化

拆解以完整叙事节拍为单位，不必机械地把每个剪辑点拆成独立条目；但内部剪切必须按顺序清楚记录。

## 4. 替换映射规则

- 先识别参考片中“谁、在何处、用什么、完成什么动作”。
- 再为新主题建立角色、场景和道具的一一映射。
- 保留镜头功能：建立空间、揭示信息、推动动作、改变关系或完成反应。
- 当新对象的物理尺寸、动作能力或情境不同，保留功能而非机械复制动作。
- 用户提供的角色、产品、场景和声音素材优先绑定，不重复生成。

## 5. 视觉与镜头迁移

- 每个新镜头与参考拆解中的一个节拍明确对应。
- 保留参考片的景别、角度、运镜、剪辑频率和节奏走势。
- 关键帧只冻结当前可见状态：开始帧表现动作预备，结束帧表现动作结果，高光帧表现最强视觉节拍。
- 角色、场景和道具分别建立稳定资产；同一角色多造型需明确状态差异。
- 连续镜头可引用前镜结果；时间跳跃、场景切换或情绪断点不应强制继承。

## 6. 视觉身份的运行时提取

本 Profile 不预设固定色盘或画风。每次运行从参考视频提取：

- 主色调、饱和度、对比度与高光滚降
- 主光源方向、光质与阴影密度
- 胶片、数字、写实、插画或动画质感
- 构图习惯、镜头焦段感与景深
- 表演尺度、动作速度和情绪基调

缺失或不可见项保持 `null`，不凭“电影感”自动补上作者、导演或具体作品标签。

## 7. 声音结构

- 参考片有明确段落或情绪变化时，可拆分多段背景音乐结构。
- 旁白和对白保留信息功能、节奏与情绪关系，但新台词必须服务新主题。
- 声线参考只用于用户有权使用的声音或经允许的合成音色。
- 视频内嵌音频与独立旁白、音乐轨不能重复叠加。
- 后期字幕独立处理，视频生成层默认不自动添加字幕。

## 8. 连续性

```yaml
continuity:
  required: true
  lock:
    - replacement_character_identity
    - costume_state
    - prop_identity_and_state
    - scene_layout
    - keyframe_composition
    - action_start_and_end_state
    - voice_identity_when_authorized
```

## 9. 权利与真实性风险

以下是运行时审查项，不属于源文档明示规则：

- 不冒充原作者、原品牌、真人或官方版本。
- 不复制用户无权使用的商标、角色形象、独特音乐和私人声音。
- 对真人声音或肖像需要明确授权和用途边界。
- 参考片中的事实、字幕和产品声明必须重新核验，不能因“复刻结构”自动继承。
- 推荐采用“同功能、不同表达”的最小变换原则，降低一比一复制风险。

## 10. 负面约束

- 不把参考片的示例人物、台词或品牌当成当前内容事实
- 不用抽象心理描述替代可见动作与微表情
- 不在关键帧中描述画面外信息
- 不强行按逐秒时间码要求生成模型执行复杂多节拍
- 不在已有独立旁白或音乐时重复生成同类音频
- 不把具体模型、语言偏好和固定包装语法视为永久 Style Core

## 11. 来源冲突与降级项

```yaml
known_source_conflicts:
  - 故事板部分允许内部剪切写精确时间段，而提示词部分又说明模型不可靠执行精确逐秒计划；应由后期时间线承担精确时码
  - 原文既要求“严格参考”又允许模型补全不可见细节，必须区分 source_defined 与 runtime_recommended
  - 声音复刻未定义授权审查流程，不能默认可用

production_adapter_reference:
  replaceable: true
  source_mentions:
    - Nano Banana 2
    - Seedance 2.5
    - MultiModalToVideo
    - voice_reference
    - Final_Video_Spec.md
```

## 12. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 复刻视频.md
style_profile:
  style_id: reference_video_structural_remake
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: reference_to_replacement_mapping
    rights_gate: runtime_recommended
  audiovisual_modules:
    visual_identity: runtime_extracted
    cinematography: reference_transferred
    editing_rhythm: reference_transferred
    sound_structure: reference_transferred
    continuity: replacement_asset_locked
  production_modules:
    keyframe_workflow: reference_only
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 复刻视频.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: reference_decomposition
        method: direct
      - module: structural_transfer
        method: normalized
      - module: rights_gate
        method: inferred_structure_only
```
