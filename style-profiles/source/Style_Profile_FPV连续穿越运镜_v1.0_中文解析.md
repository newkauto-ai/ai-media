# Style Profile：FPV 连续穿越运镜

> **版本**：v1.0-zh  
> **源文档**：`无人机运镜一镜到底.md`  
> **内部风格 ID**：`fpv_continuous_flight_take`  
> **解析原则**：该文档首先是镜头技术生产手册，而非完整视听风格；只保留连续飞行、空间路线、相机运动和安全约束，不补造色彩、人物、旁白或音乐系统。

---

## 0. 解析结论

该文档应归类为 **单一镜头生产手册 + 局部摄影语言规范**。稳定核心是：第一人称 FPV 视角、基于真实空间的无分叉飞行路线、持续向前运动、平滑的推进与转向、全程无切镜，以及路线标记不进入最终画面。

它没有定义完整的色彩、灯光、角色、表演、声音、音乐或叙事系统，因此不能单独充当整片 Style Profile；适合与另一个视觉风格组合使用。

## 1. 文档分类与组合方式

```yaml
classification:
  primary: production_playbook
  secondary:
    - pure_visual_style
  full_series_canon: false
```

### 强适配

- 有明确场景图、空间路线图或可分析三维通道的场景
- 建筑、室内、街区、景观和装置的连续穿越展示
- 需要空间发现感、速度感或终点揭示的一镜到底

### 弱适配

- 路线分叉多、障碍密集、空间关系不可辨认的输入
- 需要跳切、倒叙、跨时空或多视角叙事的故事
- 主要依靠角色微表情、对白或复杂表演推进的内容
- 终点、路线和可通行空间尚未确认的项目

### 组合规则

本 Profile 只拥有 `cinematography` 与 `continuity` 的领域权威；色彩、材质、角色和声音应来自当前项目的主 Style Profile。

## 2. 空间解析与路线闸门

- 基准场景必须能识别起点、终点、建筑、墙面、家具、人物和障碍物。
- 路线必须连续、无分叉、可通行，并按先后顺序描述空间参照物。
- 只允许使用输入画面中真实存在或用户明确确认的对象，不得凭空补场景节点。
- 路线太复杂、标注不清或物理不可行时，状态应为 `blocked`，不得直接生成。
- 规划线、箭头和标记只用于分析，最终画面必须移除。

## 3. 摄影机身份与镜头运动

- 第一人称 FPV 穿越机视角
- 单一连续镜头，全程不间断
- 从基准首帧的真实机位出发，保持初始透视与空间布局
- 以持续向前推进为主，可组合平滑转向、横移、上升、下降、环绕和穿越
- 速度变化应与空间宽度、障碍距离和叙事重点一致
- 终点应有明确视觉意图，例如抵达主体、升高揭示全景或穿出空间

## 4. 连续性硬锁

- 不切镜、不跳切、不重置机位、不瞬移
- 不倒退、不无动机悬停、不突然更换视角
- 不跳过路线节点，不简化已确认轨迹
- 运动方向、转向半径和高度变化连续
- 空间结构、人物站位、光线和透视保持可追踪
- 不出现相机、无人机机身、螺旋桨、路线线条或规划覆盖层

## 5. 运动质感

- 默认平滑、稳定、具有飞行惯性，避免机械滑轨式僵硬。
- 可以有极轻微的空气扰动感，但不能把 FPV 误写成明显人类脚步式手持晃动。
- 慢滑行、中速穿梭和激烈追随应分别对应不同加速度与转向幅度。
- 标准电影术语如推进、拉远、跟随、环绕、摇摄和俯仰可用于表达，但必须服从连续飞行路径。

## 6. 声音与音乐

源文档未定义声音和音乐系统。

- `environment_sfx`：源文档未明确
- `drone_motor_sound`：源文档未明确是否保留
- `music_direction`：缺失
- `narration`：缺失

运行时不得从其他 Profile 自动补入；如需声音，应由主 Style Profile 或当前导演方案定义。

## 7. 负面约束

- 禁止任何切镜、瞬移、倒退、镜头重置与中途换视角
- 禁止路线线条、箭头、颜色标记、文字、水印和字幕
- 禁止相机或无人机设备进入画面
- 禁止残影、运动拖影、抖动和空间几何漂移
- 禁止凭空增加路线节点和不存在的场景对象

## 8. 来源冲突与处理

源文档存在两处明显冲突：

1. 核心身份写为“第一人称 FPV 穿越机”，通用规则又写“手持第一人称 POV”；本 Profile 以 FPV 为准，只允许轻微空气扰动，不采用人类步态晃动。
2. 核心规则禁止悬停，但运镜词库包含 `static` 倾向；本 Profile 将无动机悬停列为禁止，终点短暂停留只能由当前镜头设计显式批准。

源文档固定开头、英文尾句、4A、模型时长和分辨率均属于适配器语法，不进入永久镜头身份。

## 9. 可替换生产参考

```yaml
production_adapter_reference:
  replaceable: true
  source_mentions:
    duration_by_model: ["30s", "15s"]
    video_models: ["Seedance 2.5", "MiniMax H3", "Seedance 2.0"]
    aspect_ratio_default: "16:9"
    prompt_suffixes: ["no red lines", "no camera and drone", "no subtitles"]
```

## 10. 缺失项与可靠度

```yaml
missing_or_partial:
  color_system: 缺失
  light_system: 缺失
  character_system: 缺失
  sound_system: 缺失
  music_system: 缺失
  narrative_system: 缺失

reliability:
  route_analysis: high
  cinematography: very_high
  continuity: very_high
  full_style_identity: low
```

## 11. 机器可读摘要

```yaml
style_profile:
  style_id: fpv_continuous_flight_take
  version: "1.0-zh"
  classification: production_playbook
  pre_content_modules:
    route_gate: 需要可识别起点、终点、连续通道和真实空间参照物
  audiovisual_modules:
    cinematography: 第一人称 FPV 连续向前穿越
    motion: 平滑推进、转向、横移、升降、环绕与穿越
    continuity: 无切镜、无重置、无瞬移、无倒退、无视角切换
    sound: null
    music: null
  production_modules:
    adapter_reference: replaceable
    route_overlay_must_be_removed: true
  provenance:
    source_documents:
      - file: 无人机运镜一镜到底.md
        sha256: E339D153AC41BF07ED8C40D58F08E6C3B4EDD5C392714D785B275E0381F251E6
    extracted_modules:
      - module: 路线分析、运镜与连续性
        extraction: normalized
      - module: 固定提示词、模型、时长和分辨率
        extraction: direct
        routed_to: production_modules
```
