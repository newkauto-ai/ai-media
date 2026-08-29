# Style Profile：高连贯一镜到底广告短片

> **版本**：v1.0-zh  
> **源文档**：`一镜到底广告短片.md`  
> **内部风格 ID**：`seamless_continuity_ad_short`  
> **解析状态**：`pending_review`  
> **来源哈希**：`0bc4bc7195a7a46e9e5dea308931c8e87ba54c721fbf71abdcbd6dc80c6f6e19`  
> **边界**：源文档仅作为解析素材；其中的工具、模型、生成模式和逐镜执行指令均未执行。

## 0. 解析结论

这份材料主要是一套**生产工作手册**，而不是具有稳定色彩、材质和美术身份的传统 Style Profile。它定义的核心价值是：

- 用多个顺序生成的镜头制造“近似一镜到底”的高连贯观感。
- 后一镜必须承接前一镜结束时的角色、空间、光线、机位和动作状态。
- 可通过前镜最后一帧或前镜视频流作为连续性参考。
- 每个镜头生成后先审查，再把已确认结果传给下一镜。
- 组装时使用纯切，不用淡入淡出或花哨转场掩盖接缝。

因此，本解析把它归类为 `production_playbook`。它可以与任意视觉风格组合使用，但不能单独回答“画面应该是什么颜色、材质或审美”。

## 1. 分类与权限

**主分类**：`production_playbook`  
**次级性质**：连续性语法、资产承接规范、重制与组装流程  
**系列 Canon**：否

### 权威级

- 镜头承接机制：高
- 生成顺序：高
- 首尾状态连续性：高
- 组装转场：高
- 资产绑定：高
- 故事、角色和视觉身份：无
- 色彩、光线、材质、音乐风格：无
- 具体模型、分辨率与工具接口：生产参考

## 2. 适配范围

### 强适配

- 产品、空间和人物在连续镜头中自然推进的广告短片
- 需要“像一镜到底”但受单次生成时长限制的项目
- 相邻镜头空间变化小、状态可平滑继承的叙事
- 需要逐镜质检、可局部重制的生成工作流

### 弱适配

- 场景频繁跳跃、跨时空蒙太奇
- 每镜视觉风格和人物造型都大幅变化
- 需要并发批量生成以追求速度的项目
- 没有稳定角色、场景和道具参考的复杂连续动作

## 3. 前置内容模块

这份工作手册不决定选题，只要求剧本和故事板具备可承接性：

- 相邻镜头尽量处于同一空间或具有可解释的匹配转换。
- 后一镜开场不能依赖角色瞬移、场景重建或无因光线变化。
- 每个镜头都要说明结尾状态，以便下一镜接续。
- 若必须跨空间或跨时间，应明确设计匹配剪辑，而不是假装物理连续。

## 4. 连续性核心

### 后一镜开场必须继承

- 角色站位、朝向、视线和姿势
- 手势、道具持有状态和接触关系
- 场景布局、固定参照物和背景层次
- 摄影机初始景别、角度和运动趋势
- 光源方向、强度和色温
- 前镜末尾仍在进行的动作或环境变化

### 第一镜

第一镜负责建立角色、场景、光线、镜头运动和整体视觉基准。后续镜头不能把第一镜未确认的偶然错误固化成连续性输入。

### 后续镜头

只有前镜结果被确认可用后，才能提取或绑定连续性参考。若前镜已出现人物变形、场景漂移或状态错误，应先修复前镜，不能把错误继续传递。

## 5. 两种承接方式

### 方式 A：末帧图承接

从前一镜末尾选取最后一张清晰、无黑场、无淡出、无渲染破损的画面，作为后一镜起始状态。

**优点**：成本较低、速度较快、状态边界明确。  
**风险**：镜头交界处可能出现短暂停顿或“刹车感”，动态惯性较弱。

### 方式 B：前镜视频承接

把前一镜视频作为后一镜的动态参考，用于继承运动惯性、节奏和镜头轨迹。

**优点**：动态衔接通常更自然。  
**风险**：成本和时间更高，也可能放大前镜已有的错误。

方式选择属于项目级生产决策，不是永久风格身份。

## 6. 故事板要求

### 关键元素

- 角色：锁定身份、外观、服装和不同状态。
- 场景：锁定重要物体的位置、朝向和可运动区域。
- 道具：锁定尺寸、材质、持有者和交互关系。
- 用户提供的资产优先于自动生成的替代资产。

### 镜头描述

每镜至少包含：

- 场景和关键元素引用
- 角色或产品动作
- 准确对白或旁白归属
- 景别、角度和摄影机运动
- 起始状态与结束状态
- 与前后镜的承接关系

长镜头可以包含内部节拍或内部切换，但应按叙事顺序描述，不依赖精确逐秒控制。

## 7. 重制规则

重制中间镜头时，目标不是只让该镜“更好看”，而是同时满足：

- 继承前一镜的结束状态；
- 保持本镜内容和镜头意图；
- 平滑抵达后一镜已经使用的开场状态。

若后一镜的开场本身有错误，不应反向强迫本镜适配错误目标，应先决定修复范围。

## 8. 组装规则

- 连续镜头之间优先纯切。
- 不使用淡入淡出、交叉溶解、闪白或三维转场掩盖接缝。
- 背景音乐、旁白和环境声跨接缝保持连续，不能卡顿或突变。
- 接缝处应复核姿态、运动方向、光线和环境声是否连续。
- “近似一镜到底”应诚实标记为多镜连续组装，不应声称为单次实拍长镜头。

## 9. 提示词语义规则

永久可复用的提示词原则只有：

- 明确每个参考资产分别负责角色身份、场景、起始状态或前镜动态。
- 当前镜从已确认的起始状态继续，不重新初始化人物和场景。
- 动作按摄影机、主体、空间、声音的顺序组织。
- 多动作按先后顺序描述，不强依赖精确秒数。
- 独立旁白不在视频提示词中重复，避免双重语音。
- 字幕和音乐是否由后期处理，应在生产层明确。

## 10. 后续生产路由

以下内容属于生产适配层：

- 具体图像 / 视频模型和 480p 参数
- 起始帧、结束帧、参考视频的工具字段
- 角色图版式和元素资产注册方式
- 逐镜暂停、用户确认和两个模式的成本提示
- 多模态占位符、对白包装和负面词
- 生成后末帧提取、重制和时间线导出

## 11. 来源冲突与风险

### 语言规则冲突

来源一处要求中文环境下提示词使用中文，另一处又要求所有图像提示词写成流畅英文。两者不能同时作为硬规则。本解析将自然语言选择交给当前生产适配器与用户要求。

### “一镜到底”表述风险

来源实际描述的是多镜顺序生成与纯切组装，不是真正没有剪辑的单一镜头。对外应称“高连贯伪一镜到底”或“连续镜头组装”，除非最终成片确实无可见接缝。

### 成本风险

前镜视频承接方式被来源明确描述为高成本方案。进入真实生成前必须给出模型、数量、预计成本和停止条件，并获得确认。

## 12. 核心负面约束

- 不要并发生成存在依赖的相邻镜头
- 不要把未审查的前镜错误传给下一镜
- 不要起始姿态、场景、机位或光线无因重置
- 不要用淡入淡出掩盖物理接缝
- 不要在中间镜重制时破坏前后镜连接
- 不要重复生成用户已经提供的可用资产
- 不要把多镜组装宣称为真实单次长镜头

## 13. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 一镜到底广告短片.md
style_profile:
  style_id: seamless_continuity_ad_short
  version: "1.0-zh"
  classification: production_playbook
  pre_content_modules:
    compatibility:
      authority: high
      preferred: [连续广告短片, 同一空间叙事, 多镜伪一镜到底, 可逐镜审查项目]
      avoid: [高频跨时空跳跃, 并发批量生成, 无稳定参考的复杂连续动作]
    story_direction:
      authority: medium
      value: 相邻镜头必须具备可解释的物理或匹配承接关系
  audiovisual_modules:
    visual_identity:
      authority: none
      value: null
    character_visual:
      authority: medium
      value: 角色身份、服装、状态和声音参考跨镜锁定
    environment:
      authority: hard
      value: 场景布局、重要物体位置、光源和摄影机起点跨镜继承
    props:
      authority: hard
      value: 道具持有、位置、尺寸和接触关系不得在接缝处跳变
    cinematography:
      authority: hard
      value: 后镜从前镜结束景别、角度和运动趋势自然继续
    performance:
      authority: hard
      value: 后镜动作从前镜末尾姿态和动量继续
    editing_rhythm:
      authority: hard
      value: 顺序生成，接缝纯切，音轨连续
    sound_design:
      authority: medium
      value: 环境声和音效跨纯切点保持连续
    voice_system:
      authority: soft
      value: 对白声音可绑定角色声音参考，旁白可独立成轨
    music_direction:
      authority: none
      value: null
    continuity_schema:
      authority: hard
      track: [角色站位, 朝向, 视线, 手势, 道具, 场景, 机位, 景别, 光线, 动量, 音轨]
  production_modules:
    asset_prompt_templates: 来源包含角色与场景关键元素图规范
    first_frame_templates: 前镜末帧图作为后镜起始状态
    end_frame_templates: 重制中间镜时可使用后一镜首帧作为目标结束状态
    video_prompt_templates: 来源包含末帧图承接、前镜视频承接和首尾双帧重制结构
    negative_constraints: [无字幕, 无额外音乐, 无场景重置, 无姿态跳变, 无花哨转场]
    model_adapter_reference:
      replaceable: true
      source_mentions: [Nano Banana 2, Seedance 2.5]
    asset_binding_rules: 第一镜绑定关键元素；后续镜额外绑定前镜末帧或前镜视频
    generation_workflow: 严格顺序生成、逐镜审查、确认后传递连续性参考、最后纯切组装
  provenance:
    source_documents:
      - file: "D:/AI 视频/Flova技能/一镜到底广告短片.md"
        sha256: 0bc4bc7195a7a46e9e5dea308931c8e87ba54c721fbf71abdcbd6dc80c6f6e19
        observed_date: "2026-08-24"
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer、write_the_prompt 与 video_assembler
        extraction_type: inferred_structure_only
      - field: production_modules
        source_section: planner、media_generator、write_the_prompt 与 video_assembler
        extraction_type: direct
```
