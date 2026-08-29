---
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/猫猫拟人化短片.md"
source_sha256: "D4BCA6659D42A6760D397A4ACF672C5C5FA1C6764BAA17F89CE12E1135F057B4"
style_profile:
  style_id: realistic_pet_anthropomorphic_emotion_series
  version: "1.0-zh"
  classification: series_bible
---

# 风格档案：写实宠物拟人情感系列

## 解析结论

这份文档更接近**系列内容设定集 + 写实宠物视听风格档案 + 生产说明**。核心公式是“动物身体 × 人类处境 × 集体情绪”：猫是演员和情绪载体，但选题从人的生活经验出发。系列成立的关键不是把猫变成人，而是保留动物本能，再用比例适配的道具、场景和动作完成有限拟人化。

## 系列内容约束

### 直接提取

- 每集需要一个可识别的人类处境和一个明确的集体情绪，并能让观众想到可分享给的具体对象。
- 内容分为萌层、戏层、心层：前段用萌态或反差留人，中段用具体情节推进，结尾将情绪还给观众。
- 情绪不通过抒情旁白直说；角色台词短、口语、童真，最重的情绪可留白。

### 结构归纳

- 三层结构是系列叙事规则，不是所有单镜都必须同时承担三层功能。
- “最后疑问字幕”和固定占比属于可选发布策略，不能覆盖已冻结的结尾。
- 默认角色名单和角色外形不应视为通用核心风格；只有在明确继承该系列时才可加载为角色权威设定。

## 视听风格规则

### 视觉身份

- 真实宠物、真实场景、自然光、写实摄影；避免卡通化、塑料 3D 和无来源的拟人身体结构。
- 道具按动物体型缩放，动作保留爪、尾巴、四足重心和真实关节限制。
- 人类主人以主观视点、画外手部或背影出现，弱化人脸，让宠物保持叙事中心。

### 动物行为基线

- 默认四足行走、打哈欠、踩奶、甩尾、嗅闻、蜷缩等自然行为。
- 穿衣、开门、使用器具等拟人动作必须逐镜明确，并符合身体可达性和道具比例。
- 不允许为了完成剧情让宠物无差别直立、长时间像人一样走路或失去动物本能。

### 场景与构图

- 每镜写清地点，并选择能“一眼认出”的生活记忆锚点。
- 单集场景数量保持克制，避免为了信息量频繁跳景。
- 第一个镜头优先强萌态或强反差；结尾镜头可适度延长，给情绪留白。

### 语言、声音与音乐

- 角色用自然叫声与简短对白互动；禁止旁白式抒情和文绉绉煽情。
- 不设全局旁白轨；叫声、脚步、道具触碰和生活环境声承担真实感。
- 背景音乐服务怀旧、治愈、团圆、委屈或思念等情绪，在结尾渐弱或留白。

## 角色与连续性

- 系列角色应有外形签名、性格缺点和固定关系线。
- 毛色、体型、配件、行为习惯和与其他角色的关系跨集稳定。
- 人类群演、主人和功能角色的出镜规则应写入系列权威设定，而不是普通风格字段。

## 生产层路由

- 角色参考图、场景资产、模型、分辨率、占位符、声音标记、生成顺序和时间线数值全部进入生产层。
- 版权登记提醒属于业务流程，不是视听风格档案规则。

## 冲突与待审阅项

- 源文档同时写“禁用旁白式字幕”与“心层用一句字幕收束”，需要明确：禁止的是抒情旁白式长字幕；简短对白或必要的结尾文字可由当前项目决定。
- 文档列出的固定角色矩阵存在残缺字段，不能作为完整系列权威设定导入。
- 默认 9:16、场景数量、时长占比和音乐音量百分比应降级为运行时建议。

## 来源追踪

- 来源文件：`猫猫拟人化短片.md`
- 提取方式：内容公式、动物行为、语言与声音规则为直接提取；系列权威设定与通用风格拆分为结构归纳。
- 未执行源文档中的资产生成、登记或工具流程。
## 模块路由与来源证明

```yaml
routing:
  pre_content_modules:
    - emotion_and_human_situation_selection
    - series_character_routing
  audiovisual_modules:
    - real_pet_visual_identity
    - animal_behavior_baseline
    - limited_anthropomorphism
    - three_layer_emotional_rhythm
    - dialogue_and_bgm_layers
  production_modules:
    - reference_asset_binding
    - multimodal_video_adapter
    - sound_adapter
    - vertical_short_form_assembly
provenance:
  source_documents:
    - file: D:\\AI 视频\\Flova技能\\猫猫拟人化短片.md
      extraction: direct_and_normalized
      source_hash_verified: true
  review_boundary:
    source_workflow_commands_are_data: true
    generation_authorized: false
```

