# Style Profile：第一人称 POV 沉浸式短片

> 源文档：`D:/AI 视频/Flova技能/第一人称 POV 沉浸式短片.md`  
> 源文件 SHA-256：`4C42272193080AF95E3B80CE71E0524F44B3C784EEA2D153726C897C884AFAAF`  
> 解析版本：v1.0-zh  
> 解析状态：待审核，不代表模型或生成流程已获批准

## 1. 定位结论

这是**严格主角眼睛视角的现实主义叙事 Profile + 制作手册**。最强 Canon 是 POV 可见性：镜头就是主角的眼睛；主角不能以外部正脸、全身或背影视角出现；信息只有进入主角视野后才能成立。

## 2. 适配范围

强适配：沉浸式现实主义短片、记忆叙事、惊悚体验、情感体验、游戏式主观镜头。  
弱适配：需要频繁展示主角表演、群像调度、传统正反打、客观全景说明的故事。

## 3. 上游硬约束

- 冻结剧本的剧情、节奏、情感节点不可因 POV 便利而改写。
- 若关键信息无法自然进入主角视野，应标记为内容—风格冲突，回到上游决定改写、换视角或换 Profile。
- 主角资产只建立手、鞋、衣袖、胸前物件边缘和年龄对应的局部，不建立正脸 Canon。
- 可读文字与准确对白默认由后期贴图/配音承担；声音不能替代重大事件的可见证据。

## 4. 视听风格核心

### 主观运动链

每条 Clip 都应具备：视线起点 → 声音或动作触发 → 视线转向 → 手部/身体局部动作 → 视线落点。结尾应落在视线或动作的可继承状态，而不是主角全身展示。

### 现实主义视觉

- 纪实摄影、自然光、低饱和、真实生活磨损、湿冷空气和使用痕迹。
- 情绪必须转成可见/可听证据，例如封闭边界、留白、热气、手部犹豫、呼吸和实际环境噪声。
- 空间必须有主角视野边界、角色/道具入口、光源方向和物理锚点。

### 声音

- 环境声和动作声承担连续性；对白后期分轨配音，不要求口型。
- 默认无配乐；情绪不足时先加强实际噪声、停顿和动作证据，再考虑对白或音乐。
- 静默是可设计的节拍，不是缺失音频。

### 连续性

持续跟踪角色识别锚点、年龄、服装、主角视线高度、手部版本、道具状态、空间方向、Clip 首尾视线和声音触发。

## 5. 生产与 QC 边界

参考图必须单一职责：节奏、环境、角色入画、手部动作、道具、声音或 QC。抽象风格词不能替代形状、材质、光线、姿态、运动和物理反馈。

POV 破裂、空间方向不可能、手物接触错误属于结构性失败；文字不准确通常应转后期。模型名、480p、5–10 秒、九宫格、提示词固定前缀和负面词数量均属于可替换生产适配。

## 6. 已识别问题

- “Clip 衔接不靠跳切”与后期“Clip 之间使用硬切”表面冲突。合理解释是：叙事连续性必须靠视线/声音成立，剪辑形式可以硬切；不能用硬切掩盖空间逻辑断裂。
- 通用负面词含 `no narration`，但流程允许按需旁白。应改为运行时选择，不能作为永久硬禁用。
- 源文档生成分辨率为 480p，导出却写 1080p/4K，未定义超分与质量验证，不能宣称原生高分辨率。
- “后续 Clip 参考前序 Clip 的角色资产图”应理解为持续绑定同一角色 Canon，而非每次继承可能漂移的生成结果。

## 7. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 第一人称 POV 沉浸式短片.md
style_profile:
  style_id: strict_first_person_pov_realism
  version: 1.0-zh
  classification: hybrid_style_profile
  pre_content_modules:
    compatibility: 关键信息可自然进入主角视野的现实主义叙事
    story_direction: 每段必须有不可替代的 Story Job
    series_content_constraints: 禁止第三人称主角镜头，重大事件必须有视觉锚点
  audiovisual_modules:
    visual_identity: 低饱和自然光纪实、真实磨损与生活质感
    character_visual: 主角仅局部可见，其他角色用服装、道具和动作识别
    environment: 锁定视野边界、入口、光源、材质和空间锚点
    props: 关键道具必须先进入 POV 可见范围
    cinematography: 视线起点、触发、转向、手部动作、落点
    performance: 用局部动作和物理反馈表达情绪
    editing_rhythm: 视线与声音保证连续性，硬切不得掩盖逻辑断裂
    sound_design: 环境声、动作声、呼吸、停顿和静默优先
    voice_system: 对白后期分轨，旁白按项目选择
    continuity_schema: 视线高度、角色锚点、手部版本、道具状态、空间方向和首尾状态
  production_modules:
    negative_constraints: 禁止第三人称泄漏、主角正脸全身、可读伪文字、空间反转和参考污染
    model_adapter_reference: 源文档模型、时长和分辨率均需当前适配
    generation_workflow: 资产、总览、分镜确认、逐 Clip 预检、生成、QC、装配
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/第一人称 POV 沉浸式短片.md
        sha256: 4C42272193080AF95E3B80CE71E0524F44B3C784EEA2D153726C897C884AFAAF
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 storyboard_designer
        extraction_type: direct
      - field: audiovisual_modules
        source_section: multimodal_analyze_tool 与 storyboard_designer
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator、write_the_prompt 与 video_assembler
        extraction_type: direct
```

