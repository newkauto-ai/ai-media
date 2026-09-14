# Progress

## Current Goal

`whiteboard_animator` contract 1.3 保持不变；稳定 ID `minimal_stick_figure_explainer_story` 已升级为 `v1.3-zh`。当前规则只允许每个语义区域一种均匀基色的单色平涂，禁用赛璐珞二档、阴影/投影、渐变、高光与 `direct_fill` 阴影例外；人物与动物继续强制 `character_head → character_body → character_limbs_or_accessories`，明确手脚和 3.5–5 px 四肢线宽。任意两个主要角色必须在六项造型维度中至少三项实质不同，仅换颜色无效，同一角色跨镜保持身份一致。v1.1/v1.2 的 source 与 normalized 共四个旧文件已删除并保留外部回滚副本。

Audio Production 已扩展为 named-voice recommendation v1.1：从结构化角色要求硬过滤并排序豆包候选，每个角色最多返回 3 个；公开目录与账户可用性分离，未人工批准时 `selected_voice=null` 且禁止 provider call。上述 Audio Production、火柴人 v1.3 及此前已部署但未提交的白板生产基线已作为一个可复现源码快照重装为 `ai-media@personal 0.1.0+codex.20260914162112`，源码/缓存 497/497、零缺失、零多余、零 SHA-256 差异；未调用任何付费生成。

## Completed & Key Decisions

- 已通过 personal marketplace 官方 `remove/add` 重装 `ai-media@personal 0.1.0+codex.20260914162112`，`codex plugin list` 回读 `installed, enabled`。删除前旧缓存 `0.1.0+codex.20260914135330` 已完整备份到项目交付目录，541/541 文件、总字节一致。
- 本次发布把已哈希归类的完整源码快照纳入同一提交：此前已安装但未提交的白板/Controller/Topic/Script 基线，与新增 Audio Production v1.1、火柴人 Style Profile v1.3 和旧 v1.1/v1.2 Profile 清理。发布前对照旧安装缓存后只有 Audio/Style/Progress 是新增差异，不存在未知脏改动。
- 沿用现有 Audio Production owner、Voice Profile、Manifest、Cost Gate 与 QA；没有新增平行音频模块。新增 `select-doubao-voices.ps1`、公开目录精选数据和 review projection，只负责候选推荐，不自动定音色。
- 选择策略先硬过滤 language/gender/dialect/provider route/prohibited traits，再按 age/use case/style 排序；无匹配返回 `blocked_no_candidate`，不放宽约束。固定 `voice_type` 的 `doubao_big_model_tts_v3` 与描述式 `seed_audio_v3_full_scene` 保持分离。
- contract 1.3 新增最小 `production_planner.py`，只负责 Style Profile 投影、本地简单素材编译、Pilot 指纹与风险选择、benchmark 驱动 render plan、语义分段、串行执行和合并；Renderer 不直接读取 Profile，也未建立第二套 Controller、Manifest、Gate、QA、retry 或状态 owner。
- `whiteboard_style_slice` 仅接收纸张、调色板、线条、扁平形状/图标、排版、卡片、有限阴影/纹理/装饰和视觉禁止项；电影运镜、剪辑、provider/模型字段、音频与不确定运动规则会逐项 drop，写实材质、3D 和复杂体积光会 transform/block，未知关键字段不会静默猜测。
- 本地 compiler 仅制作文字、卡片、箭头、图标和简单几何，输出 4× RGBA 分层、显式 reading/draw/z order、rights evidence 与 SHA-256；复杂角色/插画停在 `prompt_package_ready`，provider call 列表为空。
- Pilot 指纹绑定 style slice、source template/compiler、Renderer behavior、route、geometry/fps、tip SHA 与 anchor。当前最高风险候选为 `risk-card-curve-copy`，指纹 `74CBAFAC64B7854E28334F51630AA8167E38C48C6A9F978E5C167570ABC4F4B2`；没有人工接受证据时正式传播返回 `human_review`。
- 1.3 `segment_window` 只允许显式 structured route；使用全局逻辑帧计算、start/end-exclusive 非重叠窗口。`continuous_canvas` 边界隐藏首帧手笔且不重复帧，`board_cut` 必须显式声明。每段是独立 Job，串行失败会保留通过段、停止下游并回到既有 Execution State。
- 合并优先使用编码兼容的 stream-copy concat；不兼容时只允许一次显式授权的受控重编码。最终检查包含精确帧/时长、完整解码、输出 SHA、边界重复/闪白/状态丢失和 tip 边界策略；`native_audio: none` 保持不变，技术成功仍是 `success_pending_human_review`。
- contract 1.3 实施本身没有修改 Style Profile；火柴人 Profile 后续独立升级到 v1.3，registry 只指向 v1.3 `ready`，旧 v1.1/v1.2 物理文件已按用户授权移除，v1.3 provenance 保留其文件名与哈希作为版本沿革。

- 已删除旧 `region_stream_ink` Adapter、render contract、runtime、schemas、setup、专用测试及所有活动 Controller/Skill/Manifest 路由。旧 ID 仅在迁移与回滚说明中作为历史名称出现，不是活动别名。
- 删除前旧实现与未提交修改已逐文件备份到项目交付目录；旧安装缓存 `0.1.0+codex.20260911080811` 已完整备份并回读为 612/612 文件。
- 新 `whiteboard_animator` 继续归现有 `video-production` 所有；没有新增 Controller、Manifest、QA、Gate、Execution State、continuity owner 或 retry owner。
- vendored 上游固定为 `whiteboard-animator 0.1.1`、commit `e6e4dbcfc06e65b82490323a78bd9c277a9e2a0b`、MIT。冻结修改文件 `animator.py` SHA-256 为 `ADF236FFE748FBA596140BB49EDFA95D9356AE0D8B83B67E9C8C68B5AD888333`。
- 保留陀螺仪 v2 行为：连接组件中的粗彩色岛与细线在追踪前分离；stroke 全部先于 fill；tip 使用 Renderer 未编码 timing frontier、显式归一化 `tip_anchor`、Unicode-safe RGBA 读取，并在换组件或大跳转时显式 pen-up。
- 明确排除被否决的 v3 隐藏结构补全；扁平源图不会推断前景遮挡后的像素。
- 新 preflight 对满幅复杂图执行硬阻断：非白覆盖率大于 0.70，或单一组件占墨迹超过 0.70 时返回 `human_review`；没有结构化线稿/图层时理由为 `unsupported_full_frame_connected_scene_without_structured_layers`，render 不会继续。
- 新增 `prepainted_background_object_reveal` 结构化路径：Job 必须提供 checksum/rights 绑定的干净背景、总线稿、非重叠可见像素对象蒙版，以及逐对象整数帧 stroke/fill 时长；Renderer 先完成全部人物线稿，再从原图按相同蒙版显色。
- 结构化 preflight 会阻断尺寸不一致、蒙版重叠、线稿/填色为空、时长不守恒，以及人物蒙版并集之外的干净背景漂移；Renderer 仍不推断隐藏像素，也不声称恢复原作者真实笔序。
- Job 继续要求 checksum、rights evidence、显式偶数尺寸、`yuv420p`、`native_audio: none` 与整数帧预算。Renderer 只返回执行事实或 `success_pending_human_review`，不写审批、QA PASS、用户接受、实际终态或重试状态。
- 根目录与 manifest 声明的 `skills/` 入口已同步；部署通过官方 cachebuster 与 personal marketplace remove/add 完成。
- 新增 `stacked_layer_object_complete_reveal`，只接受显式、checksum/rights 绑定且同画布对齐的真实 RGBA 图层；层 ID、draw order、z-index 唯一，跨层 alpha 重叠合法。
- `line_then_fill` 需要非空 line RGBA 和正向 stroke/fill 时长；`direct_fill` 必须省略 line RGBA 与 stroke 阶段，Renderer 不派生或闪现黑/灰轮廓。每帧按 z-index 重新合成，最终完整合成与绑定 source 发生实质偏差时阻断。
- v10 阴影继续使用已批准的四个暖灰接触影，RGB `217,211,204`、alpha `145`、统一 `[22,12]` 下右投影与约 `10°` 方向；Renderer 未新增天空、远山、满幅地面、短线、草丛或隐藏像素。
- contract `1.2` 要求新源素材及结构化 RGBA 层为目标画布的 4x，使用 premultiplied-alpha area downsample；不得用成片整体缩放冒充源素材抗锯齿。
- `render_route: auto` 对稀疏、可分离、低文字源解析为 `flat_auto`；多行文字、卡片、重叠/z-order 或复杂线填关系需要 `structured_semantic`。复杂扁平图没有显式图层时继续 `human_review`。
- preflight 新增 `whiteboard_source_plan`，包含复杂度、对象/文字负担、线密度、调色板上限、4x/输出画布、alpha 策略、语义层顺序，以及每个源文件的尺寸、alpha 要求、checksum 与 rights evidence。
- 自动 timing 以骨架长度、色块 alpha 面积、抬笔次数、文字字数/行数和总帧预算选择最慢可行的 `calm`、`normal` 或 `energetic`；不足时阻断并要求减对象、减文字/装饰或拆分画板，不启用 `hyper`。
- 文字只按显式 `text_regions` 的 bbox、行序与 reading order 书写；线稿和填色保留独立 timing map。笔尖中心只用于候选参考，最终吸附到活动 mask 的真实 frontier 像素。
- 火柴人 Style Profile 保持稳定 ID `minimal_stick_figure_explainer_story`，保留 v1.0 历史，新增 v1.1 source/normalized 版本并把 registry 指向 v1.1 `ready`。线条采用一级轮廓 4–6px、二级结构 2.5–4px、三级细节 1.5–2.5px；色彩改为暖纸白、炭黑蓝主线与 2–4 个有语义的平涂色，禁止无语义彩虹色、渐变和写实光影。
- v1.1 把白板可画性写入 Profile：新源为输出几何 4x，简单稀疏图可用 `flat_auto`，多对象/粗细线填关系/文字优先 `structured_semantic`；普通对象 `line_then_fill`，仅颜色层才可 `direct_fill`，手笔需贴合当前 frontier。
- v1.2 明确人物与动物必须先完成头部外轮廓、头部身份结构与五官，再进入颈部/躯干、四肢与配饰。角色源至少拆成 `character_head` 与 `character_body` 对齐 RGBA 层；单一角色层无法证明头部先画时不得进入正式渲染。
- normalized Profile 使用 `visual.character_or_animal_draw_order` 和 `visual.head_first_required` 保留机器约束；contract 1.3 Style Slice 已确认四项 head-first 字段均为 accepted，而非 dropped。

## Core Files

- `.codex-plugin/plugin.json`
- `workflow-controller/SKILL.md` 与 `skills/workflow-controller/SKILL.md`
- `video-production/SKILL.md` 与 `skills/video-production/SKILL.md`
- `video-production/adapters/whiteboard-animator-adapter.md`
- `video-production/contracts/whiteboard-animator-render-contract.md`
- `video-production/contracts/production-manifest.md` 与镜像
- `video-production/runtime/whiteboard-animator/`
- `video-production/runtime/whiteboard-animator/production_planner.py`
- `video-production/scripts/whiteboard-animator-cli.ps1` 与 manifest Skill 镜像
- `video-production/scripts/whiteboard-production-cli.ps1` 与 manifest Skill 镜像
- `tests/test_whiteboard_animator.py`
- `tests/verify-whiteboard-animator.ps1`
- `tests/fixtures/whiteboard-animator/`
- `style-profiles/source/Style_Profile_精致单色平涂火柴人科普叙事_v1.3_角色差异化.md`
- `style-profiles/normalized/minimal_stick_figure_explainer_story.v1.3-zh.json`
- `style-profiles/registry.json`
- `tests/verify-stick-figure-style-profile.ps1`
- `video-production/contracts/audio-production-contract.md` 与 manifest Skill 镜像
- `video-production/modules/audio-production.md` 与 manifest Skill 镜像
- `video-production/data/voice-types.json` 与 manifest Skill 镜像
- `video-production/scripts/select-doubao-voices.ps1` 与 manifest Skill 镜像
- `tests/verify-doubao-voice-selection.ps1`

## Verification

- 新安装缓存的 `verify-doubao-voice-selection.ps1`、`verify-audio-production.ps1`、`verify-style-profile-library.ps1` 与 `verify-stick-figure-style-profile.ps1` 全部 PASS；火柴人 Style Slice 为 `compatible`，单档平涂、角色差异轴、明确手脚、粗四肢与 head-first 约束均从 manifest Skill 入口保留。
- 新安装缓存通过 manifest Skill 白板 14/14 回归；六个安装版 Skill 均通过 UTF-8 `quick_validate`。权威源码与安装缓存排除 `.git`/`__pycache__` 后均为 497 文件，missing 0、extra 0、SHA mismatch 0。
- `verify-doubao-voice-selection.ps1` 通过：四川中年男解说仅保留“云舟 2.0 / 小天 2.0”，年长女性角色首选“婆婆 2.0”，不支持的客家方言硬阻断；候选账户状态保持 `unknown`，没有自动选择或 provider-call 授权。既有 `verify-audio-production.ps1` 与 `verify-skill4-contracts.ps1` 回归通过；manifest Skill 通过 `quick_validate.py -X utf8`。
- manifest 声明的 `skills/` 入口完成 contract 1.3 全套 14/14 回归：1.0/1.1/1.2 路径不退化；三类 ready Profile 映射、复杂源停在 package ready、Pilot 指纹复用/阻断、长静态 hold 不误拆、语义分段、串行失败保留、`continuous_canvas` / `board_cut` 合并、精确帧和真实编码均通过。
- `verify-contracts`、`verify-skill4-contracts`、`verify-workflow-controller`、`verify-staged-approval-gates`、Controller/Video Production 四个 `quick_validate`、plugin validator、schema JSON parse 与 `git diff --check` 通过。权威源码与 staging 排除 `.git`/`__pycache__` 后为 492/490 文件、missing 0、mismatch 0；仅多出并行任务拥有的两项火柴人 v1.1 source/normalized 文件。
- Style mapping 实测：`vox_transcript_driven_handmade_collage` 为 `transformed`（33 accepted / 1 transformed / 0 blocker）；`youth_weather_luminous_anime` 为 `compatible`（18 / 0 / 0）；`photoreal_future_scifi_family` 为 `partial`（5 / 2 / 1）。三者均输出确定性 slice SHA；Profile 源文件与 registry 未由本轮改写。
- 真实全分辨率 Pilot 通过权威源码 manifest Skill 入口：1280×720、24 fps、144 帧、6.0 秒、H.264 `yuv420p`、`native_audio: none`、完整解码，SHA-256 `933D986856118E50E15B948E603D191455B2D0B6023D456CD9DFA910FF556612`；105 帧手笔可见、11 帧 pen-up、`post_snap_outside_count=0`、首段边界手笔隐藏。状态保持 `success_pending_human_review`。
- 本机 1280×720、24 帧 continuous-canvas 基准耗时 `18.9141552s`，有效 pixel-frame rate `1169409.8819703034/s`。据此 Pilot plan 估算 `94.18–117.73s` 并在完整对象组后分为 2 段；正式 scope 因缺少匹配指纹的人工接受证据返回 `human_review`，没有启动传播或正式分段渲染。

- manifest 声明的 `skills/video-production/scripts/whiteboard-animator-cli.ps1` 覆盖官方 equation、简洁太阳房屋树、冻结陀螺仪 v2 与复杂能量流程图，四者 preflight 为 `supported`；复杂乡村图为 expected `human_review`，并同时命中满幅覆盖与单组件主导警告。
- Unicode 中文路径手部素材在同一 preflight 中成功解码并校验 RGBA、SHA-256、rights evidence 与 `tip_anchor`。
- 通过同一 Skill 入口实际渲染陀螺仪 10 秒样片：1116×756、24 fps、240 帧、无音轨策略、6 个组件、1 个 mixed stroke/fill group；150 帧手笔可见、19 帧 pen-up、连续步长 P95 `76.01795245466315` px。输出 SHA-256 `E4C595901386076861E6FD83851C6C22C0E83CA94BBEA477F6CB29178947974C`，状态保持 `success_pending_human_review`。
- `verify-contracts`、`verify-skill4-contracts`、`verify-workflow-controller`、`verify-staged-approval-gates`、Controller/Video Production `quick_validate`、plugin validator 与 `git diff --check` 通过。
- 完整本地回归为 21 PASS / 1 既有 FAIL。唯一失败是未修改的 `verify-activation-contracts.ps1` 仍要求旧 Video Adapter Intake，而当前已存在的 Route Policy 明确取消该阶段；本轮未恢复旧行为或擅改无关测试。
- 安装缓存中的 whiteboard 回归、两个 Skill `quick_validate` 和 plugin validator 均通过；`codex plugin list` 回读 `installed, enabled`。
- 权威源码与安装缓存排除 `.git`/`__pycache__` 后均为 487 文件，缺失 0、多余 0、SHA-256 不一致 0。
- 本轮新增的合成结构化回归通过 manifest Skill 入口完成 preflight 与 render：2 个对象、全部 stroke 先于 fill、1.0 秒绘制预算精确守恒、1.25 秒/12 fps 输出精确 15 帧，状态为 `success_pending_human_review`；旧的四类 supported fixture 与复杂扁平图 expected reject 同时通过。
- 权威源码和安装缓存的 6 个本轮文件逐一 SHA-256 一致，安装版相同 3 项 whiteboard 单元测试全部通过；`codex plugin list` 回读 `0.1.0+codex.20260912230147 installed, enabled`。
- 经独立 Cost Gate，ChatGPT Web 只生成了 1 张干净背景，没有重试或变体；其后所有合成、蒙版修正、预检和渲染均在本地完成。
- 真实乡村图通过安装版 manifest Skill 入口完成结构化 preflight 与 render：4 个对象、8 个阶段、0–6 秒线稿、6–8.5 秒显色、8.5–10 秒停留；1280×720、24 fps、精确 240 帧、无音轨，输出 SHA-256 `DD929E7AEB41ECA76154313E38B8A7D5DE9F5C1C995B16A0A22FF5F5AF9FD422`，状态保持 `success_pending_human_review`。
- 抽帧观察确认首帧为无人背景、远处人物与环境保留、四组前景按顺序出现、全部线稿先于显色、末帧恢复原构图。背景修补区仍有轻微土路色调/纹理接缝，安全扩大的蒙版也会让少量相邻地面或墙面线条进入人物线稿阶段；尚无连续观看的人类验收。
- manifest 声明的 Skill 入口完成 5/5 白板回归：旧 flat/legacy structured 路径、陀螺仪 v2、复杂扁平图 expected reject、新 stacked RGBA、独立 draw/z-order、无描边 `direct_fill` 及其非法 line-stage 拒绝均通过。
- 真实 v10 Job 通过 manifest Skill 入口：`1280×720`、24 fps、168 帧、7.0 秒、H.264 High、`yuv420p`、silent，状态 `success_pending_human_review`，输出 SHA-256 `490A4EB8E570485595058577225434D1E77B12F77145CD172675781DF718CAC5`。
- v10 真实阶段为 character `0–1.0–1.7s`、midground `1.7–2.75–3.55s`、foreground `3.55–4.05–4.45s`、shadow direct fill `4.45–5.05s`；shadow line alpha 为 0，阴影 reveal 区域新增暗色像素为 0。最终帧相对批准 v10 的平均绝对误差 `2.076`、P95 `5`，主要来自 H.264 编码；准备后的无损完整合成相对批准 v10 平均误差 `0.249`、P95 `1`。
- `plugin validator`、Controller/Video Production 根与 manifest Skill `quick_validate`、`verify-contracts`、`verify-skill4-contracts`、`verify-workflow-controller`、`verify-staged-approval-gates` 与 `git diff --check` 通过。白板专用 Python 不含 PyYAML，验证器改用 Codex 捆绑 Python；设置 `PYTHONUTF8=1` 后通过，不新增依赖。
- 实施前受影响文件已备份到 `D:\文档\ChatGPT\AI 自媒体\deliverables\whiteboard-complex-scene-test-2026-09-12\source-upgrade-20260913-180107\backup`，并生成 `backup-manifest.json`；回滚需恢复该备份、生成新 cachebuster、重新安装并复验，不能只选旧缓存目录。
- 安装缓存 `C:\Users\Roy\.codex\plugins\cache\personal\ai-media\0.1.0+codex.20260913102324` 与权威源码排除 `.git`/`__pycache__` 后均为 487 文件，missing 0、extra 0、SHA-256 mismatch 0；安装版 5/5 白板回归通过，安装版 manifest Skill 真实 v10 渲染输出 SHA-256 仍为 `490A4EB8E570485595058577225434D1E77B12F77145CD172675781DF718CAC5`。
- contract `1.2` 白板回归 9/9 通过：旧 flat/legacy structured/stacked RGBA/direct_fill 不退化；新增 4x 连续 alpha 边缘、简单图标 `flat_auto`、多行文字 `structured_semantic`、上行完整早于下行、自动 pace 与整数帧守恒、极短时长安全阻断、凹形 frontier 吸附均通过。带真实 tip 编码返回 `success_pending_human_review`，`post_snap_outside_count = 0`。
- `verify-contracts`、`verify-skill4-contracts`、`verify-workflow-controller`、`verify-staged-approval-gates`、根/manifest Skill `quick_validate`、plugin validator、schema JSON parse 与 `git diff --check` 通过。
- 最终安装缓存 `0.1.0+codex.20260914042000` 与权威源码排除 `.git`/`__pycache__` 后同为 487 文件，missing 0、extra 0、SHA-256 mismatch 0；安装版 manifest Skill 入口白板回归 9/9 通过。
- v1.1 Style Profile source SHA-256 为 `0EA70298F1E15516AA016BA940DB90180C71FA774643D50275FA48CED3FFBF8D`；style-profile library validator、JSON parse 与 registry/source hash 对齐均通过。
- v1.1 测试资产为本地确定性 5120×2880 RGBA 三层素材，不调用外部图像生成。preflight 选择 `structured_semantic`、confidence `0.96`、3 层/6 阶段、432 帧预算守恒、最终无损合成 mean absolute error `0.00235`、P95 `0`。
- manifest 声明的 Skill 入口完成一次正式 render：1280×720、24fps、432 帧、18.0 秒、H.264 `yuv420p`、无音轨、完整解码通过，SHA-256 `FC2A779F20FF7E8AFE6399FCA7A091AF4DDA22B2D7EF9933F4015544F6E9E635`。手笔可见 292 帧、pen-up 隐藏 27 帧、`post_snap_outside_count=0`；状态保持 `success_pending_human_review`。
- v1.2 Style Slice 为 `compatible`，SHA-256 `D4A77AC4F2280B8F157D01604A4FEA71C577ACE378813C3E59D939F5D670344E`；accepted fields 明确包含 `character_head`、`character_body`、`character_limbs_or_accessories` 和 `head_first_required=true`。
- 6 秒 head-first Pilot 通过 manifest Skill 入口：1280×720、24fps、144 帧、H.264 `yuv420p`、无音轨、完整解码；draw order 为 `character_head` 后 `character_body`，头部占帧 0–60，身体占帧 60–120，停留 24 帧。输出 SHA-256 `A31EB99DA76D007C8D7837FAD1663649F57ECF49F59CCEA010BFC80180C7E7A0`，手笔可见 113 帧、pen-up 8 帧、`post_snap_outside_count=0`，状态为 `success_pending_human_review`。

## Known Issues

- 豆包公开目录已入精选推荐数据，但当前账户对具体 `voice_type` 的 entitlement 仍为 `unknown`；named-voice TTS 执行 Adapter 未在本轮配置，因此已安装插件可以推荐，不能声称可直接生成指定音色。
- v1.3 Pilot 已通过技术检查但尚未人工连续观看；不得据此传播到剩余素材或正式执行分段计划。

- 当前任务在重装前加载旧 Skill；安装与缓存验证通过不等于本对话已热加载新 Audio/Profile 指令，自然语言路由需在新任务确认。
- 既有 v10 样片没有启用 `tip_overlay`；本轮 v1.1 火柴人样片已启用手笔并通过 frontier 越界检查，但连续观看质量仍待用户判断。
- 真实 v10 已有用户视觉批准；本轮新 Renderer 输出仍保持 `success_pending_human_review`，缓存 parity 和自动化技术检查不能替代对新编码结果的连续播放确认。
- `verify-activation-contracts.ps1` 与先前已修改的无 Adapter Intake 路由存在既有不一致，需另行归属后修复。
- `verify-activation-contracts.ps1` 仍要求已被当前 Route Policy 取消的启动时 Video Adapter Intake，因此保持一项既有失败；其余发布相关检查通过，本轮未恢复已废止行为来换取全绿。
- 接触表显示角色→灯泡→因果节点的对象级顺序、三级线条与分层上色已保留，但不能替代用户对 18 秒样片的连续观看；尤其需要判断 `energetic` 速度与手笔尺寸是否舒适。

## Next

1. 在新任务中验证已安装版可由自然语言调用 Audio Production 音色候选与火柴人 v1.3；安装/哈希 parity 不作为当前对话热加载证明。
2. 若要试听固定豆包 `voice_type`，需先验证账户 entitlement、配置 named-voice TTS Adapter，并单独通过精确成本 Gate。火柴人 v1.3 正式传播前仍需一支匹配新 Style Slice 指纹的 3–6 秒双角色单色平涂 Pilot 与人工连续观看接受。
