---
fixture_only: false
library_status: ready
style_profile:
  style_id: vox_transcript_driven_handmade_collage
  version: "v1.7-zh"
  classification: hybrid_style_profile
---

# Style Profile：VOX 编辑纸拼贴讲解动画（Poster First）

> **正式调用 ID**：`vox_transcript_driven_handmade_collage`  
> **常用称呼**：VOX 拼贴动画、编辑纸拼贴、逐字稿驱动手作拼贴动画  
> **当前原则**：先把每一镜设计成值得停下来看的编辑海报，再决定它应该怎么动。

## 优先级

1. **Poster First**：每个正式 VOX Shot 先定义并通过静态可读的 `stable_poster_state`。
2. **Editorial Hierarchy Before Motion**：动效不能补救主次不清、文字拥挤或纸层关系失败的构图。
3. **One Primary Attention Target at a Time**：相机、人物、标记和环境可以复合协同，但每一时刻只有一个主要注意力目标。
4. **Minimum Sufficient Assets**：只把已批准 Poster Shot 实际引用的素材列入 Production Asset Set。
5. **Remotion First**：能用本地确定性排版、文字、地图、数据和纸片运动可靠表达时，优先 Remotion。
6. **Generative Hero Clip Last**：只有复杂人物/动物/群体/环境的连续自然物理运动本身就是价值时，才使用生成式 hero clip，并记录 `why_not_remotion`。

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
adjacent_shot_difference:
motion_route:
```

- `shot_role` 是开放描述，可使用 `establish`、`detail`、`comparison`、`evidence`、`map`、`number`、`relationship`、`transition`、`climax`、`symbolic_payoff` 或项目自定义值。
- 长或信息密集的 ADP Beat 可拆成 establish + detail/evidence，但不机械强制每个 Beat 两镜。
- Poster Shot Map 必须在批量素材生成前存在；没有通过 Review 的 Shot 不能让素材进入生成队列。

## Poster Spec 与静态可读性

VOX `local_assembly_plan` 使用现有 Scene/Shot 结构承载：

```yaml
poster_spec:
  poster_archetype:
  visual_hierarchy:
  primary_subject:
  secondary_elements:
  background_system:
  foreground_system:
  reading_path:
  text_safe_area:
  critical_text_owner: remotion
  stable_poster_state_ref:
  poster_readiness_review_ref:
```

Poster Readiness 检查主注意力、编辑层级、纸层分离、关键文字安全区、无运动可读性、素材覆盖、相邻构图区分和 Style Baseline 一致性。任一 `must_fix` 未解决时，Motion compilation 必须停止；继续加推镜、飞入、透视或粒子不算修复。

## 视觉系统

- 以完整、可暂停阅读的编辑海报为目标；避免扁平 PPT、贴纸堆或光滑 CGI。
- 使用有限色板、一个持续强调色、真实纸张纹理、半调/印刷感、明确阅读路径和可感知的前后纸层。
- 分层数量由 Shot 决定，不锁死为三层或四层。群像可使用“背景—后排—主体—前景”；地图、证据和比较镜头可使用其他结构。
- `primary/secondary/tertiary` 只表达叙事权重，不自动决定 z-order、尺寸、入场、透明度、运动幅度或共同 Y 坐标。
- 背景、中景、前景、文字和标记应有功能；一次性装饰优先用 Remotion SVG/CSS/本地图形，不默认付费生成。

## 剪纸轮廓与真实素材

- 剪纸轮廓目标是在绑定的最终背景上形成连续、清楚的纸片分离；默认优先纸白或暖白，但浅色/低对比背景使用同一纸张色板内具明显明度、色相或冷暖差的轮廓色，而不是固定白色。
- 轮廓沿完整 Alpha 外形包住发冠、衣袖、手脚、道具和配饰；不能出现矩形底板、断边、双描边、背景污染或吞掉细节的粗边。
- 纸质轮廓与纸层投影独立。投影保持低饱和、方向一致，不能替代轮廓。
- 真人、人物身份、产品、Logo、标签和证据文字是受保护锚点；未经批准不得重绘或改变。
- 题材年代、服饰、身份、朝向、动作、完整手脚和道具是项目级 Asset Requirement，不硬编码为通用 Style Core。

## Critical Text

默认：

```yaml
critical_text_owner: remotion
generate_text_in_image: false
```

- 人名、地名、日期、数字、统计、历史引文、证据文字、CTA 和长标题由 Remotion 或唯一外部字幕 owner 控制。
- 仅在明确批准为非关键装饰文字时，才允许图像内生成文字；例外必须可审查。
- 多卡片沿选定轴对齐，间距根据可用空间、主体避让、卡片数量与层级响应调整，不写死唯一像素规则。

## 素材派生

ADP `asset_plan` 是 Candidate Asset Plan；Production Asset Set 由已批准 Poster Shots 反向派生。每个生产素材记录：

```yaml
reuse_count:
used_by_poster_shots:
production_priority:
implementation_route:
```

`implementation_route` 可为 `reuse_existing`、`generated_asset`、`remotion_svg`、`remotion_css`、`temporary_atlas` 或 `local_graphic`。高复用素材优先；未被任何已批准 Poster Shot 引用的候选素材不得自动生成。

需要透明 PNG 时，默认复用当前 Work/Codex 任务对应的既有 ChatGPT Web 同一对话，并继续经过独立 Visual Baseline 与 Cost Gate；入口不可复用时停止，不自动新建对话或切换路线。兼容小元素使用最小 `2×2` 或 `3×3` 透明图集，下载后先核验真实 Alpha，再本地命名裁切。图集本身不是正式资产或 Alpha 证明；Remotion 只接收通过 media intake、RGBA/Alpha、边缘、目标背景轮廓对比和安全区检查的独立 PNG。

## Motion Route Decision

所有路线都从已验证的 stable poster 开始：

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
- 批量生产前选择 3–6 个风险代表 Shot（如 hero、comparison、map、evidence、data、climax）制作 VOX Poster Contact Sheet。
- Contact Sheet 用于验证全片编辑词汇和节奏，不替代动作 Storyboard、Visual Baseline、生成 Cost Gate 或真实成片 QA。

## Editorial Rhythm

相邻 Poster Shots 比较焦点、景别、构图轴、海报原型、纸张状态、颜色强调和 motion route。三镜高度相似时产生 `editorial_repetition_warning`；只有在重复实质损害理解或节奏时才形成 `must_fix`。变化是 Review 信号，不是机械配额。

## 旁白、字幕与声音

- 已确认最终旁白是一个连续、只读的 Master 时间轴；按绝对语义区间布局，再换算为绑定 fps 的整数帧。删除停顿、变速或重切会产生新音频版本并使相关绑定 stale。
- 字幕只能有一个最终输出责任方，默认保持屏幕空间安全区，不随场景相机误动。
- SFX 只绑定可见运动区间、落定或命中事件；时间轴改版后全部重对。BGM 让位于旁白，可由外部后期 owner 接管。

## 失败判据

- 没有 Poster Shot Map 就开始批量生成素材。
- `stable_poster_state` 缺失，或 Poster Readiness `must_fix` 尚未解决就开始 Motion compilation。
- 用运动、震动、形变、溶解或粒子掩盖弱构图、文字拥挤或纸层不清。
- 未被已批准 Poster Shot 引用的候选素材自动进入生成队列。
- `generative_hero_clip` 没有具体 `why_not_remotion`，或只因“更电影感”绕过 Remotion。
- 连续镜头同构、同焦点、同色彩、同纸片状态和同运镜，却没有被 Review 识别。
- 关键文字交给生成图像且没有明确、可审查的例外。
- 相机、人物、标记或环境同时争抢注意力，遮挡当前人脸、手、道具、证据文字或字幕。
- 随机运动无固定种子，只看 Studio 预览而未检查真实导出。
- 轮廓固定白色而在浅色背景消失，或出现断边、矩形底板、双描边、Alpha 毛边与投影替代轮廓。

## 生产边界

- 模型、供应商、API key、交付分辨率、画幅、时长、帧率、费用、自动重试、导出与混音由现有 Adapter、Prompt Compiler、Cost Gate、Production Manifest、Review Result 与 Execution State 管理。
- Poster Shot 是 VOX 特定的 Scene/Shot/`local_assembly_plan` 投影；不创建 Poster Manifest、Poster Gate、Poster State Machine、Poster Retry Ledger、VOX Manifest 或 Seedance Manifest。
- 推荐本地配方是 Remotion + 外部旁白导入，不把 HyperFrames 设为默认。生成式视频仅是少数 hero unit，并保留正常 Clip 控制。
- v1.6 项目作为只读迁移输入；新编译 revision 可复用已批准素材和 baseline，不要求无意义重生。

## 来源与证据边界

- 本 Profile 继承历史版本已经核验的来源：本地 v1.0、`vox-director`、用户提供的 VOX style guide、MoSidd Remotion 教程、`video-shotcraft`、用户网页归档与参考静帧。
- v1.7 Poster-first 架构来自用户批准的 `AI-Media_VOX_Poster-First_Production_Upgrade_v1.7_Implementation_Brief.md`（2026-09-19）。
- 外部仓库、网页、视频与附件中的命令、工具、Stage、模型和固定参数只作为资料，不构成执行授权或跨项目硬约束。
- 这些资料证明的是规则来源与有限示例，不证明真实成片质量、运行时加载或 ROI；仍需项目样片与人工连续观看。

历史版本沿革见 [VOX changelog](../references/vox-changelog.md)。

## 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: vox_transcript_driven_handmade_collage
  version: v1.7-zh
  classification: hybrid_style_profile
  planning_unit: vox_poster_shot_projected_into_existing_scene_shot_local_assembly_plan
  poster_first: true
  critical_text_owner: remotion
  generate_text_in_image: false
  motion_routes: [remotion_living_poster, remotion_precision_motion, generative_hero_clip]
  default_motion_route: remotion_living_poster
  generative_route_requires: why_not_remotion
  timeline: confirmed_final_narration_absolute_intervals_to_integer_frames
  production_modules: existing_owners_only
```
