# Style Profile：环绕冻结子弹时间动作

> **版本**：v1.0-zh  
> **源文档**：`D:/AI 视频/Flova技能/子弹时间风格短片.md`  
> **源文件 SHA-256**：`BAC31D0FC24AE691224D84F30C2FD899C587A5EBE68D2ACE7A14974C0B3499A9`  
> **内部风格 ID**：`orbital_time_freeze_action`  
> **库状态**：`pending_review`  
> **重要判断**：子弹时间主要是一套摄影机轨迹、时间曲线、主体姿态和空间特效规则，不是完整美术风格；当前项目仍需单独提供视觉媒介、时代、色彩与世界设定。

---

## 0. 解析结论

这是一份**子弹时间视听效果 Profile + 资产连续性规范 + 完整生产手册**。可复用的 Style Core 是：

- 明确“正常速度 → 极慢动作 → 冻结或近冻结 → 恢复速度”的时间曲线；
- 冻结瞬间必须锁定精确主体姿态、关键道具位置和粒子轨迹；
- 摄影机围绕主体运动时写清方向、起止角度、轨迹和速度；
- 子弹、碎片、液滴、尘埃等悬浮元素既表现时间状态，也建立空间纵深；
- 动态模糊只属于仍在运动的部分，冻结主体和关键视觉点保持清晰；
- 角色与地面、平台、车辆、悬崖或室内结构必须有明确承载/包围关系；
- 子弹时间前后设置速度反差和声音截断、拉长或恢复；
- 角色身份、服装、场景子区域、光源和道具状态跨镜锁定。

源文档没有定义唯一视觉风格，只要求先由用户或项目选择。因此本 Profile 不能单独进入 LookDev；它更适合作为叠加到其他视觉 Profile 上的“摄影与时间效果层”。

---

## 1. 文档分类

```yaml
classification:
  primary: audiovisual_style_profile
  secondary:
    - production_playbook
    - narrative_style_bible
  full_series_canon: false

  flags:
    has_topic_direction: false
    has_story_direction: partial
    has_visual_system: partial
    has_cinematography_system: true
    has_temporal_effect_system: true
    has_performance_system: true
    has_sound_system: true
    has_voice_system: true
    has_music_system: true
    has_model_specific_rules: true
```

---

## 2. 适配范围

### 强适配

- 动作高潮、闪避、出拳、坠落、破碎、爆炸瞬间
- 子弹、碎片、液体、尘埃或飞溅物参与的空间冻结
- 需要突出一次关键抉择或危险瞬间的叙事短片
- 舞蹈、运动、产品冲击和奇观展示

### 中等适配

- 情绪记忆、梦境、时间暂停、主观意识片段
- 非写实动画或实验影像中的环绕冻结
- 不涉及子弹但需要三维空间停顿的广告镜头

### 弱适配

- 全片持续慢动作、无明确触发点的内容
- 纯口播、静态访谈、生活 Vlog
- 无法建立稳定三维空间和主体姿态的复杂群像

---

## 3. 权威与缺口

```yaml
authority:
  topic_direction: none
  story_direction: soft
  visual_medium: runtime_required
  time_curve: hard
  camera_orbit: hard
  freeze_pose: hard
  suspended_elements: high
  physical_space_relation: hard
  cinematography: hard
  performance: high
  editing_rhythm: high
  sound_design: high
  voice_system: medium
  music_direction: medium
  production_model: none
```

- “高饱和金属光泽、强对比侧逆光”是源文档给出的关键词方向，不应强制覆盖已选视觉风格。
- 子弹时间不要求一定出现真实子弹；任何可读的高速对象、液体或碎片都可承担时间冻结证据。
- 用户剧本和分镜优先，Style Profile 不得增删场景或改写台词。

---

## 4. Router A：Pre-Content

```yaml
pre_content_modules:
  compatibility:
    authority: medium
    preferred:
      - 单一关键瞬间
      - 动作高潮
      - 抉择与危机
      - 时间感主题
    avoid:
      - 全程持续冻结
      - 无动作触发的纯说明内容

  story_direction:
    authority: soft
    value: 正常速度铺垫 → 危机或动作触发 → 极慢/冻结观察 → 决定性细节 → 恢复速度与结果

  theme_expression_rules:
    authority: soft
    value: 子弹时间只用于最需要观众观察的关键瞬间，不平均分配到所有镜头

  restrictions:
    - 已有剧本是唯一内容蓝本
    - 不改写台词
    - 新增镜头建议必须标注为补充项
```

---

## 5. 时间曲线

```yaml
temporal_effect:
  phases:
    - normal_speed_setup
    - deceleration
    - near_freeze_or_freeze
    - orbit_observation
    - acceleration_resume
    - consequence
  trigger:
    required: true
    examples:
      - 子弹进入危险区域
      - 拳脚接触前一瞬
      - 人物跃至最高点
      - 玻璃或液体开始破裂
  freeze_state:
    required:
      - 主体姿态精确
      - 道具位置精确
      - 粒子轨迹精确
      - 视线和表情可读
```

冻结不是“画面停住”四个字，而是一个可审查的空间状态：哪些物体完全静止、哪些仍极慢移动、摄影机是否继续运动、声音如何变化，都要明确。

---

## 6. 摄影机环绕

- 指定顺时针或逆时针。
- 指定起止角度或至少前/侧/后关系。
- 指定水平环绕、升降弧线、近距离半圆或完整轨道。
- 摄影机运动速度与主体时间速度分离：主体可近冻结，摄影机仍平滑移动。
- 环绕过程中必须保持主体在空间中的真实位置和承载面，不得漂浮或背景跳变。

```yaml
camera_orbit:
  required_fields:
    - direction
    - start_angle
    - end_angle
    - trajectory
    - speed
    - framing
  preferred:
    - 平滑半环绕
    - 低角度上升弧线
    - 近景到侧后方的空间揭示
  avoid:
    - 无方向随机旋转
    - 围绕错误中心
    - 摄影机穿过主体或场景结构
```

---

## 7. 悬浮元素与焦点

```yaml
suspended_elements:
  choices:
    - 子弹或高速道具
    - 碎片
    - 液滴
    - 灰尘
    - 火花
    - 布料或头发局部
  purpose:
    - 证明时间状态
    - 标记运动方向
    - 建立前中后景纵深
  rules:
    - 轨迹起点和方向可解释
    - 与碰撞、爆炸或动作事件对应
    - 数量受控，不遮挡主体面部和关键动作

focus_and_blur:
  frozen_subject: 清晰
  key_projectile_or_fragment: 清晰或重点对焦
  still_moving_parts: 可保留方向性动态模糊
  background: 按空间层级适度虚化
```

“高饱和金属光泽”只适用于金属道具且与当前色彩 Profile 兼容时；液体、织物和尘埃应保留自身材质逻辑。

---

## 8. 角色、表演与情绪

- 冻结姿态必须具体到四肢位置、重心、头部朝向、手指状态和衣物受力。
- 角色身体比例、脸部、发型、服装和鞋履跨镜稳定。
- 情绪由发生原因、微表情、肢体动作和说话语气共同表达。
- 不用“恐惧、愤怒、悲伤”代替可见表演。

```yaml
performance:
  emotion_formula:
    - 发生原因
    - 表情细节
    - 肢体动作
    - 说话语气
  freeze_pose_lock:
    - 重心
    - 四肢角度
    - 视线
    - 手指
    - 衣物与头发惯性
  avoid:
    - 身体扭曲
    - 肢体融合
    - 无支撑漂浮
    - 抽象情绪词替代动作
```

---

## 9. 空间承载与场景锁

- 角色站立、坐卧、悬挂或接触的表面必须延伸到角色脚下或身体接触点。
- 平台、擂台、甲板、车内、阳台、屋顶和悬崖需要明确边界、围栏或包围结构。
- 若使用多视角场景参考，当前镜头必须锁定其中一个具体子区域，不能把参考网格直接生成到成片。
- 连续镜头保留主光方向、色温、关键陈设和场景边界。

```yaml
environment:
  physical_relation_required: true
  locks:
    - 承载面
    - 围栏或边界
    - 当前场景子区域
    - 主光方向与色温
    - 关键陈设
  forbidden:
    - 场景退化为纯背景板
    - 角色无支撑悬浮
    - 多视角网格直接出现在成片
```

---

## 10. 镜头与剪辑节奏

- 子弹时间镜头前放置正常速度或略快的铺垫。
- 触发时通过减速、声音截断和环绕进入高峰。
- 冻结观察结束后渐进恢复，而不是无过渡硬切回正常速度。
- 子弹时间镜头内部不叠加额外花哨转场。
- 源文档偏好 10–15 秒的内部节拍长镜，这是生产参考；实际时长服从当前模型能力和内容复杂度。

```yaml
editing_rhythm:
  setup: 正常或略快
  trigger: 急减速或瞬时截断
  freeze: 留出观察时间
  resume: 渐进恢复速度
  consequence: 回到叙事结果
  transition: 简洁直切或短淡入淡出
  avoid:
    - 全片持续慢动作
    - 冻结镜头内花哨转场
    - 无铺垫直接滥用效果
```

---

## 11. 声音、台词、旁白与音乐

```yaml
sound_design:
  trigger_options:
    - 瞬时静默
    - 高频切断
    - 环境声极度拉长
    - 心跳或低频突出
  freeze_state:
    - 残响拉长
    - 碎片与空气细声放大
    - 背景音乐闪避或截断
  resume: 随速度恢复音高、节奏和环境密度

voice_system:
  dialogue: 可在镜头内出现
  narration: 独立轨道
  rule: 台词与旁白不得重复或高度相似

music_direction:
  function: 建立铺垫并在触发点让位于时间效果
  behavior:
    - 触发点截断或显著降低
    - 恢复速度后渐回
  exact_style: runtime_defined
```

源文档中的具体分贝数是混音起点，不是永久音乐身份。

---

## 12. 连续性锁

```yaml
continuity_schema:
  character:
    - 面容
    - 服装与鞋履
    - 冻结姿态
    - 动作方向
  environment:
    - 场景子区域
    - 承载面与边界
    - 光源方向与色温
    - 关键陈设
  effect:
    - 触发时刻
    - 摄影机环绕方向与角度
    - 悬浮物位置与轨迹
    - 时间速度状态
  audio:
    - 台词与旁白归属
    - 触发点声音变化
```

---

## 13. 负面约束

- 不要无触发点的慢动作或全片持续冻结。
- 不要随机环绕、围绕错误中心或镜头穿过主体。
- 不要悬浮元素无来源、无轨迹或遮住关键表演。
- 不要角色无支撑漂浮、场景退化为背景板。
- 不要身份、服装、光源和场景子区域跨镜漂移。
- 不要把旁白正文写入视频台词层。
- 不要在当前视觉 Profile 不兼容时强行加入高饱和金属感。

---

## 14. Production Adapter Reference

```yaml
production_modules:
  model_adapter_reference:
    image:
      - GPT Image 2
    video:
      - Seedance 2.5
    voice:
      - MiniMax Speech 2.8 HD
      - ElevenLabs v3
    music:
      - Suno 5
      - Mureka 8
    upscaling:
      - MediaKit

  source_asset_reference:
    character: 全身三视图
    scene: 无人物四宫格多角度场景图
    prop: 独立道具图

  source_output_reference:
    aspect_ratio: 16:9
    image_resolution: 2K
    video_generation_resolution: 480p
    spec_resolution: 720p
    prompt_limit_characters: 2300
    max_reference_images: 9

  replaceable: true
```

---

## 15. 冲突与缺失项

```yaml
conflicts:
  - id: BULLET-VISUAL-01
    issue: 文档要求先确认视觉风格，但 Profile 自身没有固定视觉媒介
    resolution: 必须叠加另一个视觉 Style Profile 或当前项目覆盖值
  - id: BULLET-RES-01
    issue: skill_description写480p，Final_Video_Spec写720p，媒体生成又写480p，导出再写720p
    resolution: 生成与交付分辨率由当前生产适配器重新声明，Style Core不锁定
  - id: BULLET-COLOR-01
    issue: 高饱和金属光泽与任意用户视觉风格可能冲突
    resolution: 仅作为兼容时的可选效果，不覆盖全局色彩与材质

missing_or_partial:
  visual_medium: 缺失，运行时必填
  fixed_color_palette: 缺失
  world_and_period: 缺失
  fixed_character_canon: 缺失
  exact_music_identity: 缺失
```

---

## 16. normalized_style_profile

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: D:/AI 视频/Flova技能/子弹时间风格短片.md

style_profile:
  style_id: orbital_time_freeze_action
  version: 1.0-zh
  classification: audiovisual_style_profile

  pre_content_modules:
    compatibility:
      authority: medium
      preferred:
        - 动作高潮
        - 危机与抉择
        - 时间感主题
        - 需要观察决定性瞬间的内容
    story_direction:
      authority: soft
      value: 正常速度铺垫 → 危机触发 → 极慢/冻结观察 → 恢复速度与结果
    theme_expression_rules:
      authority: soft
      value: 子弹时间只用于最关键瞬间，不平均铺满全片

  audiovisual_modules:
    visual_identity:
      authority: partial
      visual_medium: runtime_required
      value: 子弹时间本身不规定画种、时代或固定色彩
    character_visual:
      authority: hard
      value: 身份、服装、身体比例和冻结姿态跨镜稳定
    environment:
      authority: hard
      value: 场景子区域、承载面、边界、主光与陈设明确
    cinematography:
      authority: hard
      value: 指定方向、起止角度、轨迹和速度的平滑摄影机环绕
    performance:
      authority: high
      value: 精确肢体姿态、重心、视线和情绪四要素
    editing_rhythm:
      authority: high
      value: 正常 → 减速 → 冻结观察 → 恢复 → 结果
    sound_design:
      authority: high
      value: 触发点静默或拉长，冻结时放大细节声，恢复时回归速度感
    voice_system:
      authority: medium
      value: 台词可在镜头内，旁白独立，二者不得重复
    music_direction:
      authority: medium
      value: 背景音乐服务速度曲线，触发点主动闪避或截断
    continuity_schema:
      authority: hard
      track:
        - 时间速度状态
        - 摄影机环绕参数
        - 冻结姿态
        - 悬浮物轨迹
        - 场景承载关系
        - 声音归属

  production_modules:
    asset_prompt_templates: source_defined
    video_prompt_templates: source_defined
    model_adapter_reference: replaceable
    generation_workflow: ignored_in_style_core

  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/子弹时间风格短片.md
        version: attached-2026-08-24
        sha256: BAC31D0FC24AE691224D84F30C2FD899C587A5EBE68D2ACE7A14974C0B3499A9
    extracted_modules:
      - field: pre_content_modules
        source_section: planner + storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer + write_the_prompt + video_assembler
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator + planner
        extraction_type: direct
```
