# 风格档案：都市霓虹碎片诗电影

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\王家卫风格短片.md`  
> 内部风格 ID：`urban_neon_fragmented_poetic_cinema`  
> 中性化处理：导演姓名与具体影片、人物和台词仅作来源证据；运行时使用可观察的电影语言，避免依赖姓名模仿。

## 0. 解析结论

这是一份 **都市情感叙事设定 + 低照度电影视听风格档案 + 多模态生产手册**。可复用核心是：时间与错过、都市孤独、含蓄关系、低照度高饱和冷暖对照、框架式构图、前景遮挡、浅景深、手持呼吸、少量抽帧、微表情、诗意独白、精确拟音与复古器乐。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/王家卫风格短片.md"
style_profile:
  style_id: urban_neon_fragmented_poetic_cinema
  version: "1.0-zh-review"
  classification: narrative_style_bible
  pre_content_modules:
    compatibility: direct
    themes: direct
    story_direction: direct
    dialogue_style: direct
    narration_style: direct
  audiovisual_modules:
    visual_identity: direct
    cinematography: direct
    performance: direct
    sound_design: direct
    voice_system: normalized
    music_direction: direct
    continuity_schema: direct
  production_modules:
    model_adapter_reference: direct
    prompt_templates: direct
    generation_workflow: direct
  provenance:
    source_sha256: E4721F2DF6E4D1F9E0F96E4B347DFDB98D6A70822962537A939CB715145857C9
    extraction: source_grounded
```

## 2. 风格兼容性

### 强适配

- 都市关系、错过、等待、暧昧、记忆与时间
- 夜晚街道、旅馆、走廊、餐馆、舞厅、雨窗与旧城区
- 依靠眼神、空间距离、独白和物件表达潜台词的短片

### 弱适配

- 明快喜剧、知识口播、企业宣传、纯动作爽片
- 需要高亮自然日光、客观纪实或信息图表的内容
- 主要依靠密集对白解释剧情、没有空间与表演余地的脚本

若必须把原故事改成爱情、错过或都市孤独，判定 `mismatch`；风格不能自动制造人物关系。

## 3. 内容前置模块

- 主题：时间、距离、错过、欲言又止、都市孤独、记忆的误差。
- 叙事倾向：以物件、时间标记、空间阻隔和重复动作承载情绪。
- 对白：口语化、短、含蓄、有潜台词；不能为了“文艺”破坏人物原本态度。
- 独白：可带时间哲学和碎片感，但必须与前后事件有因果关系。
- 结尾：倾向自然收束、释怀或遗憾，不强造悬念；这只是风格偏好，不能覆盖原作结局。

## 4. 视觉身份

### 色彩

- 都市霓虹：翡翠绿与红/青色光，配深黑阴影，表达迷幻与疏离。
- 复古怀旧：暗红、琥珀黄、芥末黄与暗绿，表达压抑和亲密。
- 大漠或非都市变体：赭石金与深靛蓝，表达孤绝和时间质感。
- 色盘按场景锁定，不应每镜随机换色。

### 光与空间

- 低照度但面部保留细节；使用柔和包覆的面部光和方向明确的实用光源。
- 潮湿地面、玻璃和金属可承接霓虹反射；墙纸、织物和木材使用定向漫反射。
- 前景—主体—背景三层清晰；门框、窗帘、百叶窗、玻璃和柱体形成窥视与阻隔。
- 主体在焦平面，背景以透视线、散景和光衰减建立深度。

## 5. 摄影与构图

- 基线：自然三分法、侧面中景、越肩机位、框架式构图和轻微手持呼吸。
- 特写关注眼神、嘴角、下颌、手指、烟雾、雨滴和旧物。
- 倾斜构图、极度对称、抽帧拖影和极速横摆都属于稀有高光，建议全片各不超过一次。
- 抽帧用于角色与环境时间不同步，不应成为全片滤镜。
- 慢镜可用于少量情绪特写；普通叙事仍应保持自然动作和有效切镜。

## 6. 表演

- 核心：含蓄克制、静水流深；身体保持秩序，微观肌肉变化承担情绪。
- 眼神可湿润、低垂、闪躲或短暂交汇；人物不必正对镜头。
- 环境交互应有重量：手划墙、酒杯晃动、打火机点燃、雨水压重衣料。
- 多角色通过身体朝向、擦肩、停顿和回望建立关系，不依赖直白台词。

## 7. 声音、角色声音与音乐

- 拟音：高跟鞋、钟表、打火机、烟草、雨伞、衣料、杯具和潮湿地面。
- 声场随空间变化：狭窄走廊更近、更干；空房间有短混响；雨夜街道更扩散。
- 方言是运行时选择，不是风格硬要求；角色声音应按人物年龄、身份和地区单独定义。
- 配乐核心：大提琴/低音提琴、小提琴、手风琴、萨克斯、古典吉他、爵士钢琴。
- 粤语、上海话、闽南语的配器映射属于建议，不是语言决定音乐的硬规则。
- 视频片段只承载对白和拟音；背景音乐独立生成和混音。

## 8. 连续性

- 每段结束记录角色位置、姿态、视线、道具、衣物干湿和光源方向。
- 下一段开头继承前段终态，并完成未闭合动作。
- 重复出现的钟、香烟、门牌、信纸等情绪物件保持状态变化有序。
- 对白与独白应延续上一段的问题或情绪，不得只追求碎片感而失去逻辑。

## 9. 剪辑

- 段内以自然硬切连接多景别，切点跟随视线、动作、物件声或音乐重拍。
- 段间优先动作匹配、开门、遮挡或横摆衔接。
- 禁止花字、闪白、像素化和无物理依据的短视频转场。
- “高频自动切镜”是源文档的生产策略，不是永久美学；若情绪需要停留，可减少切镜。

## 10. 生产适配参考

Seedance 2.0/Fast、GPT Image 2、Nano Banana Pro、Suno、Mureka、720p/1080p、15 秒段落、4–6 秒音色视频、角色横向拼版、音频提取、方言口型、纯中文提示词、具体光圈焦段和封面比例均属于生产适配器。

## 11. 源文档冲突与风险

- 开头严禁慢动作，后文又把慢镜列为核心摄影手段；应归一化为“避免全片慢动作，只在少量情绪高光使用”。
- 要求提示词绝对无英文，但同一模板大量使用英文标签、占位符和技术词，内部不一致。
- 要求 100% 忠实原著同时允许压缩寒暄和风景，“100%”不可作为可验证指标；应改为不改变情节、人物关系和结局。
- “必须有核心悬念”与“结尾绝无悬念扣子”可兼容，但应理解为过程有主线、结尾不强行吊胃口。
- 角色设定视频提取音色、方言原生生成和精确口型属于未验证模型能力，不能由风格档案承诺。
- 具体导演、影片、角色和名台词只作来源，不应直接复制或成为运行时提示词依赖。

## 12. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/王家卫风格短片.md"
      sha256: E4721F2DF6E4D1F9E0F96E4B347DFDB98D6A70822962537A939CB715145857C9
  extracted_modules:
    - field: themes
      source_section: Skill 定位、对白与独白设计
      extraction_type: normalized
    - field: cinematography
      source_section: 三维空间与镜头深度、构图与镜头运动
      extraction_type: direct
    - field: performance
      source_section: 角色动作与表情性能解构
      extraction_type: direct
    - field: continuity_schema
      source_section: 视觉状态账本
      extraction_type: direct
    - field: production_modules
      source_section: planner、media_generator、write_the_prompt
      extraction_type: direct
```
