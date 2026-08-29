# Flova 六类工作流 Style Profile 解析索引

> 解析日期：2026-08-24  
> 解析规范：Unified Style Profile Library Contract v1.0  
> 当前状态：全部为 `pending_review`，尚未注册为可直接调用的 `ready` Profile

## 解析结论

六份源文档不是同一种“视觉风格”。它们分别描述短剧视觉开发、FPV 飞行摄影、严格第一人称叙事、电商动态展示、电商静态图集与数字人口播。若合并成一个 Profile，会让 POV、FPV、TETO 快剪与 TVC 慢节奏等互斥规则相互污染。因此本次拆成六个独立 Profile。

| Profile | 主分类 | 建议用途 | 当前判断 |
|---|---|---|---|
| 短剧前期视觉开发定调 | `production_playbook` | 短剧视觉开发素材包与概念样片 | 结构完整，需按项目选择视觉风格 |
| 第一人称 FPV 穿越视角 | `production_playbook` | 无人机式连续飞行路径 | 源文档不完整，只能保留高层规则 |
| 第一人称 POV 沉浸式短片 | `hybrid_style_profile` | 严格主角眼睛视角的现实主义叙事 | POV 硬锁清楚，模型参数需适配 |
| 电商产品 TVC 展示视频 | `mixed` | TETO 动感展示或产品 TVC | 两个互斥视觉域，必须显式选一 |
| 电商产品主图与详情页 | `production_playbook` | 静态电商主图、卖点图、详情页 | 产品真值优先，量化阈值需可测证据 |
| 电商数字人商品口播 | `hybrid_style_profile` | 单场景、单机位、音频驱动口播 | 单关键帧规则与多机位示例存在冲突 |

## 共用应用原则

1. 原始文档中的工具名、模型名、分辨率、时长、重试次数和提示词模板属于生产适配层，不属于永久风格核心。
2. 示例只用于说明结构，不能视为项目事实、品牌授权、产品参数或固定审美。
3. 用户素材、产品真值、冻结脚本与项目规格的优先级高于 Profile。
4. 缺失字段保持缺失；本次没有为源文档补造角色、事实、产品卖点或模型能力。
5. 六个 Profile 进入实际项目之前，应先选择单一 Profile；只有显式声明兼容关系时才允许组合。

## 文件清单

- `Style_Profile_短剧前期视觉开发定调_v1.0_中文解析.md`
- `Style_Profile_第一人称FPV穿越视角_v1.0_中文解析.md`
- `Style_Profile_第一人称POV沉浸式短片_v1.0_中文解析.md`
- `Style_Profile_电商产品TVC展示_v1.0_中文解析.md`
- `Style_Profile_电商产品主图详情_v1.0_中文解析.md`
- `Style_Profile_电商数字人商品口播_v1.0_中文解析.md`

