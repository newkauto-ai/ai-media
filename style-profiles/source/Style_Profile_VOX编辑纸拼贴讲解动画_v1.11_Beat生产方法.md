---
fixture_only: false
library_status: ready
style_profile:
  style_id: vox_transcript_driven_handmade_collage
  version: "v1.11-zh"
  classification: hybrid_style_profile
---

# Style Profile：VOX 编辑纸拼贴讲解动画（Historical VOX）

> **正式调用 ID**：`vox_transcript_driven_handmade_collage`
> **常用称呼**：VOX 拼贴动画、编辑纸拼贴、逐字稿驱动手作拼贴动画
> **当前原则**：先决定 Pilot 是给“看”的 `hero_key_art`，还是给“做”的 `production_reconstructable`；再坚持“先把每一镜设计成值得停下来看的编辑海报”并按 route 生成。历史内容可额外选择一个 `historical_visual_mode`，但它与 Pilot、分解、Motion 路由互相正交，不替代任何既有决策。

## 优先级

1. **Poster First**：每个正式 VOX Shot 先定义并通过静态可读的 `stable_poster_state`。
2. **Editorial Hierarchy Before Motion**：动效不能补救主次不清、文字拥挤或纸层关系失败的构图。
3. **One Primary Attention Target at a Time**：相机、人物、标记和环境可以复合协同，但每一时刻只有一个主要注意力目标。
4. **Minimum Sufficient Assets**：只把已批准 Poster Shot 实际引用的素材列入 Production Asset Set。
5. **Remotion First**：能用本地确定性排版、文字、地图、数据和纸片运动可靠表达时，优先 Remotion。
6. **Generative Hero Clip Last**：只有复杂人物/动物/群体/环境的连续自然物理运动本身就是价值时，才使用生成式 hero clip，并记录 `why_not_remotion`。
7. **Selective Hero Posters**：正式允许大多数镜头由 VOX editorial 体系承担，少量高质量 hero poster 保持整张或轻拆解；不要求每镜都碎纸拼贴或完全分层。
8. **Route Before Generation**：Pilot 生成前必须选择 `hero_key_art` 或 `production_reconstructable`；不要等出图后才发现主体镜头不可拆。
9. **Coherent and Reconstructable**：Production Pilot 必须同时是完整、有冲击力的海报，并让主要视觉组天然可独立重建；可拆但难看与好看但只能硬裁都不通过。
10. **History Explains, Not Decorates**：历史人物、史料语境、地图与时间结构必须服务于叙事解释；不把“旧纸、印章、地图、箭头”堆成装饰性档案剪贴簿。

## 适用范围与语义边界

- 适合旁白或观点驱动的历史、商业、产品、解释和评论型内容。
- Script 与 ADP 继续拥有事实、论点、叙事顺序和高层语义 Beat；本 Profile 不改写语义。
- `ADP Beat` 可以投影为一个或多个 `VOX Poster Shot`。Poster Shot 是实际编辑视觉单元，不是新的状态机、Manifest 或审批 Gate。
- 纯装饰拼贴、长时间写实表演或依赖真实空间连续物理的场景不是默认路线，应先判断兼容性。

## VOX Poster Shot

每个 Poster Shot 至少记录：

```yaml
poster_shot_id:
source_beat_id:
time_range:
information_goal:
primary_attention_target:
shot_role:
poster_archetype:
stable_poster_state:
critical_text:
asset_requirements:
pilot_design_route: hero_key_art | production_reconstructable
decomposition_decision:
adjacent_shot_difference:
motion_route:
historical_visual_mode: hero_cinematic | editorial_explainer | atmospheric_historical | null
```

- `shot_role` 是开放描述，可使用 `establish`、`detail`、`comparison`、`evidence`、`map`、`number`、`relationship`、`transition`、`climax`、`symbolic_payoff` 或项目自定义值。
- 长或信息密集的 ADP Beat 可拆成 establish + detail/evidence，但不机械强制每个 Beat 两镜。
- Poster Shot Map 必须在批量素材生成前存在；没有通过 Review 的 Shot 不能让素材进入生成队列。
- `historical_visual_mode` 是可选字段；非历史镜头保持 `null` 或省略，不改变 v1.9 的既有行为。

## Pilot Design Route

在 Pilot 设计与图片 Prompt 编译之前，每个 Pilot 选择且说明一个 `pilot_design_route`：

- `hero_key_art`：用于封面、高潮、情绪峰值、重要回扣、Title Card、宣传主视觉、图生视频参考和 Living Poster／微动画。允许完整场景与高度视觉融合，不要求所有元素天然可拆；后续优先 `keep_whole`、`partial_decomposition` 或生成式参考。
- `production_reconstructable`：用于 VOX editorial 主体、Typography、Comparison、Relationship、Evidence、Map／Route、Data／Number 与 Remotion precision shots。设计阶段就必须支持主要视觉组独立化与后续 Static Reconstruction；后续优先 `rebuild_locally`、`full_element_assembly` 或可证据化的 `partial_decomposition`。

优先 `production_reconstructable` 的信号包括关键文字分阶段出现、地图／路线精确动画、人物关系或数据需要程序控制、多元素独立入场，或最终 stable poster 明确需要 Remotion 重组。完整画面的情绪价值高于元素控制、只需微动画／整体相机／图生视频，或拆分会明显损害画面质量时，优先 `hero_key_art`。

`production_reconstructable` 的设计约束是：主要 Typography 组、方向图形、墨迹／朱印／色块／标签等装饰组与语境组在一个连贯海报内仍可视觉分离、独立复现；保留分阶段信息、运动、字幕安全区和局部调整所需负空间；避免跨元素纹理纠缠。不得固定层数、元素数量、布局、色板或任何单一历史项目的视觉常量。

底部／前景语境应拆成少量有意义的组，例如 torn paper、terrain 与 army／flags，而不是连续的 full-width context strip。Typography 可以错位、轻微重叠和保留设计感，但主要词组必须能成为 native text、verified SVG 或 verified PNG，不得与背景墨迹融合到只能截取矩形。

## Production Reconstructability Review

继续复用 `previsualization_storyboard` / Poster Readiness Review，不创建 Pilot Gate、Manifest 或 State Machine。对 `production_reconstructable` 增加以下 findings：

- `typography_split_test`：主要文字组能否独立化且保持字形完整与设计特征。
- `context_separation_test`：背景／底部语境能否拆成少量有意义的独立组，而不是整块截图。
- `decorative_independence_test`：箭、路线、墨迹、朱印与主要装饰是否可以独立存在。
- `rectangle_risk_test`：实际制作是否会退化为明显矩形 screenshot crop。
- `motion_sequence_test`：静态设计是否支持 `state A → element reveal → information build → stable poster state`，而不只允许整图 Zoom／Pan。

`hero_key_art` 只按 visual impact、focal hierarchy、style fidelity、emotional value 与 micro-animation／video-reference feasibility 评估；上述 reconstructability checks 标记为 `not_applicable`，不能因为难拆而自动失败。`production_reconstructable` 必须同时通过 Visual Quality、Poster Readiness 与 Production Reconstructability。

以下任一情况在 `production_reconstructable` 中都是 `must_fix`：可见水平裁切线、垂直矩形边、background halo、full-width context strip、title + background rectangular crop，或相邻元素残片被一起裁入。明显矩形 screenshot crop 不是元素拆分 fallback。无法安全独立化时选择 `rebuild_svg`、`rebuild_text`、`verified_typography_asset`、`generate_independent_asset` 或 route reclassification，不得硬拆。

生成后的真实 Pilot 若视觉质量高但过度融合，原计划 `production_reconstructable` 可以返回 `recommended_reclassification: hero_key_art`。保留该图并进入 v1.8 既有 salvage／reuse，之后另行生成真正的 Production Pilot；reclassification 不是对 Production Reconstructability 的 PASS，也不授权新生成。

## Poster Spec 与静态可读性

VOX `local_assembly_plan` 使用现有 Scene/Shot 结构承载：

```yaml
poster_spec:
  poster_archetype:
  pilot_design_route: hero_key_art | production_reconstructable
  historical_visual_mode: hero_cinematic | editorial_explainer | atmospheric_historical | null
  visual_hierarchy:
  primary_subject:
  secondary_elements:
  background_system:
  foreground_system:
  reading_path:
  text_safe_area:
  critical_text_owner: remotion
  critical_text_realization: remotion_native_text | verified_typography_svg | verified_typography_png
  decomposition_decision: keep_whole | partial_decomposition | full_element_assembly | rebuild_locally
  background_plate_strategy:
  cut_paper_outline_runtime_style:
  stable_poster_state_ref:
  poster_readiness_review_ref:
  static_reconstruction_evidence_ref:
```

Poster Readiness 检查主注意力、编辑层级、纸层分离、关键文字安全区、无运动可读性、素材覆盖、相邻构图区分和 Style Baseline 一致性。任一 `must_fix` 未解决时，Motion compilation 必须停止；继续加推镜、飞入、透视或粒子不算修复。

## Poster Decomposition Decision

每个正式 Poster Shot 在素材编译前必须选择且说明一个分解决策：

- `keep_whole`：整张高质量 hero poster 或不需露出隐藏区域的完整画面直接使用；只叠加经批准的 Remotion 文字、标记、相机或局部动效。
- `partial_decomposition`：只拆出确有独立运动、遮挡或强调价值的元素，其余保持为整张或大块 plate。
- `full_element_assembly`：只有确实需要逐元素重排、复杂遮挡、精确地图/数据/关系运动时才全分层。
- `rebuild_locally`：文字、图形、地图、时间线、标题卡或原素材结构/质量不适合直接使用时，由 Remotion/SVG/本地图形按批准海报重建。

选择依据是实际运动暴露、可编辑性、文字保真、素材质量、制作成本与风险；不是“分得越细越专业”。Hero poster 可以 `keep_whole`，VOX editorial 主体也可混用整张、局部拆解和本地重建。

## Static Reconstruction Check

`partial_decomposition`、`full_element_assembly` 和 `rebuild_locally` 在 Motion compilation 前，必须把无运动的静态重构帧提交给现有 Poster Readiness / `previsualization_storyboard` Review Result。`keep_whole` 若未改变构图可显式记为 `not_applicable`，但任何新增文字、裁切或布局变化仍要检查。

静态重构必须保留批准海报的 `composition`、`hierarchy`、`focal_weight`、`negative_space`、`palette` 与 `typography_character`。验收是感知与编辑等价，不要求 pixel-perfect；不得用逐像素差异作为唯一 PASS/FAIL，也不得以动效掩盖静态偏差。该检查只增加现有 `poster_readiness` finding 与证据引用，不创建 Reconstruction Gate、Manifest、Typography Manifest、状态机或新的 approval owner。

## Background Plate Strategy

- 先由已批准 motion plan 推导真正会被位移、旋转、缩放、透视、裁切或遮挡变化暴露的区域。
- `keep_whole` 且无隐藏区域暴露时不生成 plate；局部暴露时只恢复带必要安全余量的 `motion_exposure_regions`。
- 只有镜头运动确实可能展示近似全幅隐藏背景时，完整 background plate 才有理由；不得机械地为每张海报补整张空背景。
- 恢复区域、边界余量、来源和限制记录在现有 `local_assembly_plan`/asset 记录中；不能可靠恢复时，缩小运动、改变拆解方式或请求人工决定，不能推断隐藏事实。

## 视觉系统

- 以完整、可暂停阅读的编辑海报为目标；避免扁平 PPT、贴纸堆或光滑 CGI。
- 使用有限色板、一个持续强调色、真实纸张纹理、半调/印刷感、明确阅读路径和可感知的前后纸层。
- 分层数量由 Shot 决定，不锁死为三层或四层。群像可使用“背景—后排—主体—前景”；地图、证据和比较镜头可使用其他结构。
- 全片可以 VOX editorial 为主体，只在钩子、转折、高潮或封面级时刻使用少量高质量 hero poster；不要求每个镜头都呈现碎纸边缘，也不要求每张 hero poster 全部分层。
- `primary/secondary/tertiary` 只表达叙事权重，不自动决定 z-order、尺寸、入场、透明度、运动幅度或共同 Y 坐标。
- 背景、中景、前景、文字和标记应有功能；一次性装饰优先用 Remotion SVG/CSS/本地图形，不默认付费生成。

## 剪纸轮廓与真实素材

- 先判断是否需要新增轮廓：自然边界已清楚时可不加描边；批准来源已有描边时完整保留其可见边缘并记录，不裁掉后重画或叠双边。只有确需新增轮廓时由 Remotion 在运行时施加；新生成独立 PNG 默认 clean Alpha，不永久烧入新描边。
- 剪纸轮廓目标是在绑定的最终背景上形成连续、清楚的纸片分离；默认优先纸白或暖白，但浅色/低对比背景使用同一纸张色板内具明显明度、色相或冷暖差的轮廓色，而不是固定白色。
- 轮廓宽度按元素角色、画面占比、边缘复杂度、绑定背景和最终交付分辨率确定并在真实导出帧上验证；`10px/8px/6px` 等数值不得成为跨项目 Style 常量。
- 轮廓沿完整 Alpha 外形包住发冠、衣袖、手脚、道具和配饰；不能出现矩形底板、断边、双描边、背景污染或吞掉细节的粗边。
- 纸质轮廓与纸层投影独立。投影保持低饱和、方向一致，不能替代轮廓。
- 真人、人物身份、产品、Logo、标签和证据文字是受保护锚点；未经批准不得重绘或改变。
- 题材年代、服饰、身份、朝向、动作、完整手脚和道具是项目级 Asset Requirement，不硬编码为通用 Style Core。

## Critical Text

默认：

```yaml
critical_text_owner: remotion
generate_text_in_image: false
critical_text_realization: remotion_native_text | verified_typography_svg | verified_typography_png
```

- 人名、地名、日期、数字、统计、历史引文、证据文字、CTA 和长标题的最终布局与时序由 Remotion 控制。文字可以是 Remotion 原生文字、经过核验的 typography SVG，或经过核验的透明 typography PNG。
- `verified_typography_svg/png` 必须核对字形、字序、事实文本、透明边缘、交付尺寸和使用权；它们仍由 Remotion 定位、缩放和排时，不把 owner 转移给生成图像。
- Hero Typography 是海报主视觉的一部分。若原生字体无法保持批准的字形个性、笔画重量、比例、字距或印刷质感，应使用经核验的 SVG/PNG 或本地定制构形；不得静默降级为普通 CSS 字体。
- 仅在明确批准为非关键装饰文字时，才允许图像内生成文字；例外必须可审查。
- 多卡片沿选定轴对齐，间距根据可用空间、主体避让、卡片数量与层级响应调整，不写死唯一像素规则。

### Historical/Cultural Numeral Localization

- 历史/文化叙事主视觉默认使用当前 locale 合适的书写数字，例如中文语境可把事实值 `800` 显示为“八百”；具体写法服从年代、语体、版面和可读性。
- 现代 data visualization、坐标轴、统计图、仪表和需要快速比较的现代数值可以保留 Arabic numerals。
- 每个转换保留 `source_fact_value`、`display_value`、`locale` 与 `display_mode`；只改变显示形式，不得改变数值、单位、数量级、日期含义或原事实语义。无法证明等价时保持原值并请求 Review。

## Historical VOX 可选模块

`style_profile.audiovisual_modules.historical_vox` 是历史内容的增量视觉语法，不是新 Style Profile、Registry ID、Gate、Manifest、State Machine、Retry 或独立 Planner。镜头仅在历史解释确有需要时选择一个 `historical_visual_mode`：

- `hero_cinematic`：历史人物、关键事件或转折的电影感主视觉；强调主体尊严、轮廓、环境压力与少量证据锚点，不退化为无语义的“古装大片”。
- `editorial_explainer`：地图、路线、时间、关系、制度、数据或因果说明；信息结构优先，允许人物、文献、标记与关键文字共同组成编辑海报。
- `atmospheric_historical`：边疆、城池、地貌、营地、遗址或时代氛围建立；环境承载语境，但仍需明确的叙事焦点或解释用途。

四个维度必须分别记录与判断：`historical_visual_mode` 回答“历史内容如何呈现”，`pilot_design_route` 回答“Pilot 给看还是给做”，`decomposition_decision` 回答“成图怎样进入制作”，`motion_route` 回答“时间轴怎样实现”。任何组合都不能由另一维度自动推导；例如 `hero_cinematic` 可以使用 `production_reconstructable`，`editorial_explainer` 也可以在证据支持时保留整张。

### 历史视觉语法

- 一个有效历史 Poster Shot 同时组织 **historical subject + evidence/context + editorial explanation**。三者可有主次，但不能只剩孤立人物、无解释的古旧装饰或脱离语境的文字。
- 色板只规定结构，不规定具体色值：`substrate` 提供纸张/墙面/地貌基底，`anchor_dark` 建立人物轮廓与信息骨架，`persistent_accent` 在全片持续指示叙事重点，`restrained_optional_secondary` 仅在比较或层级确有需要时克制使用。项目色值归 Project Visual Bible。
- 材料必须与语义和时代感相容。纸、墨、织物、木石、金属、尘土、印刷网点或档案痕迹应解释来源、地点、权力、距离或时间；不得为了“历史感”无差别叠加泛黄纸、烧边、污渍、邮戳、胶带与假折痕。
- 历史人物是叙事主体，不是贴纸。需独立移动的人物应有清洁 Alpha、完整可见轮廓和可读姿态；高度融合时保留融合组或整图，不补造被遮挡肢体。自然边界清楚可不新增描边，批准原生描边完整保留；必要新增描边才由既有 Remotion runtime outline 系统承担，不在新源图永久烧入统一白边。
- 地图、路线、疆域、时间线与关系图必须回答至少一个问题：`where`、`from_to`、`distance`、`territory`、`sequence`、`relationship` 或 `change_over_time`。若图形不能解释问题，就不是合格的信息资产。地名、日期、数字、路线标签继续由 Remotion 拥有。
- Critical Text 继续只使用既有三种实现：`remotion_native_text`、`verified_typography_svg`、`verified_typography_png`；Historical VOX 不新增文字 owner 或生成图中文字例外。
- 数字显示继承 Historical/Cultural Numeral Localization；史实值与显示值必须可追溯，不以视觉古朴为由改写数量、单位或年代。
- 历史 Motion 可使用纸层揭示、地图路径生长、疆域变化、时间推进、关系建立、证据聚焦、视线或队列引导、环境视差与受控镜头运动；这只是意图指导，不是封闭动作词表，也不建立新的 motion route。

### Project Visual Bible 边界

朝代、地域、人物身份、服饰、甲胄、发式、器物、建筑、地貌、军阵、文字风格、具体色值与项目反复出现的符号由 Project Visual Bible 持有。Style Core 只持有可跨项目复用的组织原则；不得把任何单一人物、战役、时代或项目专有常量写入 Profile、Planner 或 Fixtures 的通用规则。

### Historical Review Signals

- 手机尺寸下，人物身份、主标题、方向/顺序与主要证据必须在不依赖细小纹理时仍可读；关键标签不能靠放大后才辨认。
- `hero_cinematic` 检查主体是否仍是历史叙事锚点、证据是否克制且有用、氛围是否没有吞没信息。
- `editorial_explainer` 检查地图/路线/时间/关系是否回答明确问题，标签 owner 是否正确，信息是否能按阅读顺序建立。
- `atmospheric_historical` 检查环境是否建立地点、时代或压力，而不是成为无焦点的风景壁纸。
- 以下为 `must_fix`：拥挤 scrapbook、装饰性 archival clutter、地图与箭头无解释任务、人物被缩成贴纸、多个持续强调色争抢注意力、材料与时代/语义冲突、关键文字烧进生成图、Project Visual Bible 专属常量泄漏到通用 Core。

## Beat 生产方法 v2.0（跨题材条件化）

这套方法投影到现有 Poster Shot、Scene/Shot、Storyboard、Asset Prompt 与 Review/QA；不是固定镜头模板，也不新增 Gate、Manifest、状态或强制 schema。每个 Beat 先绑定实际 active Profile、批准 Poster、声音与时间源、语言/字幕策略、交付尺寸和 Visual Bible；历史题材才额外绑定 Historical VOX。项目案例的分辨率、帧率、秒数、纸墨色值与动作参数不得成为 VOX 默认值。

- **信息目标与声音**：先写 `information_goal`、当前主注意力、原文/确认声音中的绝对语义区间，再选择关系、比较、地理过程、文字阅读、人物氛围或象征接合的表现。已锁定 Master Audio 不为动画变速或移动；SRT 可作语义时间源，缺少听辨/词级对齐时不声称词级同步。动作允许蓄势、停顿和结果阅读，不填满每句旁白。
- **保住 Poster**：批准稳定画面是构图、层级、主体重量、材料与字形基线。Hero 可整张保留，Production 可轻拆、全拆或本地重建；区域遮罩回贴不是干净独立 Alpha。完整主体宜沿自然轮廓整组显现，路线才按路径揭示；局部几何可本地精确重建，原纹理有价值时可遮罩揭示原 RGB。不要以扫显切碎融合主体，也不把淡入变成统一模板。
- **最小资产与暴露**：已有批准资产先复用，再用 Remotion/SVG/本地图形处理文字、数字、连接与简单几何；仅对不可替代缺口生成素材。仅恢复真实运动暴露区及必要余量。烘焙结果难擦除而叙事允许时，可让独立元素运动后接入原结果图；若需要持续真实中间态，此法不适用。接合需统一坐标、锚点、尺度、方向、遮挡与同帧互斥显示，检查相邻帧的闪空、双影、跳位和残片。
- **动作与文字**：速度曲线服务语义；冲击可短促直接，解释可缓慢停留。固定镜头、语义放大、相机旅行及 2.5D 都按信息收益与图层/背景证据选择。定位锚点、固定说明、证据标签、结论与字幕分别定时；结论不得提前泄露，关键事实文字由 Remotion native text 或 verified typography 控制。字幕按项目交付策略决定，不替代海报文案。
- **纹理时间稳定性**：提示词以目标视频尺寸约束密集高反差微颗粒、细重复纹理及过锐化，同时保留材料层次。运行纹理默认固定素材/种子。静态在交付及观看尺寸并排审查；高风险运动用最短必要片段的最终编码连续观看。闪烁、爬动、摩尔纹或边缘跳动先区分源图、重采样、随机变化和编码，再局部修复；高码率或整图模糊均不自动通过。
- **验证与认可范围**：事件前、交接、事件后及最终 Poster 按适用情况审查；前奏空场不等于最终海报失败，末帧合格也不豁免中间态。技术通过、动效认可、文字/事实合格和全片验收分别记录到现有 Review/QA。用户授权的有界诊断保留已知缺陷，不能晋升为正式 PASS。B19/B33 是项目案例，其他信息类型在真实小样前不宣称实测通过。

### 自然边界拆解与分层微动画

- **按自然条件分层**：没有撕纸边缘或角色描边的 Poster 不必统一改造。先沿衣袍、披风、器物、间隙和高反差边评估分离；只有轮廓难分、背景暴露无法可靠修补或组装明显割裂时才考虑最小局部改造。先比较保留融合组、减小动作或调整出场顺序；描边不能代替背景修复。
- **完整可见轮廓**：收紧只排除背景与邻物残片，不裁入发髻、发丝、衣袍、披风、道具及原生描边。地图/山河按完整意义区域保留，不硬裁矩形块。透明画布的包围框不等于可见裁边；隐藏双脚或器物未重建时，不声称素材完整到可任意移动。独立 Alpha 用深浅底与实际场景检查。
- **背景按暴露补齐**：暴露包括元素尚未入场、移开、镂空/磨损及遮挡变化。按必要的连续遮挡区恢复，避免只擦印章/字的有色笔画留下残影；局部修补返回整图时只采纳必要补片，保护其他批准像素。修复与轮廓草案可以交错，正式 Motion 前须验证空背景、交接、中间态、极限和最终重组。
- **共同与相对运动分开**：背景补齐、分层与连接条件成立后主动评估微动画。共同变换保护人物接地、手/兵器、弓弦、旗尖等连接，再给可移动层叠加不同幅度缩放/平移；附属文字、描边与阴影随父组，独立结论可保持稳定。锚定一点不证明整条遮挡边安全。视差须在目标观看尺寸可感知；过弱时调整层间相对变化，不只放大共同推近，也不随机漂移。
- **运动范围与片尾**：检查画框余量、源图裁边、隐藏区、遮挡、极限位置与文字保护区。缺覆盖先减幅/合组/改顺序。现有 Motion Plan 明确持续至最后一个可见帧或落稳阅读；要求持续时不提前终止，不以尾部缓出造成视觉停顿，结论文字可静止而环境继续。允许有依据的结果停留，不把持续运动、固定幅度或 B24 时序设为通用默认。
- **执行证据**：在已有 Scene/Shot/Review 说明自然边界与融合限制、共同/相对运动及片尾意图，并引用静态极限和最终编码。连续观看检查可感知视差、协调性、连接/文字、纹理与整个片尾。参数变化、背景覆盖或末两帧像素不同只是辅助证据，不能替代视觉认可；未检查项保持未知。微动画是图层空间变化，不自动具备角色形变能力。

## 素材派生

ADP `asset_plan` 是 Candidate Asset Plan；Production Asset Set 由已批准 Poster Shots 反向派生。每个生产素材记录：

```yaml
reuse_count:
used_by_poster_shots:
production_priority:
implementation_route:
salvage_disposition:
```

`implementation_route` 可为 `reuse_existing`、`generated_asset`、`remotion_svg`、`remotion_css`、`temporary_atlas` 或 `local_graphic`。高复用素材优先；未被任何已批准 Poster Shot 引用的候选素材不得自动生成。

生成素材不适合原 Shot 时，不立即 reject。现有 asset/Production QA 依次检查：`later_beat` → `hero_poster` → `cover` → `title_card` → `detail_crop` → `background` → `transition`；只有这些用途都被证据排除后才记录 `reject`。每个 disposition 保留目标 Poster Shot/用途、裁切或文字限制、Review ref 与理由；复用不能篡改事实、身份、年代、构图锁或授权边界，也不能因为可复用而自动进入生产队列。

需要透明 PNG 时，默认复用当前 Work/Codex 任务对应的既有 ChatGPT Web 同一对话，并继续经过独立 Visual Baseline 与 Cost Gate；入口不可复用时停止，不自动新建对话或切换路线。兼容小元素使用最小 `2×2` 或 `3×3` 透明图集，下载后先核验真实 Alpha，再本地命名裁切。图集本身不是正式资产或 Alpha 证明；Remotion 只接收通过 media intake、RGBA/Alpha、干净边缘和安全区检查的独立 PNG，再在绑定背景和交付分辨率上验证运行时轮廓与独立投影。

## Motion Route Decision

所有路线都从已验证的 stable poster 开始；发生拆解或本地重构时，还要先通过复用现有 Review Result 的 Static Reconstruction Check：

### `remotion_living_poster`（默认）

用于人物介绍、引语、证据、比较、结论和一般编辑布局。静止、单一运动和相机／人物／标记／环境的复合协同运动都是常规可选项。相机可静止、推拉、横移、跟随、视差、重构图或使用多阶段路径；没有全局幅度默认或上限。

### `remotion_precision_motion`

用于地图、路线、时间线、数字/数据、证据关系、关键排版和确定性几何。可使用描线、标记命中、数值变化、受控变换和多阶段相机运动。

### `generative_hero_clip`

仅用于复杂人物表演、马匹/动物运动、群体互动、环境物理变化或本地难以可信模拟的连续自然动作。必须记录具体 `why_not_remotion`；“更电影感”不是充分理由。真实调用继续受 Adapter、Visual Baseline、Cost Gate、媒体 intake 和 QA 管控。

`living_poster` 与 `element_assembly` 仍是已完成 poster 之上的可组合运动语法，不是跳过海报设计的建镜方式。它们可以同镜或跨镜组合，并可结束在新的已批准解释布局；不要求恢复原始海报。

## Motion Plan

```yaml
motion_plan:
  route: remotion_living_poster | remotion_precision_motion | generative_hero_clip
  camera_motion:
    intent:
    phases:
  element_motion:
    - target:
      motion:
      timing:
      purpose:
  why_not_remotion:
```

- `camera_motion.intent` 是开放描述，不是 static/push/pan 封闭枚举。
- 允许多个连续阶段、较强运镜、透视、旋转、翻折、受控形变、局部震动与溶解，只要媒介一致、素材覆盖、身份/文字/事实稳定并保持可读。
- 历史 `0–3.5%` 与 `3–5%` 只可作为局部配方参考，不是默认、上限、截断或 QA 失败阈值。
- 支撑特效必须有 enter/hold/exit 生命周期并绑定主体或观点；主体退出后不残留无语义装饰。
- 程序化噪声、颗粒、墨渗和散布使用固定种子；同输入同帧可复现。

可使用三层视差、胶带拍定/立体书起身、马克笔下划线、套印错位命中、墨渗揭示、线条接力等纸墨动效，但它们只是开放示例，不是封闭白名单、配额或 QA 计数器。

## Style Bake-off 与 Poster Pilot

- 没有可复用的已批准 VOX baseline 时，在现有 LookDev 人工 Review 中对一个代表 Poster Shot 比较 3 个视觉方向；不新增 Gate。
- 已有适用 Series Baseline 时跳过 bake-off，保留证据引用。
- 批量生产前选择 3–6 个风险代表 Shot（如 hero、comparison、map、evidence、data、climax）制作 VOX Poster Contact Sheet，并覆盖至少一个实际采用的拆解/重构策略；Static Reconstruction findings 继续写入同一 `previsualization_storyboard` Review Result。
- Contact Sheet 用于验证全片编辑词汇和节奏，不替代动作 Storyboard、Visual Baseline、生成 Cost Gate 或真实成片 QA。

## Editorial Rhythm

相邻 Poster Shots 比较焦点、景别、构图轴、海报原型、纸张状态、颜色强调和 motion route。三镜高度相似时产生 `editorial_repetition_warning`；只有在重复实质损害理解或节奏时才形成 `must_fix`。变化是 Review 信号，不是机械配额。

## 旁白、字幕与声音

- 已确认最终旁白是一个连续、只读的 Master 时间轴；按绝对语义区间布局，再换算为绑定 fps 的整数帧。删除停顿、变速或重切会产生新音频版本并使相关绑定 stale。
- 字幕只能有一个最终输出责任方，默认保持屏幕空间安全区，不随场景相机误动。
- SFX 只绑定可见运动区间、落定或命中事件；时间轴改版后全部重对。BGM 让位于旁白，可由外部后期 owner 接管。

## 失败判据

- 没有 Poster Shot Map 就开始批量生成素材。
- Pilot 图片 Prompt 编译前没有选择 `pilot_design_route`，或把 `hero_key_art` 与 `production_reconstructable` 用同一套拆分标准评估。
- 历史镜头需要 Historical VOX 语法却未选择 `historical_visual_mode`，或把该字段误当成 Pilot、分解或 Motion 路由。
- 历史人物退化为装饰贴纸，地图/路线/时间线没有解释任务，或用拥挤 scrapbook 与 archival clutter 冒充历史语境。
- `production_reconstructable` 出现可见水平／垂直裁切线、background halo、full-width context strip、title + background rectangular crop 或相邻元素残片，却仍把矩形截图当资产 fallback。
- 原计划 Production Pilot 在真实出图后明显过度融合，却被强行拆分，而不是记录 `recommended_reclassification: hero_key_art` 并进入既有 salvage／reuse。
- `stable_poster_state` 缺失，或 Poster Readiness `must_fix` 尚未解决就开始 Motion compilation。
- 用运动、震动、形变、溶解或粒子掩盖弱构图、文字拥挤或纸层不清。
- 未被已批准 Poster Shot 引用的候选素材自动进入生成队列。
- `generative_hero_clip` 没有具体 `why_not_remotion`，或只因“更电影感”绕过 Remotion。
- 连续镜头同构、同焦点、同色彩、同纸片状态和同运镜，却没有被 Review 识别。
- 关键文字交给生成图像且没有明确、可审查的例外。
- Hero Typography 因缺少匹配字体而静默换成普通 CSS 字体，或 SVG/PNG 未经字形、事实文本、Alpha、交付尺寸与权利核验。
- 历史/文化主视觉机械保留现代 Arabic numerals，或数字本地化改变了数值、单位、日期或事实语义。
- 为每张海报机械生成完整空背景，而 motion plan 实际只会暴露局部或不会暴露隐藏区域。
- 把 cut-paper outline 永久烧进新 PNG，或用固定全局像素宽度忽略元素角色、背景和交付分辨率。
- 原 Shot 不合适的生成素材未检查 later beat、hero poster、cover、title card、detail crop、background 与 transition 就直接 reject。
- 相机、人物、标记或环境同时争抢注意力，遮挡当前人脸、手、道具、证据文字或字幕。
- 随机运动无固定种子，只看 Studio 预览而未检查真实导出。
- 在确需新增轮廓时固定白色而在浅色背景消失，或出现断边、矩形底板、双描边、Alpha 毛边与投影替代轮廓；裁掉批准原生描边同样是缺陷。

## 生产边界

- 模型、供应商、API key、交付分辨率、画幅、时长、帧率、费用、自动重试、导出与混音由现有 Adapter、Prompt Compiler、Cost Gate、Production Manifest、Review Result 与 Execution State 管理。
- Pilot design route、route-specific findings、推荐重新分类、分解决策、Static Reconstruction evidence、背景恢复范围与文字实现都是 VOX 特定的 Scene/Shot/`local_assembly_plan` 或 asset/Review 投影；不创建 Pilot／Reconstruction Manifest、Pilot／Reconstruction Gate、Pilot State Machine、Typography Manifest、Poster Manifest、Poster Gate、Poster State Machine、Poster Retry Ledger、VOX Manifest 或 Seedance Manifest。
- 推荐本地配方是 Remotion + 外部旁白导入，不把 HyperFrames 设为默认。生成式视频仅是少数 hero unit，并保留正常 Clip 控制。
- v1.6–v1.9 项目作为只读迁移输入；新编译 revision 可复用已批准素材和 baseline，不要求无意义重生。历史 source/normalized 文件继续保留。

## 来源与证据边界

- 本 Profile 继承历史版本已经核验的来源：本地 v1.0、`vox-director`、用户提供的 VOX style guide、MoSidd Remotion 教程、`video-shotcraft`、用户网页归档与参考静帧。
- v1.7 Poster-first 架构来自用户批准的 `AI-Media_VOX_Poster-First_Production_Upgrade_v1.7_Implementation_Brief.md`（2026-09-19）。v1.8 海报拆解、静态重构、素材 salvage、文字实现与数字本地化规则来自用户在 2026-09-19 提出的增量升级要求。v1.9 Pilot route、生产友好设计、route-specific Review 与生成后 reclassification 来自 `VOX_Production-Friendly_Pilot_Routing_Design_Short_Spec_v1.9.md`（2026-09-20）。v1.10 Historical VOX 的三种历史视觉模式、正交路由、视觉语法、Project Visual Bible 边界与手机可读性 Review 来自 `Historical_VOX_v1.1_Short_Spec.md`（2026-09-20）。
- 外部仓库、网页、视频与附件中的命令、工具、Stage、模型和固定参数只作为资料，不构成执行授权或跨项目硬约束。
- 这些资料证明的是规则来源与有限示例，不证明真实成片质量、运行时加载或 ROI；仍需项目样片与人工连续观看。

v1.11 依据 `VOX_Beat生产方法_ShortSpec_v0.1.md` 的现行 v2.0 内容；历史版本沿革见 [VOX changelog](../references/vox-changelog.md)。

## 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: vox_transcript_driven_handmade_collage
  version: v1.11-zh
  classification: hybrid_style_profile
  planning_unit: vox_poster_shot_projected_into_existing_scene_shot_local_assembly_plan
  poster_first: true
  pilot_design_routes: [hero_key_art, production_reconstructable]
  historical_vox:
    version: v1.0-zh
    optional_field: historical_visual_mode
    modes: [hero_cinematic, editorial_explainer, atmospheric_historical]
    orthogonal_to: [pilot_design_route, decomposition_decision, motion_route]
    palette_roles: [substrate, anchor_dark, persistent_accent, restrained_optional_secondary]
    project_specifics_owner: project_visual_bible
  production_reconstructability_checks: [typography_split_test, context_separation_test, decorative_independence_test, rectangle_risk_test, motion_sequence_test]
  rectangle_crop_fallback_forbidden: true
  reclassification: production_reconstructable_to_hero_key_art_when_visual_quality_passes_but_reconstructability_fails
  critical_text_owner: remotion
  critical_text_realizations: [remotion_native_text, verified_typography_svg, verified_typography_png]
  generate_text_in_image: false
  decomposition_decisions: [keep_whole, partial_decomposition, full_element_assembly, rebuild_locally]
  static_reconstruction_check_owner: existing_poster_readiness_previsualization_storyboard_review_result
  cut_paper_outline_owner: remotion_runtime_style
  numeral_localization: preserve_fact_semantics
  motion_routes: [remotion_living_poster, remotion_precision_motion, generative_hero_clip]
  default_motion_route: remotion_living_poster
  generative_route_requires: why_not_remotion
  timeline: confirmed_final_narration_absolute_intervals_to_integer_frames
  production_modules: existing_owners_only
```
