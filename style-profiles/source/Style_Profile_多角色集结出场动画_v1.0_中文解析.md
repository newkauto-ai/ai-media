# Style Profile：多角色集结出场动画

> **版本**：v1.0-zh  
> **源文档**：`多角色出场动画.md`  
> **内部风格 ID**：`multi_character_ensemble_entrance`  
> **文档分类**：`production_playbook`（主）+ `audiovisual_style_profile`（次）  
> **解析原则**：群像图片只是当前视频的视觉来源，不自动成为系列 Canon；源文档中的固定长提示词、模型调用和一次性生成流程进入生产层，不能反向支配内容或永久画风。

---

## 0. 解析结论

本资料的可复用核心不是某部具体动画作品的复刻，而是**电影级绘画质感 CG 群像集结语法**：逐角色建立身份与武器高光，利用强风、动作方向、遮挡物和武器轨迹完成连续转场，最终按参考图站位集结。镜头强调强透视、景别跨度、角色差异化登场和统一的环境动力。

源文档固定引用具体作品作为风格标签。归一化后不把该作品名称写入永久风格核心，改为可观察特征：绘画化纹理、强轮廓光、高对比电影照明、夸张但物理可信的动作和分层环境运动。

## 1. 输入与适配

### 必需输入

- 至少一张包含全部角色的清晰群像图
- 可辨认的角色站位、服饰、武器与道具
- 输出比例与是否需要背景音乐

### 强适配

- 英雄、战士、奇幻角色、机甲或战队集结
- 每个角色有清楚外观和差异化能力的群像图
- 需要“逐个出场—释放能力—全员定格”的短片

### 弱适配

- 角色高度遮挡或图像分辨率过低
- 需要细腻对白、复杂剧情或准确口型的内容
- 只有文字描述、没有群像参考图
- 角色数量过多而成片时长过短

## 2. 权威与路由

```yaml
authority:
  reference_character_identity: hard
  reference_staging: hard
  story_direction: medium
  visual_identity: medium_high
  cinematography: hard
  performance: hard
  sound_design: medium
  music_direction: soft
  production_model: none

routing:
  pre_content_modules:
    load:
      - ensemble_entrance_compatibility
      - character_count_feasibility
  audiovisual_modules:
    load:
      - reference_identity_lock
      - entrance_progression
      - strong_perspective_cinematography
      - wind_environment_motion
      - transition_continuity
      - ensemble_finale
  production_modules:
    load:
      - single_generation_reference
      - placeholder_template_reference
      - model_adapter_reference
```

## 3. 角色识别与连续性

每个角色至少记录：

- 画面编号和原始站位
- 发型、发色、体型、肤色和面部辨识点
- 服装款式、颜色、材质与配饰
- 武器、道具和特殊装备
- 动作属性：近战、远程、法术、敏捷或力量倾向

```yaml
continuity:
  required: true
  lock:
    - 角色数量
    - 面部与体型
    - 服装与配饰
    - 武器类型与持握关系
    - 道具配置
    - 战斗属性
    - 最终站位顺序
    - 全片风向
```

角色识别报告是制作依据，不应把未看清的细节猜成硬事实。无法确认的字段保持 `null` 或标记为待确认。

## 4. 视听结构

### 角色出场段

- 每个角色先获得一个身份建立镜头，再获得一个与其武器或能力匹配的高光动作。
- 至少组合特写、中景、全景中的两到三类景别；短时长下优先保留特写和全景。
- 不同角色应使用不同的入场方向、动作节奏和转场方式。
- 允许跳跃、俯冲、冲刺、落地、蓄力、挥击、格挡和短暂停顿，但动作必须与身体重心、武器重量和空间关系一致。

### 集结收尾段

- 角色回到参考图对应站位，画面层次清楚。
- 多角色可快速逐一定型；单角色直接进入微动收尾。
- 最后一拍保留呼吸、眼神、头发、衣摆和武器的自然微动。
- 参考图有标题时可保留原文字信息；无标题时不新增文字。

原文的 80/20 和“角色数 × 4 秒、上限 15 秒”是生产估算，不是永久风格规则。

## 5. 视觉身份

- 高保真、绘画化纹理的电影 CG
- 高对比侧光或逆光，强化眼神、轮廓、武器和服饰材质
- 背景与角色世界观一致，但不喧宾夺主
- 前景碎屑、中景角色风效、背景雾气或旗帜形成三层空间
- 动作可夸张，但不扭曲人体、不改变武器比例
- 强透视用于武器前端、肢体前景、跳跃轨迹和空间压迫

## 6. 镜头语言

- 景别从极端特写、近景、中景、全景到大全景变化。
- 可用推拉、摇移、跟拍、升降、俯冲、甩镜和有限环绕。
- 关键表情、落地、武器命中或最终定格可短暂减速。
- 转场优先继承前镜动作方向、武器轨迹、遮挡物、烟尘或运动残影。
- 相邻角色不得机械复制同一套出场方式与转场。
- 竖屏强调纵向升降和垂直跟拍；横屏强调横向空间与群像关系。

## 7. 环境动力与表演

- 强风作为统一动力源时，头发、披风、衣摆、飘带、粉尘和旗帜方向必须一致。
- 风力应与角色动作联动，不得只让背景动、角色衣物静止。
- 大幅位移与爆发动作之后必须有落地、回弹、重心调整或环境反馈。
- 禁止站桩式展示、滑步、穿模、肢体崩坏、武器错位和角色混淆。

## 8. 声音与音乐

- 环境层：持续风声、尘土和空间低频。
- 动作层：武器破空、落地冲击、技能能量和衣物摆动。
- 背景音乐为可选项；存在时应根据角色整体属性选择史诗、暗黑、电子或管弦方向。
- 是否把音乐直接生成在视频内属于当前适配器决策，本 Profile 只要求音乐不能盖过动作音效。

## 9. 负面约束

- 不改变角色数量、服装、武器和最终站位
- 不让不同角色共享同一张脸或互换道具
- 不用相同节奏重复所有角色出场
- 不让强风方向跨镜头反转
- 不以过量镜头旋转掩盖角色辨识度
- 不添加参考图中不存在的标题、字幕或品牌标识
- 不把具体作品名、具体模型或固定提示词视为不可替换的 Style Core

## 10. 来源冲突与风险

```yaml
known_source_conflicts:
  - 角色越多，固定 15 秒上限越难同时满足身份建立、技能展示与集结清晰度
  - 原文要求每角色至少三类景别和强透视，但单角色 4 秒或多人 15 秒时可能不可执行
  - “一次生成完成全部角色”与高角色一致性目标存在能力风险
  - 模板要求模型自行识别角色，却同时禁止把已识别角色清单写入提示词，削弱了可审计的一致性约束

risk_notes:
  - 含具体商业作品风格引用；永久 Profile 已改写为可观察的高层视觉特征
  - 参考图中的文字、商标和角色权利需由使用者确认
```

## 11. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 多角色出场动画.md
style_profile:
  style_id: multi_character_ensemble_entrance
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: reference_image_ensemble
    feasibility_gate: character_count_vs_duration
  audiovisual_modules:
    visual_identity: painterly_cinematic_cg
    cinematography: differentiated_dynamic_entrances
    performance: weapon_and_attribute_matched
    environment_motion: unified_strong_wind
    continuity: reference_identity_and_final_staging
  production_modules:
    generation_pattern: single_pass_reference
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 多角色出场动画.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: audiovisual_grammar
        method: normalized
      - module: production_template
        method: direct
      - module: risk_notes
        method: inferred_structure_only
```
