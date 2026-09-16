---
fixture_only: false
library_status: ready
style_profile:
  style_id: minimal_stick_figure_explainer_story
  version: "v1.4-zh"
  classification: hybrid_style_profile
---

# Style Profile：精致单色平涂火柴人白板涂绘 v1.4

> **稳定 ID**：`minimal_stick_figure_explainer_story`
> **中文规范名**：精致单色平涂火柴人白板涂绘
> **英文规范名**：Refined Flat-Fill Stick-Figure Whiteboard Doodle
> **升级来源**：继承 v1.3 的单档平涂、角色差异化、头部先画、明确手脚、三级线宽与结构化白板适配；进一步明确“火柴人”是人物造型层，“Whiteboard Doodle”是画面媒介层，逐笔显现是绘制行为层。
> **术语边界**：这里的“单色平涂”指**每个语义区域只有一个均匀基色**，不是整张画只能使用一种颜色。一个画面仍可用少量不同纯色区分人物、道具和信息关系，但任何区域内部都没有第二档明暗。

## 1. 核心定义：人物、媒介、笔迹三层绑定

本 Profile 不是“火柴人”和“whiteboard doodle”二选一，而是三层共同构成一个风格：

1. **人物造型层｜Refined Stick Figure**：保持简洁、动作清楚和低制作负担，同时拥有稳定线宽、明确手脚、可辨身份锚和不同轮廓。
2. **白板媒介层｜Structured Whiteboard Doodle**：暖纸白底、炭黑蓝线、少量语义纯色、图标、箭头、节点和明显留白；每一笔服务解释，不模拟随手乱画。
3. **笔迹行为层｜Semantic Stroke Reveal**：按语义对象和阅读关系绘制；一个对象的线稿与平涂形成完整可读动作，再切换到下一个对象。笔尖只跟随当前有效前沿，抬笔和跨对象时隐藏。

三层缺一不可：只有火柴人会显得机械、空泛；只有 doodle 容易杂乱和角色失去身份；只有逐笔遮罩则可能只是“擦出图片”，没有可信绘制逻辑。

目标观感是清楚、亲和、轻巧、有人工解释感：比基础火柴人精致，但仍一眼可画、可读、可动画。`doodle` 在此专指**有目的的白板涂绘符号**，不授权乱线、反复描线、铅笔噪点、潦草排线或任意手写体堆叠。

强适配：科普解释、生活哲理、知识故事、轻量商业概念、学习方法和抽象关系可视化。
弱适配：精确产品外观、医学解剖、历史服饰考据、真实材质展示、大规模群戏和复杂战斗。

## 2. 线条系统：粗细有层级，四肢不能像发丝

- 以最终输出尺寸为准，使用三档稳定线宽：
  - **一级轮廓 4–6 px**：头部外轮廓、主要身体轴、关键道具外轮廓和前景焦点。
  - **二级结构 3.5–5 px**：手臂、腿、衣领、配饰、道具结构线、因果箭头和主要场景线。
  - **三级细节 1.5–2.5 px**：眼眉嘴、手指暗示、微表情和次要标记。
- 手臂和腿必须使用二级结构线，不得退化为三级细线；在缩小后的成片尺寸仍须连续、清楚、可读。
- 粗细变化服务视觉层级：重要、靠前、承重的线更粗；内部、表情、远处和辅助线更细。禁止随机抖粗细。
- 使用圆头、圆角连接和轻微自然弧度；转折干净，不出现毛刺、重复描线、铅笔噪点和高频抖动。
- 每条线必须有明确语义终点：四肢结束于手掌或鞋形，箭头结束于目标节点，路径不能无故穿过角色或文字。
- 可在主动作末端使用一次短促收笔变细或速度线，但不能让每条线都书法化、装饰化。
- 4× 超采样源中的线宽按最终输出线宽等比放大，缩小时使用 Alpha-aware area filtering。

## 3. 色彩系统：只允许单档纯色平涂

- 每个闭合语义区域只使用一个均匀基色；区域内部禁止第二档阴影、第二档亮面、明暗切面或同色深浅分区。
- **明确禁用**赛璐珞二档配色、硬边阴影块、接触阴影、投影层、渐变、塑料高光、摄影式光影、体积光、纹理、噪点和无来源彩色泛光。
- 线稿颜色独立于填色：推荐暖纸白背景 `#FAF7F0` 与炭黑蓝主线 `#24313A`。
- 一个画面可用 2–4 个语义纯色，单画面通常不超过 6 个可见色彩角色。推荐湖蓝 `#4A90A4`、暖橘 `#F2A65A`、柔黄 `#F4CF61`、薄荷绿 `#79B89A`；警示红只用于真实风险或错误。
- 大面积色块使用低至中等饱和度；同一知识概念与同一角色身份色跨镜保持一致。
- 色彩用于身份锚、服装、关键道具、因果节点和结论高亮；不能用“只换颜色”冒充角色造型差异。
- 普通对象统一使用 `line_then_fill`。本 Profile 不再允许阴影或其他仅颜色层的 `direct_fill` 例外。

## 4. 角色设计：同一画风，不同造型

- **人物和动物角色必须按固定部位顺序绘制**：头部 → 身体 → 大臂/前肢上段 → 小臂/前肢下段 → 手/前爪 → 大腿/后肢上段 → 小腿/后肢下段 → 脚/后爪。
- 新结构化白板源拆为 `character_head`、`character_body`、`character_upper_arms_or_upper_forelimbs`、`character_forearms_or_lower_forelimbs`、`character_hands_or_front_paws`、`character_thighs_or_upper_hindlimbs`、`character_lower_legs_or_lower_hindlimbs`、`character_feet_or_hind_paws`，并满足该 draw order；每个部位使用校验绑定的显式遮罩，z-order 仍按最终遮挡关系独立设置。
- 每个部位的线稿必须先完成外轮廓，再绘制轮廓以内的身份结构、关节、五官或其他细节；轮廓与内部细节分别使用显式遮罩，不得由像素连通性猜测。
- 角色必须画出可辨认的手和脚。手可用手掌加拇指/两指暗示，脚可用鞋形、脚掌或明确的短楔形；不能让四肢直接以无端点细线结束。
- 每个命名角色建立可复用的身份设计；同一角色跨镜保持头型、体型、发型/头饰、服装轮廓、配饰和主身份色一致。
- 同场或同系列的任意两个主要角色，以下六个维度中**至少有三个维度实质不同**：
  1. 头部外形：圆、椭圆、方、梨形、宽扁、窄长或动物物种轮廓；
  2. 发型或头饰：短发、卷发、发髻、帽子、耳朵、角等；
  3. 脸部锚点：不同眼镜、眉形、胡须、鼻口组合或面部标记；
  4. 身体比例与轮廓：高矮、肩宽、躯干长短、上宽下窄等非刻板化差异；
  5. 服装轮廓：衬衫领、外套、连衣裙、围裙、背心、袖型等；
  6. 配饰或职业道具：围巾、胸牌、工具、书本、手杖、包等。
- 禁止“相同圆头 + 相同椭圆身体 + 相同四肢比例，只更换颜色或单个小配饰”的批量模板化角色。
- 不用肤色、性别刻板印象或夸张体型作为主要区分手段；差异应来自轮廓、比例、服装和行为身份。
- 每个角色保留 1–3 个高辨识身份锚，避免为追求差异堆满细节。角色多样性不能破坏共同的线条语言、五官简化程度和白板可绘制性。
- 表情由眼、眉、嘴、头部倾斜和身体重心共同表达；关键动作必须让手脚方向、接触点和承重点清楚。

## 5. 场景与信息图形

- 每个画面只承担一个核心意思。背景由 3–8 个能解释关系的几何或线性元素组成，保留明显纸面留白和角色活动区。
- 优先形成“主体 → 关系或变化 → 结论”的阅读路径；推荐一个主视觉主体、一条主要关系路径和一个结论锚，辅助元素只在帮助理解时出现。
- 箭头、路径、节点、容器、对比框和小图标必须有明确语义；一级焦点用较粗轮廓，辅助关系使用较细线。
- 颜色、线宽和角色轮廓共同建立“主体 → 因果 → 结论”的阅读顺序，不能靠阴影或装饰制造精致感。
- 主体、路径、文字和边缘之间保留可见纸面呼吸区；不得用装饰性小图标、排线或背景纹理填空。
- 文字优先后期独立渲染；进入白板绘制时必须作为独立文字层声明从上到下、行内从左到右的阅读顺序。

## 6. 白板绘制适配

- 简单、稀疏、无重叠的非角色画面可走 `flat_auto`；包含人物、动物、多对象、遮挡、文字或粗细线与填色关系时使用 `structured_semantic`。
- 只要包含人物或动物角色，新 Job 就显式采用 `character_head → character_body → character_upper_arms_or_upper_forelimbs → character_forearms_or_lower_forelimbs → character_hands_or_front_paws → character_thighs_or_upper_hindlimbs → character_lower_legs_or_lower_hindlimbs → character_feet_or_hind_paws` 的 draw order；每个部位内部固定 `outline → interior_details`，不得让像素连通性或位置猜测决定身体部位或笔迹阶段顺序。
- 新资产以最终输出宽高的 4× 尺寸创作；角色、道具、图形和文字使用对齐的 RGBA 语义层。
- 普通对象使用 `line_then_fill`：先绘制显式线稿，再在同一对象内显露单档平涂终稿。线稿必须真实存在，不能从终稿猜测隐藏结构。
- 不创建阴影、投影、高光或其他仅颜色层；因此本 Profile 不使用 `direct_fill`。
- 绘制顺序按叙事理解组织，合成遮挡按独立 z-order 组织；不得用后绘对象覆盖来伪造被遮挡像素。
- 手笔必须贴合当前线稿或色块前沿；换对象、跨大距离或抬笔时隐藏。技术成功后仍需连续观看确认自然度。
- 同一对象内部允许线稿后紧随平涂；无关对象之间必须有可读的完成边界，不能在多个未完成对象之间来回跳笔。
- 禁止整块擦除、对角揭幕和随机连通域顺序；终帧相似或完整解码不能把“擦出图片”证明为可信手绘。

## 7. 连续性锁

- 同一角色：头型、身体比例、发型/头饰、脸部锚点、服装轮廓、配饰、身份色、手脚形状和三级线宽映射。
- 不同角色：已批准的至少三个差异维度不得在后续镜头中趋同或互换。
- 场景与信息：背景、主线、语义色板、图形含义、动作方向、屏幕侧、道具接触和已变化状态。

## 8. 失败判据

- 把 Whiteboard Doodle 解释成草稿噪点、重复描线、潦草排线或无语义装饰。
- 只有简单火柴人外形，却没有白板纸面、信息图关系或对象级绘制逻辑。
- 出现赛璐珞二档明暗、硬边阴影块、投影、渐变、高光、纹理、写实光影、3D、景深或运动模糊。
- 同一平涂区域出现第二档深色/浅色，或用阴影塑造体积。
- 多个角色仅靠换颜色或一个小配饰区分；仍是同圆头、同椭圆身体、同四肢比例的复制模板。
- 任意两个主要角色不足三个实质造型差异维度，或同一角色跨镜身份锚漂移。
- 没有明确手脚；手臂和腿比二级结构线更细，缩小后断裂或像发丝。
- 所有线等粗或随机漂移；粗线机械填色或细线下采样消失。
- 细节与背景过多，导致绘制碎片化、频繁跳笔或阅读顺序不清。
- 整块擦除、对角揭幕、颜色领先线稿、手笔离开前沿或跨对象瞬移。
- 人物或动物未按头部、身体、大臂/前肢上段、小臂/前肢下段、手/前爪、大腿/后肢上段、小腿/后肢下段、脚/后爪的固定顺序完成线稿，或任一部位先画内部细节再画轮廓。
- 纸面留白被无语义 doodle 填满，主体、关系和结论无法按单一路径阅读。

## 9. 叙事、镜头与声音继承

- 继承“设局—困境—顿悟—收束”，也可按内容使用“问题—原理—例子—行动”；模板不是硬阈值。
- 镜头优先固定、缓推、轻移和清晰景别变化；复杂 3D 翻转与电影化镜头不是本风格目标。
- 旁白保持温暖中性、朋友解释感；BGM 轻快低密度，并与旁白、拟音分层处理。
- 镜头秒数、画幅、分辨率、模型与音频参数由当前项目和 Adapter 决定。

## 10. v1.4 来源与升级记录

- 前版：`Style_Profile_精致单色平涂火柴人科普叙事_v1.3_角色差异化.md`，SHA-256 `33BE9EF7085A625A6A304E1AB53763B56AE5F4C397A31C90F92A37E729AE3D31`。
- 保留：单档平涂、无阴影、角色差异化、头部先画、明确手脚、三级线宽、4× 结构化源和 `line_then_fill`。
- 新增：中英文规范名、人物/媒介/笔迹三层视觉语法、Whiteboard Doodle 的正反定义、对象完成边界、留白与信息层级、禁止随意涂鸦和整块擦除。
- 未改变：稳定 ID、Renderer、Adapter、成本 Gate、媒体 QA、部署版本和安装状态。

## 11. 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: minimal_stick_figure_explainer_story
  version: v1.4-zh
  classification: hybrid_style_profile
  style_name_zh: 精致单色平涂火柴人白板涂绘
  style_name_en: Refined Flat-Fill Stick-Figure Whiteboard Doodle
  visual_identity: refined_flatfill_stick_figure_whiteboard_doodle
  character_style_family: refined_stick_figure
  medium_language: structured_whiteboard_doodle
  visual_grammar_layers: [character_design, whiteboard_medium, semantic_stroke_reveal]
  line_hierarchy_output_px:
    primary_contour: 4-6
    secondary_structure_and_limbs: 3.5-5
    tertiary_detail: 1.5-2.5
  color_fill_mode: single_tone_flat_fill_per_semantic_region
  secondary_shading_allowed: false
  color_only_shadow_layer_allowed: false
  character_design_diversity_required: true
  minimum_distinct_design_axes_per_character_pair: 3
  character_design_diversity_axes: [head_shape, hair_or_headwear, face_anchor, body_silhouette, clothing_silhouette, accessory_or_role_prop]
  same_character_identity_consistency_required: true
  hands_and_feet_required: true
  character_draw_order: [character_head, character_body, character_upper_arms_or_upper_forelimbs, character_forearms_or_lower_forelimbs, character_hands_or_front_paws, character_thighs_or_upper_hindlimbs, character_lower_legs_or_lower_hindlimbs, character_feet_or_hind_paws]
  character_part_outline_before_interior_details_required: true
  source_scale: 4x_output_geometry
  default_reveal: line_then_fill
  direct_fill_allowed: false
  random_doodle_allowed: false
  whole_object_wipe_allowed: false
  semantic_object_completion_required: true
  production_modules: replaceable
```
