# Style Profile：迷你厨房烹饪

> **版本**：v1.0-zh  
> **内部风格 ID**：`miniature_kitchen_cooking`  
> **来源**：`D:/文档/AI视频项目/Viral Feed Video/迷你厨房烹饪/迷你厨房烹饪 Skill.md`；对应样片 `迷你厨房烹饪.mp4`（10.773 秒，竖屏）。

## 可复用核心

- **适用输入**：明确菜品、食材与烹饪目标；缺失菜品或关键食材时交给既有 Controller 内容缺失路由。
- **可见初态与变化**：微型厨房中未完成的食材与器具，经连续、可辨的处理、加热或组装，变为可辨认的完成菜品与摆盘。
- **构图与尺度**：微型食物、微型厨具与同一双成年人手形成稳定尺度反差；食材、器具、环境与文化语境一致。
- **物理与连续性**：手、器具、火源/锅具、食材进度、光线和尺度跨段稳定；每一可见进度须由前一状态合理发生，不能凭空完成。
- **声音方向**：只在当前 Adapter 支持且项目选择时使用与可见动作同步的烹饪 ASMR；不默认旁白或音乐。
- **结尾兑现**：以完成菜品、真实质地与简洁的成品主视觉收束。

## 冲突与边界

- 来源一处写“中国/南亚人双手”，另一处按英语受众写“西方人双手”；不把族裔作为风格默认。以用户明确设定或参考素材为准，未指定时为 `UNKNOWN`，同一项目内必须保持同一双手。
- 指定模型、8K、固定 9:16、15–20 秒、逐阶段审批和工具调用均为来源生产流程，不进入 Style Core；由当前 Adapter 与既有 Gate 决定。
- 不把来源中的多轮问答复制进 Fast Path；只保留本 Profile 所需的菜品、食材与可见烹饪进度。

## 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: miniature_kitchen_cooking
  required_inputs: [dish, ingredients_or_recipe_scope]
  compatibility: miniature_food_process_with_visible_causality
  visible_initial_state: uncooked_or_unassembled_miniature_food
  necessary_state_change: ingredient_to_prepared_cooked_and_plated_food
  ending_payoff: finished_dish_hero_view
  production_modules: replaceable
```
