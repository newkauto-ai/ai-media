# 风格档案：高能水墨武侠动画

> 版本：v1.0-zh-review  
> 源文档：`D:\AI 视频\Flova技能\水墨风格武侠短片.md`  
> 内部风格 ID：`high_energy_ink_wash_wuxia_animation`  
> 中性化处理：具体动画作品名只保留在来源说明，运行时依赖可观察的笔墨、动作、色彩和声画规则。

## 0. 解析结论

这是一份 **五行武侠叙事设定 + 高能水墨视听风格档案 + 精细生产手册**。最有价值的风格核心是“画风随动能变化”：文戏用工笔细线、温润淡墨和大面积留白；高速打斗瞬间切换为焦墨、枯笔、飞白、喷溅墨点和矿物泼彩。动作、镜头、笔触、粒子、打击声与音乐避让共同表达力量。

五行角色、招式相克和书法招式卡是内容模块，不是所有水墨武侠都必须加载的视觉硬规则。

## 1. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: "D:/AI 视频/Flova技能/水墨风格武侠短片.md"
style_profile:
  style_id: high_energy_ink_wash_wuxia_animation
  version: "1.0-zh-review"
  classification: hybrid_style_profile
  pre_content_modules:
    compatibility: direct
    worldview: normalized
    character_archetypes: direct
    story_direction: direct
  audiovisual_modules:
    visual_identity: direct
    character_visual: direct
    cinematography: direct
    performance: direct
    sound_design: direct
    music_direction: direct
    editing_rhythm: direct
  production_modules:
    asset_binding_rules: direct
    prompt_templates: direct
    model_adapter_reference: direct
  provenance:
    source_sha256: 5A60E220E5B03804284621444B0A865E8C0C478EB6297EDEB9A36722AA7C1AC5
    extraction: source_grounded
```

## 2. 风格兼容性

### 强适配

- 武侠、妖兽、五行法术、古典山水与高强度动作
- 需要文戏留白与战斗爆发形成强反差的动画短片
- 能用笔触、墨色和矿物颜料表达动量与情绪的题材

### 弱适配

- 真人写实武打、现代都市枪战、低动作密度口播
- 需要严格科学写实或纯淡雅水墨、没有高能爆发的内容
- 无法容忍书法、矿物色或夸张动作变形的品牌项目

## 3. 内容前置模块

- 可选世界模块：五行使者、妖兽、相生相克、书法招式名与古典山水空间。
- 推荐叙事：蓄势与克制 → 招式显形 → 物理碰撞 → 墨色或矿物色侵蚀 → 余波与留白。
- 对白应短、清晰、有武侠语气，为动作与唇形留出空间；不能为了风格改写人物核心态度。
- 五行体系若与冻结脚本冲突，应标记 `UPSTREAM-CONSTRAINT-LATE`，不能事后把角色强改为五行使者。

## 4. 视觉身份

### 动能耦合

- 静态/文戏：精细工笔勾边、温润墨色、宣纸纹理、大面积留白、柔和层次。
- 常规对打：黑白灰与矿物泼彩相对均衡，强明暗对比，动作方向清晰。
- 高潮冲撞：焦墨骨架压住大面积朱砂、石青、石绿、赭石或金色泼彩。
- 高速瞬态：线条加粗、边缘干裂、飞白排线、墨点喷溅、手绘残影和笔锋拖尾。

源文档给出的 35–40%、50–60%、70/30 等比例是视觉配方参考，不应作为机器像素阈值。

### 场景

- 基底：大气泼墨山水，前中后景由墨色浓淡、留白、云雾和地貌引导。
- 典型陈设：古松、孤碑、竹林、山崖、飞瀑；它们是原型库，不是每集必选资产。
- 古松以焦墨枯笔表现骨力；孤碑以湿晕与干裂刻痕表现时间；竹林以近实远虚和叶影叠层表现风。
- 场景不得被普通 3D 体积烟雾、光滑 CGI 表面或通用日漫背景替代。

## 5. 五行色彩与物理语言

- 金：亮白锋刃、金箔碎屑、线性切割、镜面寒光与焦墨铁骨。
- 木：石绿能量、狂草藤蔓、飞叶和纤维撕裂，兼具弹韧与生长力。
- 水：群青/靛蓝重墨、飞白霜、透明冰刃和液固转换。
- 火：朱砂与熔金、焦墨阴影、热浪扭曲和自发光返照。
- 土：赭石尘暴、飞白巨石、重力崩落、地裂底光与光线衰减。

相克转化需要物理介质变化，例如水灭火产生蒸汽、火烧木产生焦墨灰、木穿土导致石体撑裂。不得只用抽象“能量碰撞”。

## 6. 角色与表演

- 文戏微表情：眉尖、眼波、下颌、呼吸和姿态克制变化。
- 高能瞬态：咬肌、青筋、瞳孔、牙齿和受力形变清晰，但血汗可转译为宿墨痕、飞白抓痕和喷溅墨点。
- 人类动作强调武侠受力与连贯；妖兽可使用非线性轨迹和形体解构；五行使者结合真实武术与元素介质。
- 角色外观、武器、伤势、五行色与声音身份跨镜头保持一致。

## 7. 镜头、动作与剪辑

- 文戏：微速平移、长卷展开、云雾呼吸、陈设特写与墨滴晕染。
- 高能动作：急推聚焦表情或碰撞点，急拉揭示破坏范围，急扫跟随位移轴线。
- 连击硬切必须继承动作矢量；残影和笔锋拖尾只桥接动能，不制造重复肢体。
- 碰撞可使用 1–3 帧黑白水墨闪、微重力定格和衰减震动。
- 书法大字卡是可选高光资产，不能替代剧情节拍，也不能默认每条视频都出现。
- 生成单镜 4–12 秒与后期 1–2 秒内部切片并不冲突，但必须在生产计划里区分“生成单元”和“最终剪辑单元”。

## 8. 声音与音乐

- 环境：风过竹林、细雨、纸张、水滴和水墨空间底噪。
- 武打：刀剑高频、肉体闷击、轻功风阻、招式爆发与材质碎裂。
- 五行碰撞采用高频特征层 + 低频能量层，不用单一爆炸声覆盖所有招式。
- 对白期间，音效与背景音乐主动避让；嘴部首帧与语音起点保持同步。
- 配乐：古筝、二胡、笛子等传统乐器，可叠加摇滚与重打击；高潮保留重拍和突然留白。
- 背景音乐独立生成，视频片段默认不请求背景音乐。

## 9. 连续性

- 同场景固定地貌、光源、矿物色范围、雾向与唯一场景身份。
- 同角色固定五官、服饰、武器、元素色、伤势和声音。
- 跨镜继承动作动量、招式残留、碎屑方向和环境破坏状态。
- 四宫格场景资产是生产参考，不得出现在最终视频中形成分屏。

## 10. 生产适配参考

GPT Image 2、Seedance 2.5、MiniMax Speech、ElevenLabs、2K/480p、角色三视图、四宫格场景图、提示词中英标签、`{dialogue}`、`<sfx>`、具体帧数、dB、频带和暂停节点均属于生产适配器。风格档案只保留其语义目的。

## 11. 源文档冲突与风险

- 开头要求中文提示词，但后文强制大量中英双语标签；归一化后只保留语义，语言由当前适配器决定。
- 一处写“严禁其他模型（如 Kling 或 Seedance 2.5）”，把唯一允许的模型也列入禁用例，属于明显笔误。
- “场景四宫格带白色分割线”会提高最终视频分屏风险，不应视为可靠通用方案。
- 大量精确帧数、频率、dB 与模型唇形机制是生产假设，未经当前真实生成验证。
- 源文档以具体作品为风格锚点；运行时必须改用笔墨、色彩、动作和声画特征。
- “水墨闪”“闪白”“定格”使用过密会削弱冲击，应由当前片长与视听节拍配额控制。

## 12. 来源记录

```yaml
provenance:
  source_documents:
    - file: "D:/AI 视频/Flova技能/水墨风格武侠短片.md"
      sha256: 5A60E220E5B03804284621444B0A865E8C0C478EB6297EDEB9A36722AA7C1AC5
  extracted_modules:
    - field: visual_identity
      source_section: 画风与运动张力动态耦合、色彩与泼彩比例
      extraction_type: normalized
    - field: character_archetypes
      source_section: 五行角色与妖兽动作
      extraction_type: direct
    - field: editing_rhythm
      source_section: 时间线编排与后期剪辑控制
      extraction_type: normalized
    - field: sound_design
      source_section: 音画精密对齐与多轨音频设计
      extraction_type: direct
    - field: production_modules
      source_section: media_generator、write_the_prompt
      extraction_type: direct
```
