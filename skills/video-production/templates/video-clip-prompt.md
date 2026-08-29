# Video Clip Executable Prompt — 6 modules

```text
【规格与参考】
输出参数：时长 ...；画幅 ...；分辨率 ...；原生音频模式 ...。
Scene Baseline 职责：只锁定本镜所需的空间拓扑、固定物和已审核 coverage；不得把剧情 Key Frame 或 Resume Frame 当作 Scene Setting。
全局共享层（本次调用自包含）：...
人设不变量层（按冻结锚点原样复制）：...

【起始状态】
...

【时间轴】
0.0–1.0s：动作、镜头、关键状态变化。

【镜头与表演】
...

【结束状态】
...

【连续性与禁止项】
锁定项：...
允许变化：...
禁止项：...
```

The external Video Prompt remains exactly these six modules. Internal feasibility fields, evaluator evidence, confidence, owner, and retry state stay in the Manifest and are not emitted as additional modules.

This block is the copy-ready external prompt. Do not replace it with an acceptance note, QA result, cost gate, file path, or a pointer to another document. Do not use placeholder text such as `已接受片段`, `正文另见`, `承接上一条后再编译`, or `Clip Brief`. Do not request background music. The timeline must be continuous at 0.1-second precision and end at the declared Clip duration. Unresolved aspect ratio or resolution blocks generation.
