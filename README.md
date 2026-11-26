# 测光表（LightMeter）

面向胶片摄影师的 iOS 单机测光应用：用 iPhone 测量场景亮度，给出可直接拨到胶片机上的 **感光度 / 光圈 / 快门** 建议。

无账号、无云端，全部在本地完成。

---

## 要验证的核心假设

> 胶片 / 手动相机用户会信任手机测光结果，并用它来设置 ISO · 光圈 · 快门，而不必依赖硬件测光表。

当前版本是围绕该假设的最小可用原型（MVP）。

---

## 功能概览

| 能力 | 说明 |
|------|------|
| 实时测光 | 读取后置相机自动曝光参数，反推场景 **EV₁₀₀** |
| 相机预览 | 全屏取景，UI 仅压在顶部 / 底部 |
| 胶片感光度 | 常用档位滑轮 + 手动输入；主界面只显示当前 ISO |
| 优先模式 | **快门优先** 或 **光圈优先**；当前模式高亮，另一侧标「计算」 |
| 曝光补偿 | ±2 档（⅓ 档步进），有效测光 = EV + 补偿 |
| 取景倍率 | 多摄机型显示 0.5 / 1x / 1.5 / 2 / 3 等；单主摄不显示倍率条 |
| 设定记忆 | 用户选过的 ISO、补偿、优先模式、对应用户档、倍率会本地保存 |
| 中英文 | 跟随系统语言（`zh-Hans` / `en`） |

---

## 测光原理（简述）

系统相机不会直接返回「某点的 EV」。本应用采用：

1. 开启连续自动曝光  
2. 读取当前 **ISO、快门、光圈**  
3. 反推场景亮度 **EV₁₀₀**  
4. 结合用户设定的 ISO +（光圈或快门）+ 曝光补偿，算出另一项  

因此测的是 **当前取景范围内的等效亮度**。切换倍率会改变视野，测光结果通常也会变化——这是预期行为。

> 当前不做点击局部测光；那需要分析预览帧像素，属于后续能力。

---

## 取景倍率说明

- **显示倍率**对齐系统相机习惯（0.5 / 1x / 2 / 3…），不是底层原始 `videoZoomFactor`（多摄上常见为 1 / 2 / 6）  
- **首次**获得相机权限后探测本机可用档位并缓存；之后启动直接读缓存  
- 可选档 **≥ 2** 才显示浮层切换；仅主摄时界面与无倍率版本相同  

---

## 技术栈

- SwiftUI + AVFoundation  
- iOS 17+  
- 本地持久化：`UserDefaults`  
- 本地化：String Catalog（`Localizable.xcstrings` / `InfoPlist.xcstrings`）  

Bundle ID：`com.watstudio.LightMeter`

---

## 工程结构

```
LightMeter/
├── LightMeterApp.swift          # 应用入口
├── ContentView.swift            # 主界面
├── CameraMeter.swift            # 相机会话、测光采样、变焦
├── CameraPreview.swift          # 预览层（UIKit 桥接）
├── ExposureMath.swift           # EV / 曝光三角 / 补偿计算
├── ZoomCapability.swift         # 倍率探测与显示↔设备换算
├── MeterPreferences.swift       # 用户设定与能力缓存
├── PickerSheets.swift           # ISO / 补偿 / 快门 / 光圈选择器
├── Theme.swift                  # 颜色与视觉常量
├── Localizable.xcstrings        # 界面文案
├── InfoPlist.xcstrings          # 桌面名、权限说明
├── Info.plist
└── Assets.xcassets              # 图标等

DesignOptions/                   # 设计稿（不参与编译）
```

---

## 本地运行

1. 安装 Xcode，打开 `LightMeter.xcodeproj`  
2. **Signing & Capabilities** → 勾选自动签名 → 选择 Team  
3. 真机运行（测光与多摄倍率需实物；模拟器仅 UI / 假 EV）  
4. 首次在手机上需：**信任开发者证书**、允许 **相机** 权限  
5. 若提示 Developer Mode：系统设置 → 隐私与安全性 → 开发者模式  

---

## 设定持久化规则

**会保留（用户设定）**

- ISO、曝光补偿  
- 优先模式（快门 / 光圈）  
- 该模式下用户选过的快门或光圈（两侧各自上次手选值都会记）  
- 当前取景倍率  
- 本机可用倍率列表（首次探测）  

**不保留（系统计算）**

- 由测光算出的另一项 → 每次按当前 EV 重算  

---

## 设计演进（摘要）

1. 单屏三角曝光 + 锁定读数（初版）  
2. 改为胶片工作流：ISO 少改、优先模式、曝光补偿、EV 置顶、预览为主  
3. 增加取景倍率，并修正多摄显示倍率与内部 zoom factor 的换算  

相关静态稿见 `DesignOptions/`。

---

## 已知边界

- 测光精度依赖手机 AE，非实验室级入射式测光表  
- 不同机型可用倍率不同，属硬件能力差异  
- 点测 / 分区 EV、胶片焦段→FOV 预设等尚未实现  

---

## App Store 上架

- 支持页 / 隐私页：[`docs/`](docs/)（GitHub Pages）  
- 文案与 ICP：[`StoreListing/ASC_China_drafts.md`](StoreListing/ASC_China_drafts.md)  
- 打赏规格：[`StoreListing/Tips_Product_Spec.md`](StoreListing/Tips_Product_Spec.md)  
- **首发可勾选清单**：[`StoreListing/ASC_Launch_Checklist.md`](StoreListing/ASC_Launch_Checklist.md)  

## 下一步可考虑

- 点按画面局部测光  
- 胶片焦段快捷预设（近似匹配取景）  
- TestFlight 给更多胶片用户试用  

---

## 许可

私有项目，默认未开放开源许可。
