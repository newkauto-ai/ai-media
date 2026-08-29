# 风格档案：中国经典美术动画复合风格

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\上美影风格短片（工笔重彩、水墨、剪纸、木偶）.md`  
> 内部风格 ID：`classic_chinese_art_animation_collection`  
> 运行原则：原机构名称只保留在来源说明；运行时使用可观察的美学特征，不依赖机构名或具体作品名。

## 0. 解析结论

这是一份 **四分支风格集合 + 叙事建议 + 生产手册**。工笔重彩、水墨、剪纸、木偶并非同一种视觉语言，默认应当四选一；只有在用户明确设计段落切换且说明转换逻辑时才允许混合。

四分支共享的上层 DNA 是：中国传统造型资源、装饰性动作、传统材质、民乐与声音节奏、画面留白或平面秩序、拒绝通用西式 3D 商业渲染。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/上美影风格短片（工笔重彩、水墨、剪纸、木偶）.md"
style_profile:
  style_id: classic_chinese_art_animation_collection
  version: "1.0-zh-review"
  classification: mixed
  pre_content_modules:
    compatibility: direct
    story_direction: normalized
    narration_style: direct
  audiovisual_modules:
    visual_identity: direct
    character_visual: direct
    cinematography: direct
    voice_system: direct
    music_direction: direct
    editing_rhythm: direct
  production_modules:
    asset_binding_rules: direct
    model_adapter_reference: direct
    prompt_templates: direct
  provenance:
    source_sha256: 7B6FF088672EC1515AC5EED0EAA8FE5FE62540B8718F01C61FA626FDA3D6112B
    extraction: source_grounded
```

## 2. 子风格选择闸门

| 子风格 | 强适配 | 核心运动与剪辑 |
|---|---|---|
| 工笔重彩 | 神话、仪式、英雄亮相、装饰性动作 | 戏曲身段，硬切为主，跨时空可叠化 |
| 水墨 | 哲思、山水、寓言、克制情绪 | 长镜、慢摇、留白、柔和叠化 |
| 剪纸 | 童趣、民俗、寓言、节奏喜剧 | 平面铰接动作，清脆硬切 |
| 木偶 | 手工温度、说书、温暖寓言 | 有节制的定格顿挫，硬切 |

选择后，应锁定一个 `selected_substyle`。不能在单镜头内把四种材质平均混合。

## 3. 共享内容前置规则

- 题材与子风格必须兼容；风格只能建议呈现方式，不能改写核心命题。
- 动作可具有戏曲化、民间艺术化或寓言化倾向，但人物立场与剧情事实仍由上游脚本拥有。
- 旁白可凝练、典雅、有东方哲思，但不能为追求古意删改事实或强行去掉角色口语特征。
- 示例人物、场景和台词只用于说明，不是系列固定设定。

## 4. 子风格视觉 DNA

### 工笔重彩

- 线条：清晰闭合的墨线、单线平涂、装饰性轮廓。
- 色彩：石青、石绿、朱红、藤黄等矿物色，色块厚重而有秩序。
- 空间：散点透视；山石、水纹、云纹和建筑可图案化。
- 角色：脸谱与戏曲行当可作造型来源，动作强调台步、身段与亮相。
- 禁止：照片级光影、现代体积光、通用 3D 塑料感。

### 水墨

- 线条：可弱化或取消封闭轮廓，以浓淡、湿润扩散和飞白塑形。
- 色彩：黑白灰为主，可少量藤黄、花青等淡彩。
- 空间：大面积留白、虚实相生、宣纸纤维与墨色自然晕染。
- 运动：柔和、舒缓、如行云流水；远景和山水可优先于角色表演。
- 禁止：密集快剪、硬边数字特效、写实高光。

### 剪纸

- 形态：二维平面、彩纸叠层、硬朗切边、可见铰接关系。
- 色彩：朱红、藤黄、亮绿等高纯度民间色。
- 运动：皮影式机械灵活感、清脆跳跃节奏。
- 光影：保留纸张物理厚度，但不转成厚重三维体积。
- 禁止：柔软无边界、真实皮肤、三维体积光。

### 木偶

- 材质：木、黏土、布、棉麻、毛线等真实手作表面。
- 形体：立体手工偶与微缩布景，关节结构可以可见。
- 光影：真实微缩灯光与柔和投影，整体温润。
- 运动：保留适度定格顿挫，不追求真人般完全无痕。
- 禁止：把木偶误做成全尺寸真人或光滑 CGI 玩具。

## 5. 角色、场景与表演

- 角色设定应能稳定识别正面、侧面和背面；这是连续性需求，不是风格本体。
- 场景需明确空间归属，同地点复用同一场景身份，避免背景随机跳变。
- 工笔强调亮相；水墨强调克制与气韵；剪纸强调关节节奏；木偶强调手工惯性。
- 源文档的“四宫格场景图”是生产参考格式，不是最终画面形式。

## 6. 声音与音乐

- 共享乐器库：古筝、琵琶、二胡、笛子、锣鼓、板鼓、丝竹。
- 工笔：庄重、雄浑、戏曲念白感；音乐可用琵琶与锣鼓重音。
- 水墨：空灵、慢板、呼吸充分；音乐可用古琴与横笛。
- 剪纸：说书与民俗节奏；音乐可用唢呐、梆子和明快打击。
- 木偶：慈祥、质朴、温暖；音乐保持手作与童话感。
- 背景音乐必须独立，不作为视频提示词中的同步生成要求。

## 7. 剪辑与连续性

- 工笔：动作亮相后的停顿点适合硬切。
- 水墨：通过墨色洇散、留白和柔和叠化完成空间转换。
- 剪纸：以动作节拍和卡片式位移硬切。
- 木偶：在动作顿挫处切换，允许轻微跳帧感。
- 角色、场景、服饰、道具和声音身份在跨镜头保持一致；相同场景不应因重新生成而改变陈设。

## 8. 生产适配参考

GPT Image 2、Seedance 2.5、480p/1080p/2K/4K、16:9、4–30 秒、角色三视图、无人物四宫格、音色资产、超分模型、提示词占位符和暂停节点均属于 `production_adapter_reference`。未来模型能力变化时不应修改四分支风格核心。

## 9. 源文档冲突与风险

- 四种子风格差异足以构成四个独立风格档案；本文件保留为集合型入口，正式入库时建议拆分。
- 同时出现“默认 480p / 会员 1080p”和“分辨率限制后降级为 480p”等不清晰描述，需由当前适配器复核。
- 水墨分支要求柔和慢镜，而公共动作公式又包含推拉与统一资产流程；以子风格规则为高权威。
- 源文档把具体机构与经典角色写入提示词示例；它们只保留为来源，不作为运行时依赖或固定设定。
- 方言、具体语速和音色是建议，不能在没有角色与脚本证据时伪装成源作品固定声音。

## 10. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/上美影风格短片（工笔重彩、水墨、剪纸、木偶）.md"
      sha256: 7B6FF088672EC1515AC5EED0EAA8FE5FE62540B8718F01C61FA626FDA3D6112B
  extracted_modules:
    - field: substyle_collection
      source_section: 上美影子风格故事板设计规范
      extraction_type: normalized
    - field: voice_system
      source_section: 音轨与音色一致性设计
      extraction_type: direct
    - field: editing_rhythm
      source_section: 画面转场与镜头过渡规则
      extraction_type: direct
    - field: production_modules
      source_section: planner、media_generator、write_the_prompt
      extraction_type: direct
```
