# 风格档案：生活空间沉浸式第一人称视角

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\室内设计生活空间POV展现.md`  
> 内部风格 ID：`immersive_living_space_pov`  
> 解析原则：侘寂、轻奢、北欧等室内风格是每次任务的运行时输入，不是本风格档案的固定美术身份。

## 0. 解析结论

这是一份 **空间展示导演语法 + 一镜到底 POV 规范 + 生产手册**。它定义的是“怎么带观众走进一个空间”，而不是某一种室内设计风格。稳定核心是：成人步行视角、阈限—发现—归属的情绪路径、竖向构图、空间连续、自然光与材质逐步显现、安静环境声和步态拟音。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/室内设计生活空间POV展现.md"
style_profile:
  style_id: immersive_living_space_pov
  version: "1.0-zh-review"
  classification: production_playbook
  pre_content_modules:
    compatibility: direct
    story_direction: normalized
  audiovisual_modules:
    visual_identity: normalized
    cinematography: direct
    editing_rhythm: direct
    sound_design: direct
    continuity_schema: direct
  production_modules:
    asset_binding_rules: direct
    prompt_templates: direct
    model_adapter_reference: direct
  provenance:
    source_sha256: 7ED85AE2AA7204D64E21E986D7CE38EDC4B13097FF64BCFDE4DE349A5E83F513
    extraction: source_grounded
```

## 2. 风格兼容性

### 强适配

- 住宅、酒店、民宿、展厅、工作室与小型商业空间
- 室内设计方案展示、改造前后中的“改造后”沉浸呈现
- 需要让观众理解布局、材质、采光和生活感的短片

### 弱适配

- 需要大量人物表演、对白或剧情冲突的内容
- 建筑外观航拍、城市漫游、快速产品剪辑
- 空间布局尚未确定或参考图互相矛盾的项目

## 3. 内容与情绪路径

### 阈限

- 从入口、玄关、门洞或走廊开始。
- 只透露空间轮廓，光色可略冷或低饱和。

### 发现

- 沿真实通行路径进入主体空间。
- 光线逐渐充盈，家具关系、材质和纵深逐步可读。

### 归属

- 在窗边、床头、沙发、阅读角或核心生活场景停留。
- 节奏收敛，让光影、织物、木纹和环境声完成情绪落地。

这三段是展示结构，不得被误用来擅自改造室内方案。

## 4. 视觉与空间规则

- 镜头高度保持成人步行视角，约 155–170 cm；水平或轻微俯视。
- 禁止无人机俯瞰、贴地仰拍、上帝视角和无理由的高度漂移。
- 竖屏构图优先利用天花、窗景、走廊和垂直材质纹理。
- 画面上段承载天花与光，中段承载主体家具，下段承载地面材质与行进线。
- 空间应有真实透视、自然白平衡和轻微胶片颗粒，避免商业渲染过曝与 CGI 塑料感。
- 人物默认不出现；若任务需要生活角色，必须作为用户当前覆盖重新设计。

## 5. 摄影与运动

- 核心：第一人称、连续行进、无可见切剪。
- 基线运动：手持平摇、缓步前行、轻微镜头呼吸、凝视停留。
- 摄影机的轻微垂直位移应符合步行惯性，不能漂浮。
- 相邻空间节点保持视线中心、运动方向和门洞关系连续。
- 结尾缓慢收敛，避免突然停止或硬结尾。

## 6. 材质、光线与陈设

- 从用户参考提取墙面、地面、家具、织物、石材、木材和金属的真实表面。
- 明确主光源方向、色温和软硬程度；同一行进路径中的光线变化应可解释。
- 标志性道具可单独锁定，但不能为填画面随意增加装饰。
- 空间全景、局部材质和最终视频应保持同一布局与家具位置。

## 7. 声音

- 主层：静谧室内底噪、窗外风声、远处自然声或城市声。
- 可选层：脚步、衣料、木地板、地毯和门把手的拟音。
- 归属阶段逐步收缩音量和运动声，让空间自身成为听觉主体。
- 源文档将环境氛围声标为 `music`，语义不准确；归一化后应标为环境声，真正的背景音乐为可选。

## 8. 连续性

- 固定平面布局、家具位置、材质、窗外方向、光源、时间、镜头高度和运动轴线。
- 从一个功能区进入另一个功能区时，必须经过真实门洞或通道，不可空间瞬移。
- 若必须拼接多段，拼接点选择方向和视线一致的运动帧；对外仍保持一镜到底观感。

## 9. 生产适配参考

9:16、30 秒、横版全景底片、竖版 4–6 格分镜、Nano Banana Pro、Seedance 2.5、2K/480p、时间区间标注、提示词标签与两次暂停属于生产实现。当前模型若不能可靠读取宫格标注，应改用空间路径清单或多个关键帧，不改变风格核心。

## 10. 源文档冲突与缺失

- 各段建议时长相加只有约 13–17 秒，无法覆盖固定 30 秒；示例又把归属阶段写成 11–30 秒。
- “一次生成 30 秒”与模型上限属于易变事实，必须由当前适配器验证。
- 一镜到底与“若因时长拆分则无缝拼接”并不等价；后者只能标记为视觉伪一镜到底。
- 多宫格内叠加导演文字可能污染视频画面或被模型误读，应作为生产风险。
- 未定义具体室内风格、音乐身份、人物系统和对白系统；这些字段必须保持空或运行时推荐。

## 11. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/室内设计生活空间POV展现.md"
      sha256: 7ED85AE2AA7204D64E21E986D7CE38EDC4B13097FF64BCFDE4DE349A5E83F513
  extracted_modules:
    - field: story_direction
      source_section: Threshold、Discovery、Belonging
      extraction_type: normalized
    - field: cinematography
      source_section: 视角高度锁定、一镜到底视频提示词
      extraction_type: direct
    - field: continuity_schema
      source_section: 格间视线衔接、时间轴组装
      extraction_type: normalized
    - field: production_modules
      source_section: planner、media_generator、write_the_prompt
      extraction_type: direct
```
