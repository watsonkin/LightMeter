# App Store 首发清单（含打赏）

按顺序勾选。文案与 Product ID 以本目录草稿 / 规格为准。

---

## A. 协议与账号

- [ ] Apple Developer 年费已生效  
- [ ] [App Store Connect](https://appstoreconnect.apple.com) → **协议、税务和银行业务**  
- [ ] 签署 **Paid Applications**（Paid Apps）  
- [ ] 银行账户、税务表格状态为「有效」（否则 tip IAP 无法销售）  
- [ ] 记下 **Team ID**（会员中心或 Xcode Signing）

---

## B. 支持页 / 隐私页（GitHub Pages）

- [x] 仓库已推送：https://github.com/watsonkin/LightMeter  
- [x] 联系邮箱：`watstudio@icloud.com`  
- [x] Pages：`main` + `/docs` 已启用  
- [x] Support：https://watsonkin.github.io/LightMeter/  
- [x] Privacy：https://watsonkin.github.io/LightMeter/privacy.html  
- [ ] 把上述 URL 填进 ASC 元数据  

---

## C. 新建 App（ASC）

- [ ] **我的 App → +** → iOS  
- [ ] Bundle ID：`com.watstudio.LightMeter`（与 Xcode 一致）  
- [ ] SKU：自定（如 `lightmeter`）  
- [ ] 用户访问权限：完整访问（除非你刻意用有限）  
- [ ] 价格：**免费**  
- [ ] 销售范围：含 **中国大陆**（及其他目标店面）  
- [ ] 主类别：摄影与录像  
- [ ] 年龄分级：4+  
- [ ] 记下 ASC 数字 **Apple ID**（App 信息页）

### 元数据（简体中文）

从 [`ASC_China_drafts.md`](ASC_China_drafts.md) 粘贴：

- [ ] 名称、副标题、宣传文本、描述、关键词  
- [ ] 支持网址、隐私政策网址  
- [ ] App 图标（工程内已更新字标 1024）  
- [ ] 截图：真机主界面 + 打赏 Sheet（至少 **6.7"** 与 **6.1"** 各一套）

### 合规与审核

- [ ] App 隐私：声明不收集（或按实际问卷勾选；测光本地、无追踪）  
- [ ] 出口合规 / 加密问卷按实际填写（常见：仅用 HTTPS/标准加密）  
- [ ] 内容版权、广告标识等按向导完成  
- [ ] 声明无 AIGC / 无需安全评估类功能（以 ASC 当时选项为准）  
- [ ] **审核备注**：粘贴草稿 §2（已含 tip 测试步骤与 Product ID）

---

## D. 内购（三档 tip）

对照 [`Tips_Product_Spec.md`](Tips_Product_Spec.md)：

| 档位 | Product ID | 美区价 |
|------|------------|--------|
| tier1 | `com.watstudio.LightMeter.tip.tier1` | $0.99 |
| tier2 | `com.watstudio.LightMeter.tip.tier2` | $2.99 |
| tier3 | `com.watstudio.LightMeter.tip.tier3` | $5.99 |

对每个商品：

- [ ] 类型：**消耗型（Consumable）**  
- [ ] Reference Name / Display Name / Description（EN + 简体中文）按规格  
- [ ] 价格档位对应 $0.99 / $2.99 / $5.99  
- [ ] 状态：**准备提交**，并**关联到本次 App 版本**

App 内已实现：[`../LightMeter/TipStore.swift`](../LightMeter/TipStore.swift)、左上角字标入口。本地可用 Scheme 里的 `Configuration.storekit` 测流程。

---

## E. Build 上传与提审

- [ ] Xcode Signing：Team = 已通过的 Developer 账号  
- [ ] 真机再测一遍：测光 + 打开打赏 Sheet（Sandbox / StoreKit Configuration）  
- [ ] **Product → Archive → Distribute App → App Store Connect**  
- [ ] ASC 版本页选择该 Build  
- [ ] 确认三档 tip 已勾选进本版本  
- [ ] **提交以供审核**

---

## F. 中国区 ICP（若被卡）

- [ ] 若中国大陆缺 ICP / 备案：用 [`ASC_China_drafts.md`](ASC_China_drafts.md) §3 Contact Us 模板  
- [ ] 模板中写明：**仅有 Apple IAP 打赏，无自建收款**  
- [ ] 填入 Apple ID（数字）、Team ID、法定姓名  
- [ ] 按回信补签名声明，等待豁免同步后再在国区搜索「测光表」

---

## 工程侧已就绪（对照）

| 项 | 状态 |
|----|------|
| Bundle ID `com.watstudio.LightMeter` | 工程已设 |
| App Icon 字标 1024 | Assets 已换 |
| Tip Product IDs | 与规格一致 |
| StoreKit 2 + tip UI | 已实现 |
| `docs/` 支持 / 隐私页 | 已写好，待你开 Pages |
| Review Notes + ICP 文案 | 已含 tip / Apple IAP |

---

## 修订

| 日期 | 说明 |
|------|------|
| 2026-11-26 | 首发含 tip；Pages + ASC 可勾选清单 |
