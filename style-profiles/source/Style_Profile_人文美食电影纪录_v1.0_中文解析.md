# 风格档案：人文美食电影纪录

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\舌尖美食-美学短片.md`  
> 内部风格 ID：`humanistic_food_cinematic_documentary`  
> 中性化处理：具体节目名称只保留在来源说明，运行时用可观察的美食纪录片语言描述。

## 0. 解析结论

这是一份 **美食材质摄影 + 烹饪物理过程 + 人文旁白 + 生产手册**。稳定核心不是某个节目名，而是：温暖深邃的有机色彩、食材微观纹理、逆光蒸汽、油脂与水分的真实反馈、烹饪状态变化、动作匹配转场、现场拟音、人文叙事。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/舌尖美食-美学短片.md"
style_profile:
  style_id: humanistic_food_cinematic_documentary
  version: "1.0-zh-review"
  classification: audiovisual_style_profile
  pre_content_modules:
    compatibility: direct
    story_direction: direct
    narration_style: direct
  audiovisual_modules:
    visual_identity: direct
    cinematography: direct
    sound_design: direct
    voice_system: direct
    editing_rhythm: direct
  production_modules:
    prompt_templates: direct
    model_adapter_reference: direct
    generation_workflow: direct
  provenance:
    source_sha256: B75EDB82C55F9775B2C485D226B284918FFF69306873B3818C223B1F7E6B071D
    extraction: source_grounded
```

## 2. 风格兼容性

### 强适配

- 食材溯源、地方物产、家庭味道
- 烹饪工艺、火候、发酵、熟成、切配与盛装
- 厨师、农人、家庭成员与食物关系
- 需要通过材质与声音制造食欲的短片

### 弱适配

- 纯价格促销、快闪广告、数据口播
- 无真实食材状态变化的抽象剧情
- 需要冷白科技、无机塑料或强赛博风的食品片

## 3. 内容前置模块

- 可选叙事方向：食材溯源、极致烹饪细节、人文情感故事。
- 每个叙事单元应有明确视觉重点与烹饪或情绪高潮。
- 旁白应连接食物、地域、劳动与记忆；不能凭风格补造产地、历史、营养或食品安全事实。
- 若脚本是纯产品卖点，风格只能增强食欲，不应擅自加入家庭或乡愁故事。

## 4. 视觉身份

### 色彩与光

- 基调：温暖、深邃、有机。
- 主层：食材本色；辅层：木色、环境灰；强调层：暖黄实用光。
- 源文档的 6:3:1 可作为构图配色参考，不是必须精确执行的机器阈值。
- 蒸汽使用逆光；肉类强调次表面散射；油脂和酱汁保留湿润高光；阴影不能丢失纹理。

### 材质与物理

- 肉类：纤维、脂肪、成熟度、受热收缩与汁液迁移。
- 果蔬：表皮、脆度、水分张力、断面和熟化色变。
- 液体：黏度、气泡、沸腾、挂壁、飞溅和表面张力。
- 烹饪变化必须有因果：加热、翻炒、浸泡、切配、凝固、酥化、焦化或乳化。
- 避免塑料质感、虚假的均匀高光和没有热源的蒸汽。

## 5. 镜头与剪辑

- 微距承担纹理与状态变化；中景承担手部动作；全景承担产地、厨房和共同进食的人文空间。
- 视觉高潮应来自真实物理瞬间，如油脂迸发、热气喷薄、液体入锅或食材由生到熟。
- 转场优先动势匹配与物理遮挡，例如搅拌方向衔接摆盘，蒸汽遮挡衔接下一空间。
- 默认避免黑白场、无意义叠化和破坏食物流畅感的爆破式转场。
- 源文档的禁词应理解为避免无必要的暴力破坏意象；正常切片等烹饪动作仍可准确描述。

## 6. 表演、旁白与声音

- 人物表演以劳动动作、专注神态、品尝微表情和人与食物关系为主。
- 旁白：厚重、缓慢、磁性、有人文温度；性别和年龄不是永久硬限制。
- 拟音：滋滋、切菜、咕嘟沸腾、油脂飞溅、器皿接触、火焰与蒸汽。
- 物理声效必须与动作点对点同步；背景音乐不应遮盖烹饪声与旁白。
- 源文档没有完整定义音乐身份，运行时音乐只能标记为 `runtime_recommended`。

## 7. 连续性

- 保持食材的生熟状态、份量、切法、湿度、锅内位置和火候阶段连续。
- 同一道菜跨镜头的颜色变化必须符合烹饪顺序。
- 厨具、手部、操作方向、蒸汽来源和光源方向应继承。

## 8. 生产适配参考

Nano Banana 2、Seedance 2.5、480p、2K、16:9/9:16、每 30 秒一组、分镜字数、镜头数量、提示词英文物理参数和暂停节点属于生产适配层，不能成为风格永久定义。

## 9. 源文档冲突与缺失

- 同时要求每 30 秒 10–24 个镜头和最终质检 5–12 个微镜头，数量口径冲突。
- “前 3 秒视觉重点、后 7 秒高潮”只覆盖 10 秒，未定义其余 20 秒。
- 将 30 秒分镜视为单个连续生成任务，与高密度切镜要求存在执行风险。
- 源文档没有定义事实核验、食品安全边界、完整音乐系统和跨菜品色彩连续性。
- 具体模型对基于物理的材质表现、物理过程和长时连续性的执行能力需要实测，不能由风格档案保证。

## 10. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/舌尖美食-美学短片.md"
      sha256: B75EDB82C55F9775B2C485D226B284918FFF69306873B3818C223B1F7E6B071D
  extracted_modules:
    - field: visual_identity
      source_section: 食材逆向工程、核心美术提示词铁律
      extraction_type: normalized
    - field: editing_rhythm
      source_section: 格式与无缝转场
      extraction_type: direct
    - field: sound_design
      source_section: 音频规划、音视频对齐
      extraction_type: direct
    - field: production_modules
      source_section: planner、media_generator
      extraction_type: direct
```
