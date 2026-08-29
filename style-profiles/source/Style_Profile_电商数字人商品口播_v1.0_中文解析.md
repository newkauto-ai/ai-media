# Style Profile：电商数字人商品口播

> 源文档：`D:/AI 视频/Flova技能/电商数字人商品口播.md`  
> 源文件 SHA-256：`99D4F238D03E2745A4294194704BE2E844E5BAB6EC76CB50801B274B8C3FB9B5`  
> 解析版本：v1.0-zh  
> 解析状态：待审核，不代表数字人、声音或产品生成已获批准

## 1. 定位结论

这是**单场景、单构图、音频驱动的写实数字人口播 Profile + 制作手册**。核心不是丰富镜头变化，而是数字人身份、产品外观、场景、构图和音频时间线的稳定。

## 2. 适配范围

强适配：9:16 电商口播、产品讲解、短时促销和 UGC 式推荐。  
弱适配：多场景剧情广告、多机位访谈、需要展示复杂全身动作或产品细节切镜的影片。

## 3. 内容与事实边界

- 口播脚本必须来自用户文本或已确认产品优势；不得凭产品图片补造功效、参数、价格或合规声明。
- 用户没有上传产品图时，可以生成明确标注为“演示占位”的虚拟产品，但不能伪装成真实 SKU。
- 用户参考肖像只用于保留已授权的身份特征与氛围；未经确认不能推断年龄、种族或身份信息。
- 输出语言按角色画像、用户明确需求和输入语言决定，但用户明确指定始终优先。

## 4. 视听风格核心

### 视觉

- 写实摄影、自然或干净室内光、自然肤色、轻微稳定手持感，避免过度磨皮和网红脸。
- 只使用一个主场景、一个主构图和一张可复用关键帧；背景不因文案变化而改变。
- 以中近景或胸像为主，数字人的脸和产品同时清晰；全身镜头只有在服装或全身使用关系确有必要时使用。
- 产品的形体、颜色、包装、Logo 和拿取方式在全片保持一致。

### 表演与声音

- 音频是时间线的唯一时长依据；按完整句子切分，不直接按秒把一句话截断。
- 表演提示只描述说话状态、情绪、清晰可见的身体动作和背景事件。
- 旁白/口播是独立音频层，BGM 是独立全局底层；视频生成片段的额外音频在装配时避免重复。

## 5. 生产适配层

源文档中的 Nano Banana、OmniHuman 1.5、2K、1080p、15 秒限制与固定路径均为模型适配参考。执行前需要验证当前音频驱动能力、参考图权限、口型语言支持、最长音频、分辨率和成本。

## 6. 已识别问题

- Storyboard 明确要求单场景、单构图、单关键帧、禁止多机位；提示词段却建议交替双人、越肩和单人镜头。两者直接冲突。本 Profile 以更明确的“单构图连续性”作为核心，多机位建议不启用。
- “每个镜头生成关键帧”与“全片使用一个 asset_id”表述不一致；归一为：建立一张主关键帧，所有音频分段复用该资产。
- 生成演示产品只能作为占位素材，并需醒目标注，不能进入真实商品发布。
- “语调与时间轴匹配”需要实际音频时长或对齐结果验证，不能从脚本字数直接宣称完成。

## 7. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 电商数字人商品口播.md
style_profile:
  style_id: ecommerce_digital_human_product_pitch
  version: 1.0-zh
  classification: hybrid_style_profile
  pre_content_modules:
    compatibility: 单场景、单构图、音频驱动的电商口播
    dialogue_style: 清晰、直接、按完整句子切分
    series_content_constraints: 产品卖点必须来自用户确认资料
  audiovisual_modules:
    visual_identity: 写实手机摄影感、干净光线、自然肤色和克制美化
    character_visual: 锁定面部、发型、服装、配饰和授权参考特征
    environment: 全片固定一个主场景
    props: 产品始终清晰并保持包装、颜色、Logo 和拿取方式一致
    cinematography: 单一中近景或胸像构图，避免多机位变化
    performance: 情绪、说话状态、清晰发音和少量可见身体动作
    sound_design: 口播、BGM 与生成片段音频分层
    voice_system: 音频时间线是镜头时长的唯一事实来源
    continuity_schema: 数字人身份、产品、场景、构图、光线和持物方式
  production_modules:
    asset_prompt_templates: 数字人、产品、场景、主关键帧与音频驱动视频
    negative_constraints: 禁止产品过小、脸部不清、背景跳变、重磨皮和重复音频
    model_adapter_reference: 模型、分辨率、时长与语言能力需执行前验证
    generation_workflow: 规格、故事板、元素、主关键帧、音频、分段视频、装配
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/电商数字人商品口播.md
        sha256: 99D4F238D03E2745A4294194704BE2E844E5BAB6EC76CB50801B274B8C3FB9B5
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 storyboard_designer
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer 与 write_the_prompt
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator、write_the_prompt 与 video_assembler
        extraction_type: direct
```

