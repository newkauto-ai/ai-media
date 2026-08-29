# Style Profile：电商产品 TVC 展示

> 源文档：`D:/AI 视频/Flova技能/电商产品TVC展示视频.md`  
> 源文件 SHA-256：`111453C6B0B1F428C06B947844EB6C5712802EB372AD6155C2D9C11814319836`  
> 解析版本：v1.0-zh  
> 解析状态：待审核；包含两个互斥视觉域

## 1. 定位结论

源文档实际包含两个不能混用的模式：

1. **TETO 动感展示域**：高对比冷青、粗颗粒、重拍快剪、爆发加速度、畸变与闪烁。
2. **产品 TVC 域**：莫兰迪低饱和、柔和扩散光、平滑推拉、卖点微距、叠化与轻音乐。

因此本 Profile 归类为 `mixed`。运行时必须显式选择 `dynamic_teto` 或 `product_tvc`，未选择时不得合并规则。

## 2. 共用核心

- 用户参考图是主体外观的视觉真值，形体、颜色、材质、Logo 位置与关键结构不得漂移。
- 先识别主体、评估背景、确认视觉焦点，再设计镜头。
- 焦点应是可描述的物理特征或卖点区域，不应只写抽象“视觉中心”。
- 产品与背景合成必须检查边缘、受光方向、色调融合和主体完整性。
- BGM 与视频生成分离，最终装配时再管理音乐与旁白关系。

## 3. 视觉域 A：TETO 动感展示

适配车辆、建筑、风景、宠物、人物和强调冲击力的产品展示。视觉特征包括冷青高对比、暗部深压、高光锐利、明显胶片颗粒、超广角速度感、急推急拉、甩镜、短弧环绕、跳剪与重拍触发特效。

主体类型决定机位：产品贴物微距、车辆低位贴地、建筑低位仰拍、风景高空航拍、动物眼平跟随、人物平视或微仰并限制广角畸变。

所有精确 BPM、歌词触发、11/13.5/16 秒节点、像素畸变和特效三档属于特定剪辑模板，不是 Style Core。

## 4. 视觉域 B：产品 TVC

只适配产品。核心是低饱和高级灰、真实产品色、柔和漫反射、高光不过曝、阴影保留层次、缓慢环绕、平滑推拉、卖点静定微距、全景—中景—特写交替和叠化转场。

叙事顺序为：全景建立 → 多个卖点展示 → 清晰收尾。BGM 只是低存在感情绪底层；如有旁白，音乐应让位。禁止把 TETO 的冷青强对比、爆发加速、白闪、球面畸变、RGB 色散、手持抖动和硬切带入该域。

## 5. 锚点规则修正

源文档把“全程偏差 ≤2px”写成生成与剪辑硬阈值。该数值只有在后期跟踪或可测画面中才有意义，不能假定生成模型能原生保证。Style Core 只保留：

- 主体焦点在镜头中持续可辨认；
- TETO 运动围绕焦点组织；
- TVC 的卖点区域在展示镜头中保持清晰；
- 精确坐标与容差进入后期 QC，并标记测量方法。

## 6. 已识别问题

- TVC 要求平滑匀速、禁止硬切；TETO 要求爆发变速、硬切和强特效。两域必须隔离。
- “纯色/无景深背景是不佳背景”与 TVC 极简无缝棚拍背景并不兼容；背景质量规则应按视觉域判定。
- 人物、动物、建筑和风景不是“产品 TVC”，只能进入 TETO 域。
- 精确 Logo、锚点像素和多角度一致性不能仅凭一张参考图保证；需额外产品视图或允许隐藏不可见面。
- 模型、720p/1080p、超分、重试次数与会员能力可能变化，执行前必须验证。

## 7. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 电商产品TVC展示视频.md
style_profile:
  style_id: ecommerce_dynamic_showcase_and_product_tvc
  version: 1.0-zh
  classification: mixed
  pre_content_modules:
    compatibility: 根据主体类型与传播目标选择唯一视觉域
    series_content_constraints: 产品真值与用户素材优先，不生成未经证实的卖点
  audiovisual_modules:
    visual_identity:
      dynamic_teto: 冷青高对比、深暗部、锐利高光、粗颗粒和速度冲击
      product_tvc: 莫兰迪低饱和、柔和扩散光、真实产品色和高级灰
    cinematography:
      dynamic_teto: 急推急拉、甩镜、俯冲、短弧环绕和主体类型机位
      product_tvc: 缓慢环绕、平滑推拉、卖点静定微距和景别循环
    editing_rhythm:
      dynamic_teto: 重拍快剪与爆发加速度
      product_tvc: 从容三段式与叠化过渡
    music_direction:
      dynamic_teto: 节奏驱动画面切点
      product_tvc: 低存在感氛围底层，不要求卡点
    continuity_schema: 主体形体、颜色、材质、Logo、卖点、焦点清晰度和背景受光
  production_modules:
    negative_constraints: 两个视觉域禁止混用
    model_adapter_reference: 模型、BPM 模板、时码、像素阈值和超分仅作适配参考
    generation_workflow: 主体分析、模式选择、背景决策、焦点确认、分镜、生成、QC、装配
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/电商产品TVC展示视频.md
        sha256: 111453C6B0B1F428C06B947844EB6C5712802EB372AD6155C2D9C11814319836
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

