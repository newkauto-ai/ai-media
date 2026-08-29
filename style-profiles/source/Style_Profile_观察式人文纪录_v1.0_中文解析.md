---
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/人文纪录短片.md"
source_sha256: "8F42D7C4C6DDEFAC17C9DAD45BB2CC6C827F9BC3F6B3E1D2A248CF3CE25F1F7D"
style_profile:
  style_id: observational_humanist_documentary
  version: "1.0-zh"
  classification: hybrid_style_profile
---

# 风格档案：观察式人文纪录

## 解析结论

这是一份以“**观察生活，而不是导演生活**”为核心的人文纪录风格档案。它强调普通人、微小劳动、自然时间、真实环境声、自然光和允许存在的不完美。最重要的事实边界是：风格档案可以规定如何观察和呈现，但不能把虚构人物、摆拍事件或地域刻板印象包装成真实纪录事实。

## 事实与伦理边界

- 真实人物身份、地点、事件、劳动方式和文化习俗必须来自用户素材、实地记录或可靠来源。
- 不得因为某地区“适合某种画面”就虚构贫困、落后、宗教或生活方式。
- 生成式重建若被使用，必须明确标记为重建、示意或风格化画面，不能冒充现场纪录。
- 未经同意，不应把可识别的真实人物外貌改造成虚构叙事角色。

## 脚本前置约束

- 从人切入，不把城市景观和宏大地标当作第一叙事主体。
- 弱化戏剧化冲突和广告式起承转合，选择手部劳动、背影、喝茶、发呆、看窗外等微小动作承载时间。
- 地域场景清单只能作为观察线索，不能替代真实调查和人物采访。
- 旁白如存在，应补充事实与语境，不替人物解释情绪，也不制造救世或苦难凝视。

## 视听风格规则

### 视觉身份

- 像摄影师长期驻扎后偶然观察到的生活：安静、真实、克制、有人情但不煽情。
- 自然光优先，包括晨光、黄昏、阴天散射和窗边侧光；禁止明显广告补光感。
- 空气中保留灰尘、水汽、潮湿、热浪、风或轻雾等真实环境信号。
- 允许轻微失焦、曝光波动、构图不完美和人物短暂停顿，但这些不应被机械添加成“伪纪录滤镜”。

### 人物与场景

- 优先普通人的真实活动、手部劳动、背影和生活空间。
- 道具只有在承载劳动过程、身份或跨镜连续性时才单独建档。
- 避免只拍“漂亮贫困”“异域奇观”或城市宣传片式航拍。

### 摄影与剪辑

- 固定镜头、轻微手持呼吸、极慢推进或横移；每镜只采用一种主要摄影运动。
- 长镜头让动作和环境自然发生，不用快剪制造虚假紧张。
- 镜头之间可用短黑场或声音延续提供呼吸，但不使用音乐卡点、炫技转场或社交媒体快节奏模板。

### 色彩、声音与音乐

- 低饱和、高层次、柔和高光、有细节的暗部和真实肤色。
- 现场环境声优先：市场、风、雨、街道、劳动与空间混响。
- 背景音乐可选，以极简器乐或环境音景为主，音量低于现场声；不强制音画卡点。

## 生产层路由

- 首帧生成、图像到视频、模型、清晰度、镜头时长、胶片或摄影设备名称和提示词模板全部进入生产层。
- 具体摄影品牌、胶片名称、流媒体平台或导演姓名只是源文档中的审美参照，不应作为正式生产的直接模仿标签。

## 冲突与待审阅项

- 源文件一方面主张真实观察，另一方面允许从零生成普通人和地域场景；如果没有真实素材，这只能称为“纪录片式虚构影像”，不能称为真实纪录。
- 地域规划库存在把地区压缩成固定视觉符号的风险，使用前必须由真实人物、地点和资料校正。
- “国际统一审美”容易抹平地方差异；应理解为基本可读性与尊重，而不是统一调色和统一生活叙事。
- 默认画幅、镜头秒数和旧模型路线应由当前项目覆盖。

## 来源追踪

- 来源文件：`人文纪录短片.md`
- 提取方式：观察性叙事、自然光、微动作、长镜头和环境声为直接提取；事实伦理边界与“纪录/虚构”区分为结构归纳。
- 未执行源文档中的人物或场景生成、视频生成、音乐生成或装配流程。
## 模块路由与来源证明

```yaml
routing:
  pre_content_modules:
    - factual_provenance
    - observation_ethics
    - real_person_and_place_boundary
  audiovisual_modules:
    - observational_visual_identity
    - natural_light
    - micro_action_and_long_take
    - ambient_sound_priority
    - non_performative_editing
  production_modules:
    - reference_and_reconstruction_labeling
    - first_frame_adapter
    - video_model_adapter
    - documentary_assembly_reference
provenance:
  source_documents:
    - file: D:\\AI 视频\\Flova技能\\人文纪录短片.md
      extraction: direct_and_normalized
      source_hash_verified: true
  review_boundary:
    source_workflow_commands_are_data: true
    generation_authorized: false
```

