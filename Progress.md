# Progress

## Current Goal

`region_stream_ink` 已作为现有 `video-production` 下的可选 Local Renderer Adapter 完成源码实施、隔离 runtime、中文触发别名、整包验证与本机更新安装。下一阶段是使用新任务加载新版 Skill，并对三类真实图片逐条做人工标注、真实视觉 QA 与 ROI 试片。

## Completed & Key Decisions

- 新 Adapter 只负责 `source image -> region annotation/protected masks -> grid|skeleton continuous ink -> ink_only|ink_then_color -> silent visual_track.mp4`；未新增 Controller、顶层 Skill、Manifest、Gate、QA taxonomy、状态源或 retry ledger。
- `aspect_ratio`、`resolution`、`width_px`、`height_px` 无默认值，`UNKNOWN` 会阻止正式 Job；图片只可通过显式 `pad|crop` 保持比例，不存在 `cap_long_edge=1080` 回退。
- 时间轴以显式整数帧为权威：区域不得时间重叠，尾停留包含在总帧预算，空 mask/path 也输出完整帧数；多 Clip 合并返回偏移表，不隐式追加时长。
- `ink_only` 不显色且末帧不恢复原图；`ink_then_color` 只揭示当前获准区域。暂缓保护与永久保护分开，未覆盖墨迹在未显式接受时阻断。
- OpenCV/NumPy 逐帧渲染，OpenCV `VideoWriter` 只写临时 `mp4v`；FFmpeg 优先、PyAV 回退输出 H.264 `yuv420p`。双路失败结构化失败并保留诊断中间件，绝不把 `mp4v` 冒充成功。
- 拼接前校验宽高、帧率、codec、pix_fmt、time base；首版拒绝异构输入。成功产物须无音轨、完整解码、帧数准确且时间戳单调。
- 默认无手部/笔尖叠加，不依赖 Windows 字体；自定义 tip 必须带权利证据。保留上游 `geeklee/srt-whiteboard-animation@696a724` MIT 声明，未打包示例资产、字体、手部、FFmpeg 二进制或依赖 wheel。
- Renderer CLI 只返回 `clip_id/revision_id/input_hash/checksum` 等执行事实，不保存审批、QA PASS、用户接受或 retry 状态。Manifest 只增加既有 `adapters[]` 能力事实和 `clips[].local_visual_render_ref` 可选引用；真实媒体继续走现有 intake、`qa.results`、Execution State 与 `controller_return`。
- 用户导入图片不需要媒体生成 Cost Gate，但继续要求来源/权利证据；付费源图仍走 Visual Baseline 与独立 Cost Gate；`external_prompt_only` 不可执行本地 Renderer。
- 隔离 Python runtime 位于 `C:\Users\Roy\AppData\Local\Codex\runtimes\ai-media-region-stream-ink\0.1.0`，锁定 NumPy 2.2.6、OpenCV Headless 4.12.0.88、Pillow 11.3.0、PyAV 15.1.0。
- 重装前 HEAD/源码/cache 三方归因为 A=29、B=21、C=15、D=0；保留所有既有 dirty 改动，无 stash/reset/checkout/clean。未执行 Git commit 或 push。
- `workflow-controller` 与 `video-production` 的根目录及 `skills/` 入口已加入“白板手绘动画、逐笔手绘、连续笔迹动画、图片分区连续笔迹渲染、线稿逐笔显现”和 `region_stream_ink`；Adapter 仍归 `video-production`，未新增顶层 Skill。

## Core Files

- `video-production/adapters/region-stream-ink-adapter.md`
- `video-production/contracts/region-stream-render-contract.md`
- `video-production/runtime/region-stream-ink/renderer_cli.py`
- `video-production/runtime/region-stream-ink/annotation.py`
- `video-production/runtime/region-stream-ink/render.py`
- `video-production/runtime/region-stream-ink/encode.py`
- `video-production/runtime/region-stream-ink/preview.py`
- `video-production/runtime/region-stream-ink/schemas/annotation.schema.json`
- `video-production/runtime/region-stream-ink/schemas/render-job.schema.json`
- `tests/test_region_stream_ink.py` 与 `tests/verify-region-stream-ink.ps1`
- `video-production/SKILL.md`、`skills/video-production/SKILL.md`
- `workflow-controller/SKILL.md`、`skills/workflow-controller/SKILL.md`
- 两份 `production-manifest.md` 镜像

## Verification

- Region Stream Ink 10/10 fixture 通过：合法/非法 annotation、空区域/零墨迹、暂缓/永久保护、未覆盖墨迹、细字/实心块/交叉箭头/多对象与显式重叠、`ink_only`/`ink_then_color`、grid/skeleton、64×64 与 96×54 显式规格、整数帧/尾停留、预览、取消、FFmpeg、PyAV 回退、双路失败、同构拼接/异构拒绝、无音轨、H.264、完整解码、单调时间戳和结构化 JSON。
- 当前插件全部 22 个 `tests/verify-*.ps1` 通过；插件 validator、四个受影响 Skill 的 UTF-8 `quick_validate` 与 `git diff --check` 通过。
- 系统 FFmpeg 探测为 8.1.2，当前构建支持 `libx264`；FFmpeg 不随插件分发，其许可证取决于本机实际构建。
- 本机插件已通过 personal marketplace 安装并启用为 `0.1.0+codex.20260911080811`；清除测试生成的 `__pycache__` 后，最终源码与安装缓存按非 Git 文件核对为 473/473、零缺失、零多余、零 SHA-256 不一致。
- 上述 fixture 只证明合同、渲染、编码与路由行为，不证明真实媒体主观质量、用户批准、外部旁白同步、Final Master 或发布。

## Known Issues

- 首版不包含 SRT importer、自动分区、GPU、并行、复杂缓存、解说、字幕、BGM 或最终混音。
- grid/skeleton 的真实连续性、细节可读性、平台压缩效果、人工标注成本与 ROI 仍需三类真实试片；硬性正确性未通过的图片类别必须标为暂不支持。
- 本机磁盘安装成功不代表当前任务热加载新版 Skill；必须新建任务验证运行时发现。
- 既有 Fast Path/Stage 0 路由冲突、固定叙事/Beat 模板与装配交接仍是独立待办，不属于本次 Adapter 实施。
- Git 提交与远端同步状态以权威仓库的实时 `git status`、`git log` 和 `origin/master` 回读为准；安装缓存一致不自动等于当前任务已热加载新版 Skill。

## Next

1. 新建任务加载已安装插件，使用“白板手绘动画”等中文名称确认 `ai-media:workflow-controller` 可触发并路由到 `ai-media:video-production` 的 Local Renderer Adapter。
2. 逐视频确认平台、比例、分辨率和显式像素尺寸，再进行 annotation preview；未经当前 revision 的人工确认不执行正式 Job。
3. 用稀疏线稿、彩色扁平插画、多对象重叠画面各做一条真实试片，记录标注/渲染/重做成本与硬性 QA；只有三条硬性正确性全部通过且至少 2/3 达到主观质量和 ROI 才升级为推荐路线。
