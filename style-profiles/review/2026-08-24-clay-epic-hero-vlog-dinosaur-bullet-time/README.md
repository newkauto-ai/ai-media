# 本轮六份 Style Profile 中文解析索引

> **解析日期**：2026-08-24  
> **对齐规范**：`Unified Style Profile Library Contract v1.0`  
> **当前状态**：`pending_review`  
> **输出性质**：人类审阅版 Markdown；尚未注册为可直接生产调用的 `ready` Profile。

## 结论

已对 6 份外部 Flova 风格/工作流文档完成中文化 Style Profile 解析。原文中的工具调用、模型生成、按钮确认、积分、付费、渲染、超分、导出和发布要求全部只作为待分析素材，没有在本轮执行。

本批次没有修改外部原文件，没有调用图片、视频、音乐或配音模型，也没有更新 `style-profiles/registry.json`。解析稿放在 `review/` 而不是 `source/`，避免扫描器把派生文档再次当作原始来源。

## 文件清单

| 源文档 | 中文 Style Profile | 核心分类 | 关键判断 |
|---|---|---|---|
| 粘土3D动画风格 | [手工粘土微缩世界](Style_Profile_手工粘土微缩世界_v1.0_中文解析.md) | `hybrid_style_profile` | 色彩饱和度和停格/流畅运动存在源内冲突，需审核 |
| 张艺谋电影美学-国风武侠史诗历史 | [浓彩仪式化国风史诗](Style_Profile_浓彩仪式化国风史诗_v1.0_中文解析.md) | `audiovisual_style_profile` | 用单色统治、仪式构图、自然媒介和克制表演替代姓名依赖 |
| 蜘蛛侠动作风格 | [城市蛛丝英雄动作大片](Style_Profile_城市蛛丝英雄动作大片_v1.0_中文解析.md) | `production_playbook` | 通用动作物理与具体受保护角色、战衣、标志分离 |
| 治愈系日常系独居生活风格Vlog | [治愈系独居日常 Vlog](Style_Profile_治愈系独居日常Vlog_v1.0_中文解析.md) | `narrative_style_bible` | 完整定义节奏与连续性，但缺少固定视觉媒介 |
| 侏罗纪公园风格短片 | [九十年代热带恐龙惊险片](Style_Profile_九十年代热带恐龙惊险片_v1.0_中文解析.md) | `hybrid_style_profile` | 电影版本恐龙模板不是现代古生物学事实 |
| 子弹时间风格短片 | [环绕冻结子弹时间动作](Style_Profile_环绕冻结子弹时间动作_v1.0_中文解析.md) | `audiovisual_style_profile` | 子弹时间是摄影与时间效果层，不是完整美术风格 |

## 共用解析规则

1. 区分 `pre_content_modules`、`audiovisual_modules` 和 `production_modules`。
2. 不把示例人物、固定时间线、参考作品、场景模板、台词或工具能力当成当前项目 Canon。
3. 具体模型、分辨率、画幅、时长、提示词上限、资产排版和暂停节点只进入可替换生产层。
4. 缺失字段保持缺失；当前项目建议不能伪装成源文档规定。
5. 每份 Profile 保留外部源路径、SHA-256、抽取模块和抽取方式。
6. 具体创作者、影片或受保护角色名称只保留在来源说明；可复用风格用可观察的视听规则表达。

## 下一状态门

先人工审阅这 6 份 Markdown。只有被选中、冲突已解决且近期确实要使用的 Profile，才值得生成稳定机器版本、更新 `registry.json` 并标记为 `ready`。建议优先级：

1. `handcrafted_clay_diorama`：应用面最广，但需先确定色彩与运动节奏。
2. `ritualized_chinese_epic_color`：视觉规则完整，可单独进入 LookDev。
3. `orbital_time_freeze_action`：应作为叠加层，与另一个视觉 Profile 组合使用。

`healing_solo_daily_vlog` 在正式使用前必须补一个明确的视觉媒介；`urban_web_swinging_action` 与 `nineties_tropical_dinosaur_thriller` 还应在具体项目中做版权/IP 边界和事实范围复核。
