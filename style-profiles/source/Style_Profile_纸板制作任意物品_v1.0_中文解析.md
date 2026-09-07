# Style Profile：纸板制作任意物品

> **版本**：v1.0-zh  
> **内部风格 ID**：`cardboard_make_anything`  
> **来源**：`D:/文档/AI视频项目/Viral Feed Video/纸板制作任意物品/Prompt.txt`；对应样片 `纸板制作火车.mp4`（20.155 秒，竖屏）。

## 可复用核心

- **适用输入**：明确要制作的物品；若目标物、结构可行性或关键部件未知，交给既有 Controller 缺失内容路由。
- **可见初态与变化**：天然棕色瓦楞纸板从平板、标线或部件开始，经过切割、折叠、粘接和装配，逐步成为单一、可辨认的纸板成品。
- **材料与主体锁**：所有成品可见结构为天然棕色瓦楞纸板，保留层状边缘、纤维和手工痕迹；同一双真实成年人手和必要工具保持一致。
- **构图与镜头**：干净、稳定的制作台面/背景，优先让切割、对齐、粘接和结构增长可读；微距仅用于证明材料或进度，不能替代关键制作步骤。
- **物理与连续性**：部件只能在实际制作后出现；结构、比例、接缝、手部和光线连续，已完成部分不得倒退或无因变形。
- **声音方向**：在支持时使用同步的纸板切割、折叠、摩擦与装配 ASMR；不默认旁白或音乐。
- **结尾兑现**：清晰展示完成物的整体轮廓和瓦楞纸板细节。

## 冲突与边界

- 来源文本把 15 秒写成最长模板时长，样片实际约 20.15 秒；时长不是 Style Core，交由当前 Adapter 与用户目标决定。
- 文件名称为“火车”，样片画面更接近消防/工程车辆。Profile 只要求“用户指定物品的可辨纸板构建”，不将火车或车辆类型写为默认目标。
- 8K、固定镜头序列、平台名、逐轮审批、工具枚举和固定白背景为生产参考；当前 Adapter、项目条件或用户参考可替换。

## 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: cardboard_make_anything
  required_inputs: [target_object]
  compatibility: single_cardboard_object_with_visible_build_progress
  visible_initial_state: flat_or_sorted_brown_corrugated_cardboard
  necessary_state_change: cut_fold_glue_and_assemble_into_object
  ending_payoff: completed_object_with_corrugated_detail
  production_modules: replaceable
```
