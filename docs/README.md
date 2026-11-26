# LightMeter 支持站（GitHub Pages）

本目录是 App Store 用的**支持页**与**隐私政策**静态站。

| 文件 | 用途 |
|------|------|
| `index.html` | Support URL |
| `privacy.html` | Privacy Policy URL |
| `styles.css` | 共用样式 |

## 发布步骤

1. 把本仓库推到 GitHub（建议公开仓库，或对 Pages 开启访问）。
2. 仓库 **Settings → Pages**：
   - Source：Deploy from a branch
   - Branch：`main`（或你的默认分支）
   - Folder：**`/docs`**
3. 保存后等待 1–2 分钟，打开：
   - Support：`https://<GitHub用户名>.github.io/<仓库名>/`
   - Privacy：`https://<GitHub用户名>.github.io/<仓库名>/privacy.html`
4. 若仓库名是 `LightMeter`、用户名是 `watsonkin`，则为：
   - `https://watsonkin.github.io/LightMeter/`
   - `https://watsonkin.github.io/LightMeter/privacy.html`
5. 把最终 URL 填进 App Store Connect，并回填 `StoreListing/ASC_China_drafts.md`。

## 联系邮箱

- 支持 / 隐私页使用：`watstudio@icloud.com`

## 本地预览

用任意静态服务器打开 `docs/`，例如：

```bash
cd docs && python3 -m http.server 8080
```

浏览器访问 `http://localhost:8080/`。
