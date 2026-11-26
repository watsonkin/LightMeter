# App Store 中国区上架文案草稿

供复制到 App Store Connect。按实际产品微调后使用。

首发含**自愿打赏内购**（三档 tip，不解锁功能）。操作清单见 [`ASC_Launch_Checklist.md`](ASC_Launch_Checklist.md)。

---

## 1. 商店元数据（简体中文）

### 名称
```
测光表
```
（若被占用：测光表 LightMeter / 胶片测光表）

### 副标题（≤30 字符，含标点）
```
胶片相机曝光助手
```

### 宣传文本（可选，可随时改，不随版本审核）
```
单机测光，专为胶片与手动相机。对准主体，设定 ISO 与优先模式，立刻得到可拨的光圈或快门。
```

### 描述
```
测光表是一款面向胶片与手动相机用户的单机测光工具。用 iPhone 测量场景亮度，给出可直接拨到相机上的曝光建议。

【适合谁】
• 使用无内置测光或测光不准的胶片机
• 需要光圈优先 / 快门优先快速出参数
• 希望手机取景范围尽量贴近实际焦段视野

【核心功能】
• 实时测光：显示 EV，并换算曝光建议
• 胶片感光度：常用 ISO 档位 + 可手动输入
• 快门优先 / 光圈优先：锁定你设定的一侧，计算另一侧
• 曝光补偿：最多 ±2 档（⅓ 档步进）
• 取景倍率：多摄机型可切换 0.5x / 1x / 2x / 3x 等（随机型能力显示）
• 本地记忆：记住你的 ISO、优先模式与偏好设定
• 完全单机：无需账号、无需联网
• 可选打赏：自愿支持开发（不解锁任何功能）

【使用提示】
手机测光为反射式估算，不同机型可能有轻微偏差。可用曝光补偿按你的胶片与习惯微调。重要拍摄建议先试拍验证。

【隐私】
测光在设备本地完成。我们不收集个人信息，不要求注册登录。
```

### 关键词（≤100 字符，逗号分隔，勿重复 App 名废话堆砌）
```
测光,胶片,曝光,光圈,快门,ISO,EV,旁轴,手动相机,反转片
```

### 支持网址
静态站见仓库 [`docs/`](../docs/)。GitHub Pages 发布后填入实际地址，例如：

```
https://<GitHub用户名>.github.io/<仓库名>/
```

示例（仓库名 `LightMeter`、用户 `watstudio`）：
```
https://watstudio.github.io/LightMeter/
```

### 隐私政策网址
```
https://<GitHub用户名>.github.io/<仓库名>/privacy.html
```

示例：
```
https://watstudio.github.io/LightMeter/privacy.html
```

正文已写在 `docs/privacy.html`（本地测光、无账号、无上传、无广告/分析；可选 Apple IAP 打赏由 Apple 处理）。

### 类别
- 主要：摄影与录像  
- 次要：工具（可选）

### 年龄分级
4+

---

## 2. App 审核备注（Review Notes）

英文为主（审核团队常用），可中英对照粘贴：

```
App name: LightMeter / 测光表
Bundle ID: com.watstudio.LightMeter

What the app does:
An offline light meter for film and manual cameras. It uses the rear camera’s exposure metadata to estimate scene EV and recommends shutter or aperture based on the user’s ISO and priority mode (shutter-priority or aperture-priority). Optional exposure compensation (±2 stops) and optical zoom stops when the device supports multiple cameras.

Login: None. No account required.

Network: Metering works fully offline. No analytics, no ads, no developer backend. Optional tip purchases contact Apple’s StoreKit / App Store servers only.

How to test:
1. Use a physical iPhone (Simulator has no camera / limited metering).
2. Grant Camera permission when prompted.
3. Point at a subject; EV updates live.
4. Tap ISO / ± compensation / shutter or aperture priority to change settings.
5. If the device has multiple rear cameras, zoom chips appear above the bottom bar.
6. Tap the top-left 测光 wordmark to open the tip sheet. Select a tier, then Confirm. Tips are optional and do not unlock features.

In-App Purchases:
Three optional consumable tips (US: $0.99 / $2.99 / $5.99):
  com.watstudio.LightMeter.tip.tier1
  com.watstudio.LightMeter.tip.tier2
  com.watstudio.LightMeter.tip.tier3

Tips do not unlock features, remove ads, or change metering behavior.
Core light-meter features remain free. No third-party payments.

China mainland:
This app provides no internet information services of its own (no developer server, no UGC, no account). Optional tips use only Apple IAP. We are applying / will apply for ICP filing exemption as an offline utility. Please see App Compliance declarations (no AIGC / no regulated features).
```

---

## 3. ICP 豁免 · Contact Us 模板

入口：https://developer.apple.com/contact/  
（或开发者页面底部「联系我们」）  
问题类型可参考：分发 / App 审核相关其他问题（以页面选项为准）。

### 英文版（建议主送）

```
Subject: Request for Mainland China ICP filing exemption – offline light meter app

Hello Apple Developer Support,

I would like to request an exemption from the Mainland China ICP filing requirement for the following app:

• App Name: LightMeter (测光表)
• Apple App ID: [填 App Store Connect 里的 Apple ID 数字]
• Bundle ID: com.watstudio.LightMeter
• Team ID: [填你的 Team ID]

Reason for exemption:
This is a fully offline utility app for film / manual camera exposure metering.

• No developer-operated servers or backend
• No user accounts or login
• No user-generated content, community, or content distribution
• Camera frames are processed only on-device to estimate exposure; we do not upload photos or metering data
• No third-party advertising or analytics SDKs that transmit user data
• Optional tips only via Apple In-App Purchase (Apple servers); no third-party or self-hosted payments. Tips do not unlock features.

The app does not provide an internet information service that would require MIIT APP filing for our use case. Please grant an ICP filing exemption so the app can be available on the App Store in Mainland China.

I am prepared to provide a signed legal declaration as required.

Thank you,
[法定姓名]
[Apple ID 邮箱]
[Team ID]
```

### 中文版（可作附件或补充）

```
主题：申请中国大陆 App Store ICP 备案豁免 – 离线测光工具

您好，

本人申请对以下 App 豁免中国大陆 ICP / 移动应用程序备案要求：

• App 名称：测光表（LightMeter）
• Apple App ID：[填写]
• Bundle ID：com.watstudio.LightMeter
• Team ID：[填写]

豁免理由：
本应用为胶片 / 手动相机用的纯单机测光工具。

• 无自建服务器或后端服务
• 无用户账号与登录
• 无 UGC、社区或内容分发
• 相机画面仅在设备本地用于估算曝光，不上传照片或测光数据
• 未接入广告或向第三方发送数据的统计分析 SDK
• 仅有通过 Apple 内购的可选打赏，无自建或第三方收款；打赏不解锁任何功能

本应用不提供需履行 APP 备案的互联网信息服务。恳请批准 ICP 备案豁免，以便在中国大陆 App Store 上架。

如需签署法律责任声明，本人可按贵方模板提供手写签名文件。

此致
[法定姓名]
[联系邮箱]
[Team ID]
```

### 声明信常见要素（苹果回信后按要求补）

收到要求后，PDF 中通常需包含：

- Team ID  
- 开发者法定姓名（正楷）  
- App ID / Bundle ID  
- 案例号（Case ID）  
- 手写签名 + 日期  
- 承担相应法律责任的声明句  

用 iPhone「文件 / PDF 标记」手写签名即可；上传走苹果提供的安全链接，并回复原邮件确认「已上传」。

---

## 4. 操作顺序备忘

完整可勾选清单见 [`ASC_Launch_Checklist.md`](ASC_Launch_Checklist.md)。

1. Developer 年费账号 + **Paid Apps** 协议（银行/税务）  
2. GitHub Pages 发布 `docs/`（支持页 + 隐私页）  
3. ASC 新建 App，价格 = 免费，勾选中国大陆  
4. 创建三档 tip 消耗型内购并关联版本  
5. 上传 Build，填简体中文元数据 + 审核备注  
6. App 合规：声明无 AIGC / 无需安全评估类功能  
7. 提交审核  
8. 若中国大陆显示缺少 ICP → 用上文模板 Contact Us 申请豁免  
9. 豁免通过后等待状态同步，再在国区搜索「测光表」验证  

---

## 5. 待你替换的占位符

- `[填 App Store Connect 里的 Apple ID 数字]`  
- `[填你的 Team ID]`（会员中心或 Xcode 签名里可见）  
- 支持网址 / 隐私政策网址（Pages 发布后的真实 URL）  
- 法定姓名（ICP 模板用）  
- 联系邮箱已定为 `watstudio@icloud.com`（见 `docs/`）  

