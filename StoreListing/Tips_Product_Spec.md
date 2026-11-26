# 打赏（Tips）产品规范

**产品：** 测光表 / LightMeter  
**版本：** 建议随 1.x 功能迭代上线  
**店面基准价：** 美国区 App Store  
**档位：** $0.99 · $2.99 · $5.99  
**模式：** 自愿打赏，**不解锁任何功能**  
**支付：** 仅 Apple 内购（StoreKit），禁止第三方支付  

本文档供产品、设计、开发、ASC 配置与审核材料共用。

---

## 1. 目标与非目标

### 1.1 目标
- 为喜欢本 App 的用户提供可选的支持开发者渠道。
- 符合 App Store 审核指南 3.1.1（数字内容/支持类收益走 IAP）。
- 保持核心测光能力完全免费，打赏零强迫。

### 1.2 非目标
- 不做订阅。
- 不做「Pro 功能墙」。
- 不做慈善捐赠（无公益机构资质，文案禁用 Donate to charity / 慈善捐款）。
- 不做微信/支付宝/网页打赏入口。

---

## 2. 商业与合规原则

| 原则 | 规范 |
|------|------|
| 商品类型 | **消耗型（Consumable）**，可多次购买 |
| 权益 | **无权益变化**：测光、倍率、设定记忆等全部不因打赏改变 |
| 文案 | 英文用 **Tip / Support the developer**；中文用 **打赏 / 支持开发者** |
| 协议 | ASC 须已签署 Paid Apps，并完成银行与税务 |
| 抽成 | 按 Apple 现行分成（小商业计划达标时多为 15%，否则 30%） |
| 中国区 | 仍可申请 ICP 豁免；IAP 走 Apple，不视为自建收款服务 |
| 隐私 | 不因打赏收集额外个人信息；收据由系统处理 |

---

## 3. 内购商品定义（美区基准）

### 3.1 商品一览

| 档位 | 美区价格 | Product ID（建议） | 参考定位 |
|------|----------|-------------------|----------|
| Tip S | **$0.99** | `com.watstudio.LightMeter.tip.tier1` | 一杯便宜咖啡 |
| Tip M | **$2.99** | `com.watstudio.LightMeter.tip.tier2` | 默认推荐档 |
| Tip L | **$5.99** | `com.watstudio.LightMeter.tip.tier3` | 重度支持 |

> Product ID 一经创建不可改，上线前确认无拼写错误。

### 3.2 App Store Connect 字段（英文主语言）

**类型：** Consumable  

**Reference Name（后台用，用户不可见）：**
- `Tip Tier 1 – 0.99`
- `Tip Tier 2 – 2.99`
- `Tip Tier 3 – 5.99`

**Display Name（用户可见，≤30 字符）：**
| 档位 | EN | 简体中文 |
|------|----|----------|
| tier1 | Tip $0.99 | 打赏 $0.99 |
| tier2 | Tip $2.99 | 打赏 $2.99 |
| tier3 | Tip $5.99 | 打赏 $5.99 |

> 实际按钮上优先显示系统本地化价格（`Product.displayPrice`），Display Name 可写「小打赏 / 支持一下 / 大力支持」避免与价格重复。推荐界面文案见 §5。

**Description：**
```
EN: Optional tip to support LightMeter development. Does not unlock features.
ZH: 自愿打赏，支持测光表的持续开发。不会解锁任何功能。
```

**价格：** 在 ASC 为各商品选择对应价格等级（Price Tier 对应 $0.99 / $2.99 / $5.99）。其他店面由 Apple 自动换算（中国区显示约 ¥3 / ¥8 / ¥18，以 ASC 当时档位为准，勿手写写死人民币）。

**审核截图：** 可选用打赏页截图；非必须每档一张。

### 3.3 能力开关
- App 内购 Capability：Xcode → Signing & Capabilities → In-App Purchase  
- 无需申请额外外部购买权益（External Link / Reader）

---

## 4. 产品行为规范

### 4.1 购买成功后
1. 系统完成扣款与交易完成（StoreKit `finish`）。
2. UI：Toast / 简短致谢（见 §5.3），**2 秒内可自动消失**。
3. **不改变**任何测光逻辑、默认值、广告（无广告）、水印、档位上限。
4. 允许用户立即再次购买任意档位（消耗型）。

### 4.2 购买取消 / 失败
- 用户取消：静默或极短提示「已取消」，不弹错。
- 网络/商店失败：提示「暂时无法完成购买，请稍后重试」，保留打赏页。
- 禁止反复自动弹购买框。

### 4.3 不提供的能力
- 不提供「恢复购买」（消耗型打赏无持久权益）。
- 不提供打赏排行、公开感谢墙、强制账号。
- 不在打赏流程中强求五星好评（可另遵评分规范做温和引导，与打赏解耦）。

### 4.4 入口与露出频率
| 位置 | 要求 |
|------|------|
| **主入口** | 「设置 / 关于」页 → **支持开发者**（必做） |
| **可选次入口** | 关于页底部文字链；勿遮挡测光主路径 |
| **禁止** | 首次启动弹窗逼打赏；测光失败时诱导打赏；不打赏则限次测光 |

推荐信息架构：
```
主界面（测光）
  └─ 关于 / 设置
       └─ 支持开发者  →  打赏页（三档）
```

---

## 5. 文案规范

### 5.1 打赏页（EN / ZH）

**主文案**
- ZH: 感谢支持“测光”APP  
- EN: Thanks for supporting 测光  

**副文案**
- ZH: 您的支持是我不断迭代更新的动力  
- EN: Your support keeps the updates coming  

**界面不展示**「不会解锁任何功能」；产品与审核层面仍为纯打赏、无解锁。  

**档位按钮标签（价格用系统返回值）**
| 档位 | ZH | EN |
|------|----|----|
| tier1 | 感谢 | Thanks |
| tier2 | 拜谢 | Grateful |
| tier3 | 跪谢 | Deeply grateful |

按钮主行显示：`{displayPrice}`（如 `$0.99` / `¥3`）。  
副行显示上表文案（感谢 / 拜谢 / 跪谢）。  
**默认选中 tier2（拜谢）**；**无「推荐」字样**。  
点档位只改选中；点 **「确定」** 后才对选中档发起购买。

**页脚**
- EN: Payment is charged to your Apple ID.  
- ZH: 费用将记入你的 Apple ID 账户。  

### 5.2 设置入口
- EN: Support the developer  
- ZH: 支持开发者  

### 5.3 成功致谢
- EN: Thank you for your support!  
- ZH: 谢谢支持！  

### 5.4 禁用词
- Donate / Donation / Charity / 捐款 / 慈善 / 公益  
- Unlock Pro / Remove limits（除非未来真做 Pro，需另开规范）  
- Buy me coffee 可作为非正式比喻，**商店商品正式名仍建议 Tip / 打赏**

---

## 6. 交互稿要点（实现时对齐）

1. 打赏页为独立 Sheet 或 Push 页，深色风格与主 App 一致。  
2. 三档纵向或横向等宽卡片；tier2 描边/底色略强调。  
3. 点击某档 → 系统购买表 → 成功致谢 → 留在打赏页（可再打赏）或关闭。  
4. 购买进行中按钮 Loading，防重复点击。  
5. 商品加载失败：显示「无法加载打赏选项」+ 重试，不显示假价格。

---

## 7. 工程约定（开发对照）

| 项 | 约定 |
|----|------|
| API | StoreKit 2（`Product.products(for:)` / `purchase()`） |
| Product IDs | 见 §3.1，集中常量，如 `TipProductID` |
| 沙盒 | 用 Sandbox Apple ID 测三档各至少 1 次 |
| 日志 | 仅本地调试日志；不上报用户身份 |
| 功能开关 | 远程开关非必须；下架某档可在 ASC 停售 |

伪流程：
```
打开打赏页 → 请求 [tier1, tier2, tier3]
  → 展示 displayPrice
  → 用户点 tierN → purchase
  → verified transaction → finish → 致谢
```

---

## 8. 审核备注补充（Review Notes 追加段）

```
In-App Purchases:
Three optional consumable tips (US: $0.99 / $2.99 / $5.99):
  com.watstudio.LightMeter.tip.tier1
  com.watstudio.LightMeter.tip.tier2
  com.watstudio.LightMeter.tip.tier3

Tips do not unlock features, remove ads, or change metering behavior.
Core light-meter features remain free. No third-party payments.
```

---

## 9. 验收清单（QA）

- [ ] 未登录 Sandbox 时购买流程可测通  
- [ ] 三档价格与 ASC 一致（美区显示 $0.99 / $2.99 / $5.99）  
- [ ] 购买成功后功能与未购买完全一致  
- [ ] 可连续购买同一档多次  
- [ ] 取消购买无崩溃、无卡死 Loading  
- [ ] 无网时有明确失败提示  
- [ ] 中英文入口与说明无「捐赠/慈善」用词  
- [ ] 主测光路径无强制打赏弹窗  
- [ ] ASC 商品状态为「准备提交」并随 App 版本一起审核  

---

## 10. 上线步骤（ASC）

1. 确认 Paid Apps 协议 + 银行税务生效。  
2. App → 功能 → 内购 → 创建 3 个消耗型商品（§3）。  
3. 各店面价格以美区 $0.99 / $2.99 / $5.99 为基准选档。  
4. 本地化至少：**English (U.S.)** + **简体中文**。  
5. Xcode 打开 In-App Purchase capability，实现 StoreKit。  
6. 新 Build 提审，内购与 App 版本关联。  
7. 审核通过后，打赏随 App 在已选地区上架（含中国区若已可售）。  

---

## 11. 修订记录

| 日期 | 变更 |
|------|------|
| 2026-11-25 | 初版：美区三档消耗型纯打赏规范 |
| 2026-11-26 | 首发含 tip；上架步骤见 `ASC_Launch_Checklist.md`；ICP 文案改为「仅 Apple IAP」 |
