# Style Profile：方法论培训与课程视频

> **版本**：v1.0-zh  
> **源文档**：`方法论培训与课程视频生成.md`  
> **内部风格 ID**：`methodology_training_course_presentation`  
> **文档分类**：`production_playbook`（主）+ `hybrid_style_profile`（次）  
> **解析原则**：课程内容、公式、指标和合规要求必须来自用户文档；Style Profile 负责信息结构、课件呈现、讲师声音与音画组织，不得替用户改写事实或合规结论。

---

## 0. 解析结论

这是一套将方法论、业务 SOP、知识框架和复杂脑图转化为**专业课程课件视频**的混合型 Profile。核心价值不是某个生成模型，而是把高密内容变成可教、可看、可验证的视觉逻辑：先抽取角色、步骤、分支、公式、指标与红线，再用克制的商务幻灯片、流程图、专家卡、操作演示和分层配音呈现。

最重要的质量标准是**内容正确性与认知带宽**。画面必须服务理解，不能为了科技感堆叠光效；公式和图表不能脱离上下文；合规红线必须高对比呈现且由来源支持。

## 1. 适配范围

### 强适配

- 企业 SOP、方法论、培训大纲和产品发布培训
- 多角色协作机制、流程依赖、决策树和闭环模型
- 含 KPI、计算公式、合规拦截点的专业课程
- 脑图、拓扑图、系统操作与软件界面演示

### 弱适配

- 以情绪和故事体验为主的剧情片
- 缺少可靠原文、却要求生成专业结论的课程
- 需要观众阅读大量原文条款、但不允许拆页的内容
- 竖屏娱乐化快剪或高频镜头运动

## 2. 事实与内容边界

```yaml
factual_boundary:
  style_may_invent_methodology: false
  source_required_for:
    - 方法论定义
    - SOP 步骤
    - 公式与变量
    - KPI 数值
    - 合规红线
    - 处罚与异常分支
  examples_are_canon: false
```

- 跨章节引用可以合并解释，但不能改变原文条件与例外。
- 公式必须保留变量含义、推导关系和适用前提。
- 无法确认的组织角色、系统节点或阈值保持待确认。
- 若内容已冻结，新加载的风格规则与其冲突时记录 `UPSTREAM-CONSTRAINT-LATE`，不静默重写。

## 3. 权威与路由

```yaml
authority:
  content_semantics: none
  information_architecture: hard
  visual_identity: hard
  slide_layout: hard
  cinematography: hard
  narration_behavior: hard
  sound_mix_direction: medium
  production_model: none

routing:
  pre_content_modules:
    load:
      - source_structure_extraction
      - hierarchy_and_cross_reference
      - decision_branching
      - formulas_kpis_and_compliance
      - chapter_architecture
  audiovisual_modules:
    load:
      - slide_visual_system
      - layout_templates
      - diagram_animation
      - screencast_interaction
      - narration_direction
      - music_direction
      - subtitle_readability
  production_modules:
    load:
      - image_prompt_reference
      - video_prompt_reference
      - model_adapter_reference
      - mixing_and_transition_reference
```

## 4. 信息提炼规则

### 层级映射

- L0：课程总主题与总标题。
- L1：主章节；超过五个时可在不改语义的前提下归并为三至四个阶段。
- L2：单页核心论点或流程节点。
- L3：页面内要点、角色职责或执行子项。
- L4 及更深：拆成独立下钻页面，禁止堆在同一页。

### 复杂关系

- 多父节点共享对象只建立一次，并在多个页面引用同一逻辑资产。
- 双向箭头和反馈环路必须按闭环呈现，不能错误改成单向流程。
- 每个操作提炼为主干动作、准入条件和例外分支。
- “禁止、立即中止、红牌”等内容独立路由到合规警示页。

### 教学重点

- 角色与协作：谁负责、输入是什么、输出给谁。
- 步骤与分支：前后依赖、通过、驳回与回退。
- 模型与公式：变量、交互逻辑、输出结果和适用条件。
- 指标与红线：数值、触发条件、责任和后果。

## 5. 视觉身份

### 默认气质

- 专业、克制、清晰、逻辑优先
- 大面积纯净留白，极弱网格或导向线
- 扁平卡片、轻微阴影、规整圆角几何节点
- 无衬线字体，信息层级明确
- 16:9 宽屏课件为默认方向，但可由当前平台规格覆盖

### 色彩方案

- 科技蓝：冷灰或白底，低饱和蓝与青色强调
- 商务墨绿：石墨灰或米白底，墨绿边框与按钮
- 科技黑：黑灰底，白、蓝或青色细线强调
- 温暖米色：米色或麦芽色底，深褐与炭黑文字

同一项目只选一套主色系统；警示页可临时加入红、橙或荧光黄高对比强调。

## 6. 页面布局系统

### 左右分割

- 3:7 或 4:6 专家卡：左侧人物卡，右侧职责与要点。
- 6:4 或 7:3 流程页：左侧流程图，右侧解释文字。

### 上下分割

- 上方约三成放公式、定理或金句横幅。
- 下方约七成放两至三列概念拆解卡。

### 合规警示页

- 高反差警示带或通栏标题。
- 违规场景、触发条件和后果分开呈现。
- 旁白更短、更慢、更权威，并留出静止阅读时间。

### 系统操作演示

- 可用全屏界面或 7:3 界面加步骤卡。
- 明确光标路径、悬停目标、点击反馈和界面响应。
- 除光标、高亮和必要状态变化外，文字与布局保持静止清晰。

### 通用版式规则

- 四周保留约 10% 安全边距。
- 文字与图表使用统一对齐系统。
- 不允许卡片、标题或字幕贴边。
- 单页只承担一个主要教学任务。

## 7. 专家与图表资产

### 专家卡

- 正面胸像或 3/4 侧面，平视镜头。
- 人物占卡片主要区域，头顶和四周保留呼吸空间。
- 表情克制、自信、专业，避免夸张笑容或戏剧化怒容。
- 同一专家跨页锁定面部、发型、服装和配饰。

### 流程图

- 网格化、等间距、正交连线。
- 当前节点高亮，其余节点降饱和或置灰。
- 动画按讲解顺序逐节点激活。
- 闭环、共享节点和分支关系必须与原文一致。

## 8. 镜头与动画

- 以锁定镜头为主，保护文字与图表可读性。
- 必要时只做极缓慢推近，聚焦核心卡片、图表或人物面部。
- 推近幅度应很小，不能导致字体模糊、边缘畸变或空白区放大。
- 箭头流动、节点高亮、呼吸边框和光标点击是可用的局部动画。
- 除正在讲解的局部外，其余页面结构保持静止。
- 转场只用叠化或淡入淡出，避免 3D 翻转、花哨擦除和无意义缩放。

## 9. 旁白与音乐

### 旁白

- 常规页：理性客观、平稳自然。
- 公式与金句：睿智深沉或适度感召，重音清楚。
- 合规警示：严肃权威、语速更慢、句子更短。
- 中文语速和字数必须给图表阅读留出时间；原文的精确字数范围作为生产参考，不作为所有语言的永久硬阈值。
- 旁白结束后保留短暂纯视觉停留，不立即切页。

### 音乐

- 独立背景音乐，舒缓、沉浸、适合思考。
- 避免人声哼唱、强鼓点和抢夺注意力的旋律。
- 旁白出现时自动降低音乐存在感。
- 片头与片尾可有独立音效，但不能破坏全片专业气质。

## 10. 字幕与可读性

- 字幕使用半透明深色安全底，避开主图表和交互区域。
- 中文主字幕与英文副字幕分层，英文尺寸小于中文。
- 自动分行不得拆断英文单词或留下单字孤行。
- 页面内可读文字与后期字幕是两层资产，不能互相覆盖。

## 11. 负面约束

- 不编造课程结论、公式、指标或合规规则
- 不把一页塞入四级以上结构
- 不使用无规则交叉线和重复共享节点
- 不让动态效果造成文字抖动、变形或闪烁
- 不使用高饱和霓虹、厚重 3D 浮雕或廉价光晕
- 不让背景音乐盖过讲师声音
- 不为了缩短时长删除语义必要的停顿
- 不把具体模型、英文提示词片段和精确混音参数升级为永久 Style Core

## 12. 来源冲突与降级项

```yaml
known_source_conflicts:
  - 原文把若干混音和动画毫秒值写成绝对标准，但实际需由平台、语音时长和编辑器能力校准
  - 原文同时要求高精度画面内文字与视频动态变形零漂移，当前生成模型未必稳定满足
  - “一级分支超过五个自动归并”可能改变原文结构，必须先确认语义等价
  - 模型分辨率和会员权益描述属于可能变化的适配器信息

production_adapter_reference:
  replaceable: true
  source_mentions:
    - GPT Image 2
    - Seedance 2.5
    - Google Veo3.1 Fast
    - MiniMax Speech 2.8 HD
    - Final_Video_Spec.md
```

## 13. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 方法论培训与课程视频生成.md
style_profile:
  style_id: methodology_training_course_presentation
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    extraction: roles_steps_branches_formulas_kpis_compliance
    hierarchy: l0_to_l4_drilldown
    factual_source_required: true
  audiovisual_modules:
    visual_identity: restrained_business_slide
    layout: split_formula_alert_screencast
    cinematography: lockoff_or_micro_push
    narration: page_type_differentiated
    music: independent_low_attention_bed
    readability: hard
  production_modules:
    prompt_templates: reference_only
    mixing_parameters: runtime_calibrated
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 方法论培训与课程视频生成.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: content_structure
        method: direct
      - module: audiovisual_system
        method: normalized
      - module: production_parameters
        method: direct
```
