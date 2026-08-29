# Style Profile：金色美式怀旧与装饰艺术忧郁风

> **版本**：v1.0-zh  
> **源文档**：`盖茨比金色怀旧风格.md`  
> **内部风格 ID**：`golden_americana_art_deco_melancholy`  
> **文档分类**：`hybrid_style_profile`  
> **源文档别名**：盖茨比金色怀旧风格  
> **解析原则**：永久 Profile 使用可观察的色彩、光影、构图、胶片与情绪语法，不把在世艺人或具体影视作品名称作为生成指令。题材模板是候选库，不是固定分镜顺序。

---

## 0. 解析结论

这是一套结合 **1920s–1950s 美式怀旧、装饰艺术几何秩序、旧好莱坞胶片质感与美国梦幻灭情绪** 的完整视听 Profile。它的独特性不在“满屏金色”，而在公开浮华与私人孤独的交替：宴会、豪宅、珠宝、舞台和名车之后，紧接空酒杯、空座位、熄灯、独处或无人公路，让奢华成为失落的反证。

金色只作为高光和情绪节点；阴影保持冷绿或烟草棕，公开场合使用稳定对称的 35mm 语法，私人记忆和公路段使用偏心、轻手持的 16mm 语法。

## 1. 适配范围

### 强适配

- 时代爱情、家族、上流社会、爵士舞台与旧好莱坞题材
- Americana 公路、汽车旅馆、加油站、路边餐厅与荒漠远行
- 音乐影像、意识流回忆、梦境与美国梦幻灭主题
- 需要华丽与孤独强烈对照的短片、片头或片尾

### 中等适配

- 历史、美食、运动、悬疑与奇幻题材，但需使用对应题材路由
- 现代题材的复古化表达，前提是主动处理时代穿帮

### 弱适配

- 高饱和赛博朋克、现代科技产品演示
- 轻快喜剧、儿童治愈或无怀旧动机的纯功能内容
- 需要严格还原某位在世创作者独特风格的请求

## 2. 权威与路由

```yaml
authority:
  themes: medium
  story_direction: medium
  visual_identity: hard
  cinematography: hard
  performance: medium_high
  voice_behavior: medium
  music_direction: hard
  continuity: hard
  production_model: none

routing:
  pre_content_modules:
    load:
      - compatibility
      - public_private_contrast
      - american_dream_disillusionment
      - period_consistency
      - genre_route
  audiovisual_modules:
    load:
      - color_system
      - dual_visual_grammar
      - film_texture
      - cinematography
      - performance
      - voice_direction
      - sound_and_music
      - continuity
  production_modules:
    load:
      - character_reference_layout
      - prompt_keyword_reference
      - model_adapter_reference
      - finishing_reference
```

## 3. Pre-Content 主题规则

- 核心主题：欲望、等待、距离、怀旧、阶层、浮华残影、无法抵达的目标。
- 情绪必须通过可见结果表达：散落亮片、喝剩的酒、空房间、错开的视线、车窗阻隔、遥远灯光或无人公路。
- 每个漂亮镜头都必须承担建立空间、推进动作、改变关系、揭示信息或完成情绪反应中的至少一项。
- 题材模板只提供候选镜头，不为符合风格强行添加无关香槟、名车、珠宝或回眸。
- 公路加悬疑同时出现时，优先使用冷色危机路由，不套用浪漫金色公路模板。

## 4. 全局视觉身份

### 色彩

- 香槟金：局部高光与情绪释放
- 烟草棕：中间调、木材、皮革与旧胶片基底
- 翡翠绿：冷色阴影与心理距离
- 象牙白：服装、字幕和装饰艺术留白
- 落日茜红：黄昏与公路情绪点缀

暖色高光与冷色阴影形成分离；中间调适度降饱和。避免全画面金黄滤镜。

### 光线

- 户外：有真实太阳入镜条件时使用黄昏逆光。
- 室内：烛光、琥珀钨丝灯、舞台灯或窗缝光。
- 体积光必须有现实光源和烟尘、雾气等介质。
- 水平椭圆光斑仅在强点光源正对镜头时低强度出现。

### 画幅与质感

- 优先宽银幕构图，次选常规横屏。
- 公开场合：细腻 35mm 颗粒、稳定曝光、深黑保留服装纹理。
- 私人时刻：16mm 颗粒、轻微曝光漂移、偶发跳帧或竖划痕。
- 同一场景类型内不混用两套胶片规则。

## 5. 双重视觉语法

### 公开场合

- 场景：宴会、豪宅、舞台、上流社会空间。
- 构图：装饰艺术对称、稳定中心、几何边框与纵深轴线。
- 镜头：锁定、缓慢推移或摇臂，禁止手持抖动。
- 表演：克制、收敛、保持体面。
- 色彩：黑与象牙白为底，香槟金只作局部高光。

### 私人时刻

- 场景：回忆、公路、汽车旅馆、独处与私人影像。
- 构图：偏离中心、门框或车窗框架、留出负空间。
- 镜头：轻微手持、自然曝光漂移。
- 表演：视线回避、停顿、细微失落与迟疑。
- 色彩：褪色暖白、烟草棕和冷绿阴影。

### 强制对照

公开浮华后紧接一个私人空缺镜头。该规则服务“繁华越盛，失落越明显”的主题，不要求逐镜机械交替。

## 6. 人物、场景与道具

### 人物

- 服装、发型、妆容、鞋履和配饰符合目标年代。
- 同一角色跨镜头锁定面部、发际线、服装轮廓和珠宝位置。
- 有台词角色需要稳定声线参考，并覆盖平静、起伏和低落三类情绪。

### 场景

- 装饰艺术豪宅、爵士夜总会、旧片场、海湾码头。
- 双车道公路、旧加油站、路边餐厅、汽车旅馆、褪色广告牌。
- 公路场景明确车内挡风玻璃视角或车外低机位追拍。

### 道具

- 香槟杯、留声机、旧相片、情书、烛台、老式电话。
- 年代车辆、铬饰仪表盘、旧路牌、纸质地图、皮革手提箱。

道具必须推动情节或承载人物关系，不作为纯装饰清单。

## 7. 镜头与表演

- 普通叙事镜头以一个主要动作或关系变化为单位。
- 可用远景建立距离、近景捕捉克制表情、微距呈现手指、眼神与道具。
- 推、摇、摇臂、焦点转移和有限变焦按叙事功能选择。
- 慢动作只用于情感高潮、回眸、冲线、蒸汽或汗水等关键节拍。
- 光斑、颗粒、划痕和曝光漂移都是点缀，不覆盖主体叙事。
- 台词配合微表情、停顿、重音、气声和整句情绪弧线。

## 8. 题材路由摘要

- 历史：服化道细节、窗格影、走远背影、逐渐褪色。
- 美食：黄昏空镜、烹饪微距、蒸汽、空碗余韵。
- 运动：逆光起跑、汗水与呼吸、冲线、赛后空场。
- 爱情：双人距离、焦点在两人间移动、接触微距、分离收尾。
- 悬疑：低角度压迫、局部线索、倾斜构图、冷绿深阴影。
- 音乐影像：低饱和开场、随音乐逐步恢复色彩、象征性蒙太奇。
- 梦境：轻柔焦、曝光漂移、漂浮动作、现实与梦境使用不同声音层。
- 公路：消失点远景、挡风玻璃与后视镜、沿途地标、夜间车灯。
- 悬疑公路：漂白沙黄加冷绿、近黑夜路、车灯白光和后视镜焦虑构图；禁用大面积金色逆光。

## 9. 声音与音乐

- 角色声线与旁白声线分开管理。
- 角色台词保留微表情、停顿和情绪弧线。
- 旁白可选择忧郁梦呓、沧桑电台、南方绅士、年代广播或梦境低语等行为特征，不锁定具体真人音色。
- 现实段可用爵士钢琴、弦乐或旧广播质感；梦境段使用无强拍环境音垫层。
- 公开场合音乐可更华丽，私人段降低密度与速度。
- 背景音乐独立生成与混音，旁白始终优先。

## 10. 负面约束

- 不把金色铺满全画面
- 不使用无光源依据的体积光与数字粒子
- 不使用高饱和霓虹、HDR 数字感和夸张色彩反转
- 不让光斑横扫、爆发或充满画面
- 不在普通走路、对话和过渡中滥用慢动作
- 不让现代手机、LED 屏、当代车辆或服装破坏年代感
- 不把来源中的艺人名或具体作品名作为永久生成指令
- 不让华丽镜头连续堆叠而缺少人物空缺与代价

## 11. 来源冲突与降级项

```yaml
known_source_conflicts:
  - 源文档连续两次标注“ED 30 秒”，第一套时间码实际只到 15 秒
  - 音乐影像部分一处要求色彩逐步恢复，后文候选词又写“突然全彩爆发”，永久 Profile 采用渐进恢复
  - 公路模板一处允许光斑横穿，核心规则明确禁止夸张横扫；永久 Profile 以有光源、低强度为准
  - 梦境部分核心规则要求克制，后文词库出现高饱和、双倍体积光和快速白闪；永久 Profile 不继承这些夸张项
  - 若干年代服饰清单与具体品牌名属于生产参考，不能自动成为当前角色事实

production_adapter_reference:
  replaceable: true
  source_mentions:
    - Nano Banana Pro
    - Seedance 2.5
    - Suno 5
    - MiniMax Speech 2.8 HD
    - MediaKit
```

## 12. 机器可读摘要

```yaml
fixture_only: false
library_status: pending_review
normalized_from_source: 盖茨比金色怀旧风格.md
style_profile:
  style_id: golden_americana_art_deco_melancholy
  version: 1.0-zh
  classification: hybrid_style_profile
  pre_content_modules:
    themes: desire_distance_disillusionment
    story_direction: public_opulence_vs_private_absence
    period_consistency: required
  audiovisual_modules:
    visual_identity: golden_americana_art_deco
    color: warm_highlight_cool_shadow_separation
    film_texture: public_35mm_private_16mm
    cinematography: restrained_functional
    voice: behavioral_presets_without_real_person_lock
    music: jazz_strings_ambient_by_domain
    continuity: period_character_and_prop_lock
  production_modules:
    keyword_library: reference_only
    model_adapter: replaceable
  provenance:
    source_documents:
      - file: 盖茨比金色怀旧风格.md
        extraction: direct_and_normalized
    extracted_modules:
      - module: themes_and_dual_grammar
        method: direct
      - module: audiovisual_system
        method: normalized
      - module: artist_reference_neutralization
        method: inferred_structure_only
```
