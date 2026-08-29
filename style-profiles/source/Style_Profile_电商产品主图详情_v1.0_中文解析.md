# Style Profile：电商产品主图与详情页

> 源文档：`D:/AI 视频/Flova技能/电商产品主图详情生成.md`  
> 源文件 SHA-256：`4746330FD67F19F40B2DF5EAEBF5664868E3F49D8B1E613038AE06AF0A4B159F`  
> 解析版本：v1.0-zh  
> 解析状态：待审核；默认仅处理静态图像

## 1. 定位结论

这是**电商静态视觉全案制作手册**。它从产品参考图建立产品真值基线，再组织主图、卖点图、材质特写、对比图与规格图。除非用户明确要求，不能进入视频流程。

## 2. 产品真值边界

- 产品参考图是形体、比例、颜色、表面、Logo、接口、按键和结构分区的最高视觉依据。
- 没有尺度参照时，不能从单张图片可靠推断毫米尺寸、曲率半径或真实长宽高；只能标记为视觉估计。
- 没有色卡、已知白平衡或原始文件时，HSL 数值只能作为当前图片中的测量结果，不能升级为产品真实色。
- 产品卖点、材料等级、防水能力和性能结论必须来自用户已确认信息；视觉意象不能反向证明产品性能。

## 3. 图集结构

建议结构为三张主图和六至八张详情页，但数量应按平台、产品复杂度和实际卖点调整。

- 主图：场景氛围、卖点结构、白底标准图。
- 详情：使用场景、材质微距、功能结构、对比验证、尺寸与配件。
- 每张图需明确唯一用途、景别、视觉焦点、卖点意图和参考资产。
- 详情页焦点可以形成自然扫读节奏，但固定 Z/F 路径不是跨平台硬规则。

## 4. 视听风格核心

本 Profile 只含视觉：高端商业摄影、物理合理布光、真实材质、清晰轮廓、受控色彩和卖点聚焦。主导色与强调色比例、焦点坐标、白底阈值和审计容差属于生产 QC，不是永恒风格规则。

跨图持续跟踪：轮廓比例、产品朝向、结构分区、主色、材质反射、Logo 位置、文字、接口、背景与道具调性。

## 5. 提示词与模型层

源文档要求英文提示词、120–200 词、固定参考标签、固定负面词和特定模型。这些都属于适配器规则，不进入 Style Core。实际执行应依据当前模型语言表现和参考图能力编译；本中文 Profile 只保留语义结构。

## 6. 已识别问题

- 一方面要求严格继承真实 Logo，另一方面通用负面词要求 `no brand identifiers`，存在直接冲突。应按任务区分：合法展示真实产品时保留已授权 Logo；生成无品牌演示品时禁止虚构品牌。
- “白底 RGB 均值大于 245”只能用于实际图像测量，不能靠文字审查宣称通过。
- “9:1 色彩克制”“固定三主图加六至八详情页”是建议模板，不是所有平台和品类的硬规则。
- 爆炸图、尺寸图、文字标注和对比验证涉及事实准确性，不能只靠生成图；应使用可编辑图形层和已核实数据。

## 7. 机器摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 电商产品主图详情生成.md
style_profile:
  style_id: ecommerce_product_image_suite
  version: 1.0-zh
  classification: production_playbook
  pre_content_modules:
    compatibility: 有真实产品参考与已确认卖点的电商静态视觉
    series_content_constraints: 不得从图片补造尺寸、材料等级、性能或品牌事实
  audiovisual_modules:
    visual_identity: 高端商业摄影、物理合理布光、真实材质、受控色彩
    props: 产品是唯一核心资产并保持真值一致
    environment: 白底、场景与道具按图位功能选择
    cinematography: 建立、中景、微距、平铺和标准棚拍等静态景别
    continuity_schema: 轮廓、比例、颜色、材质、Logo、结构、朝向、接口和文字
  production_modules:
    asset_prompt_templates: 主图、白底图、卖点图、材质微距、对比图和规格图
    negative_constraints: 禁止产品形变、随机文字、水印、物理错误光影和无关道具
    model_adapter_reference: 模型、英文提示词、词数、坐标和容差均需当前适配
    generation_workflow: 基线提取、规格、图集规划、参考绑定、批量生成、一致性审计
  provenance:
    source_documents:
      - file: D:/AI 视频/Flova技能/电商产品主图详情生成.md
        sha256: 4746330FD67F19F40B2DF5EAEBF5664868E3F49D8B1E613038AE06AF0A4B159F
    extracted_modules:
      - field: pre_content_modules
        source_section: planner 与 multimodal_analyze_tool
        extraction_type: normalized
      - field: audiovisual_modules
        source_section: storyboard_designer
        extraction_type: normalized
      - field: production_modules
        source_section: media_generator 与 write_the_prompt
        extraction_type: direct
```

