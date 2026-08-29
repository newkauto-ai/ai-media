# Style Profile：短剧前期视觉开发定调

> 源文档：`D:/AI 视频/Flova技能/短剧前期视觉开发定调.md`  
> 源文件 SHA-256：`E0FB49E8FB8A937ED715B104271B96B4E550A85DEDF7935B138467C9B0249356`  
> 解析版本：v1.0-zh  
> 解析状态：待审核，不代表用户已批准任何生成或付费调用

## 1. 定位结论

这是一份**短剧视觉开发制作手册**，不是固定美术风格。它负责从剧本提炼视觉锚点，建立角色、场景、道具、造型、色彩、妆发、声音与概念样片的统一开发包；默认的“商业短剧写实”只能在剧本没有明确风格且用户确认后使用。

最可复用的核心是：先定风格，再锁资产；只选 3–5 个代表镜头做概念样片；复合面板只作为视觉文档，不作为可执行镜头资产；图像、文档、音频和样片分层交付。

## 2. 适配范围

强适配：真人短剧、都市情感、悬疑、年代、古装等需要前期定调和跨部门沟通的项目。  
中等适配：广告叙事、MV 概念开发、人物群像提案。  
弱适配：只需要单张成图、已经完成完整美术设定、或需要直接批量生成完整成片的任务。

## 3. 上游内容约束

- 剧本与分镜是事实和剧情来源，Profile 不得改写剧情、台词、人物关系或情绪节点。
- 剧本未给出美术方向时，只能提出 3–4 个候选方向并说明理由，不能擅自锁定默认风格。
- 只为用户确认的 3–5 个代表镜头建立概念样片 Storyboard；未选镜头不应被假装已经设计。
- 图面文字语言必须在规格阶段显式确认；角色名、场景名、道具名保持剧本原写法。

## 4. 视听风格核心

### 视觉系统

- 角色：身份、年龄、五官、体型、发型、服装材质与标志特征形成连续性锁。
- 场景：空间布局、墙地材质、时间、主光方向、光质和 3–6 个视觉锚点形成场景锁。
- 道具：形态、材质、颜色、磨损与归属关系形成道具锁。
- 色彩：建立全剧主色、辅色、点缀色，以及铺垫—铺陈—转折—高潮的色调弧线。
- 视觉资料：角色设定卡、场景参考、道具参考、服装细节、妆发、关系图、氛围板和调色板各自承担单一职责。

### 摄影与剪辑

- 景别、角度、运动和焦段必须服务镜头的故事节拍。
- 概念样片优先展示风格代表性、角色/场景一致性和叙事节奏，不追求覆盖全剧。
- 复合九宫格、多角度矩阵、关系图与 PPT 页面属于沟通资产，不可当作单镜生成参考直接执行。

### 声音

- 角色音色样本用于声音身份参考，不等于概念样片对白。
- BGM、旁白、角色对白和环境音分轨管理。
- 环境音样本是音频设计参考，除非明确绑定，否则不进入样片时间线。

## 5. 生产适配层

源文档中 GPT Image 2、Seedance 2.0、720p/2K、4–15 秒单镜、10 页 PPT、30–60 秒样片等均为生产参考，执行前必须按当前模型能力、成本与交付规格复核。图像中的复杂可读文字不应仅依赖生成模型，重要文字应保留可编辑后期方案。

## 6. 已识别问题

- 流程中 PPT 展示与确认步骤出现重复编号，后续依赖编号也有错位，不能直接当作机器状态机。
- 文档同时强调“仅做前期素材包”和“生成概念样片”；两者并不矛盾，但交付时必须明确样片不是完整成片。
- 默认商业短剧写实标签不是跨题材永久 Canon；古装、水墨、悬疑等项目必须替换为项目已确认方向。
- 复杂中文标注、关系线和 PPT 正文由图像模型直接生成存在可读性风险，应优先输出可编辑版式。

## 7. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 短剧前期视觉开发定调.md
style_profile:
  style_id: short_drama_preproduction_visual_development
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: 短剧及叙事型真人内容的前期视觉开发
    story_direction: 只提取剧本既有节拍，不改写剧情
    series_content_constraints: 未确认视觉风格时必须先选择方向
  audiovisual_modules:
    visual_identity: 由剧本锚点与用户确认的风格共同定义
    character_visual: 锁定外貌、服装、妆发和状态变体
    environment: 锁定空间、材质、时间、光源和视觉锚点
    props: 锁定形态、材质、颜色、磨损和归属
    cinematography: 景别、角度、运动、焦段服务故事节拍
    sound_design: 环境音与音效作为独立参考层
    voice_system: 角色音色样本与正式对白分离
    music_direction: BGM 独立成轨并服从样片节奏
    continuity_schema: 角色、场景、道具、色彩和状态连续性
  production_modules:
    asset_prompt_templates: 角色、场景、道具、造型、氛围、海报和提案页模板
    model_adapter_reference: 源文档模型与分辨率仅作可替换参考
    generation_workflow: 风格确认、选片、故事板、资产、扩展包、文档、样片、交付清单
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/短剧前期视觉开发定调.md
        sha256: E0FB49E8FB8A937ED715B104271B96B4E550A85DEDF7935B138467C9B0249356
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 multimodal_analyze_tool
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator、write_the_prompt 与 video_assembler
        extraction_type: direct
```

