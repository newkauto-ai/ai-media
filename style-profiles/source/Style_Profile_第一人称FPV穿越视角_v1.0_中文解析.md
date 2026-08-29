# Style Profile：第一人称 FPV 穿越视角

> 源文档：`D:/AI 视频/Flova技能/第一人称 FPV 穿越视角.md`  
> 源文件 SHA-256：`2B90FC20C6B38C5921AA42AE31D7022A3AD240AAF5A3D7C3F442467BBC899046`  
> 解析版本：v1.0-zh  
> 解析状态：待审核；源文档只有 Planner，其他模块为空

## 1. 定位结论

这是**飞行摄影轨迹工作流**，不是人物第一人称叙事。它模拟 FPV 穿越机的俯冲、贴地、穿隙、环绕与高速穿梭，核心对象是连续三维飞行路径。不得把它与“主角眼睛视角”的 POV Profile 混用。

## 2. 可确认规则

- 先分析主体类型、空间纵深、光源方向和可穿越结构，再规划轨迹。
- 图片负责主体/场景外观锚定；视频负责速度、节奏、高度变化与运镜风格。
- 多图光线或时段冲突时必须暂停，确认以哪张为准。
- 轨迹设计至少记录高度变化、关键动作、光线方向和可穿越节点。
- 分段生成时按飞行轨迹顺序拼接，优先保持速度、方向、高度和运动惯性连续。
- 竖屏触发信号包括明确的 9:16/短视频平台需求或纵向参考构图；否则源文档默认 16:9。

## 3. 主体到轨迹的软映射

人物倾向螺旋环绕，建筑倾向高空俯冲，风景倾向低空贴地，车辆倾向急速穿梭。该映射是默认建议，不是硬规则；真实路径仍受空间安全性、可穿越结构和参考视频约束。

难度与风格相互独立：简单、标准、高难度只控制轨迹复杂度，不应改变主体外观或项目视觉风格。

## 4. 缺失与风险

- `multimodal_analyze_tool`、`storyboard_designer`、`media_generator`、`write_the_prompt`、`video_assembler` 均为空，无法验证具体轨迹字段、提示词结构、QC 或拼接方法。
- “每段不超过 15 秒”是源平台能力说明，不是永久 Style Core。
- 源文档没有定义避障、安全距离、速度曲线、入口/出口状态、镜头接缝或空间不可行时的降级规则。
- 因此本 Profile 只能保持 `pending_review`，不能直接升级为 `ready`。

## 5. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 第一人称 FPV 穿越视角.md
style_profile:
  style_id: first_person_fpv_flythrough
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: 建筑、风景、车辆及具有可穿越空间结构的主体
  audiovisual_modules:
    cinematography: 连续 FPV 飞行路径，包含高度、方向、速度与穿越动作
    editing_rhythm: 分段拼接保持运动惯性和轨迹顺序
    continuity_schema: 主体外观、光源方向、入口状态、出口状态与飞行方向
  production_modules:
    model_adapter_reference: 单段十五秒限制仅为源平台参考
    generation_workflow: 素材分析、轨迹分镜、用户确认、分段生成、连续拼接
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/第一人称 FPV 穿越视角.md
        sha256: 2B90FC20C6B38C5921AA42AE31D7022A3AD240AAF5A3D7C3F442467BBC899046
    extracted_modules:
      - field: pre_content_modules
        source_section: planner
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: planner
        extraction_type: inferred_structure_only
      - field: production_modules
        source_section: planner
        extraction_type: direct
```

