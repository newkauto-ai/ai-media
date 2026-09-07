# Style Profile：美女跳舞卡点变装

> **版本**：v1.0-zh  
> **内部风格 ID**：`female_dance_beat_outfit_transition`  
> **来源**：`D:/文档/AI视频项目/Viral Feed Video/美女跳舞卡点变装/skill.md`；对应样片 `美女跳舞卡点变装.mp4`（13.955 秒，竖屏）。

## 可复用核心

- **适用输入**：明确成年人物身份锚点、初始造型和候选造型；缺失关键人物或造型时交给既有 Controller 内容缺失路由。
- **可见初态与变化**：同一成年人物以一个初始主造型居中出现，候选造型作为同一人物的完整剪影贴纸/参考；每次卡点触发一张候选贴纸与中心人物重合，中心人物只改变对应穿搭，且动作不中断。
- **候选数量驱动**：候选造型数量决定可用换装次数与布局；不得把七人、五套、六候选或四次换装固化为永久默认。每次使用后，该候选位置留空，中心始终只有一个完整人物。
- **构图与镜头**：中心主体明显最大，候选贴纸较小、完整且可辨；固定或低复杂度机位优先，使人物身份、贴纸去留和换装结果可读。
- **连续性与物理**：脸、成年年龄感、族裔外观、肤色、发型、体型和配饰锚点稳定；只改变服装。重心、手臂轨迹、头部朝向、发丝和衣料运动跨换装节点连续。
- **声音方向**：在支持时以卡点、点击/飞入与轻微衣料拟音服务换装节点；是否有音乐由当前项目决定。
- **结尾兑现**：以最终选中的完整造型和持续动作作清晰展示。

## 冲突与边界

- 样片为中心人物加六个候选贴纸（七人），旧来源还包含“五套/四次时点”规则；统一为候选数量驱动，当前项目在确定候选数后再计算换装次数与时间分配。
- 用户可见名称“美女跳舞卡点变装”原样保留；此名称是格式分类，不强制人物性别、族裔、具体年龄、服装域或亲密语义。人物必须为成年人。
- 固定 8 秒、9:16、镜头角度、默认机制和逐轮问答均为生产参考；由当前 Adapter、用户内容与参考素材决定。

## 机器可读摘要

```yaml
fixture_only: false
library_status: ready
style_profile:
  style_id: female_dance_beat_outfit_transition
  required_inputs: [adult_identity_anchor, initial_outfit, candidate_outfits]
  compatibility: single_adult_subject_with_candidate_driven_outfit_transitions
  visible_initial_state: one_center_subject_with_initial_outfit_and_candidate_stickers
  necessary_state_change: each_selected_candidate_merges_and_changes_center_outfit
  ending_payoff: final_outfit_with_continuous_motion
  production_modules: replaceable
```
