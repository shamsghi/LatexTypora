<div align="center">

<img src="https://github.com/user-attachments/assets/a093ed6e-a166-4c0e-accf-852dc034dd4a" alt="浅色模式" width="49%" /> <img src="https://github.com/user-attachments/assets/677f5f36-a9cc-4867-9fee-1d7f6ff4ca28" alt="深色模式" width="49%" />

<br />
<sub>☀️ <strong>浅色模式</strong> &nbsp;—&nbsp; <code>latex.css</code> &nbsp;&nbsp;|&nbsp;&nbsp; 🌙 <strong>深色模式</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>

</div>

# ✍️ LaTeX Typora 主题

> 英文说明请见：[English README](./README.md)

受经典 LaTeX 文档启发的 Typora 主题 —— 为论文、文章与长篇阅读打造的学术排版风格。附带一个面向代码密集型 Markdown 的开发者深色变体。

## 特性

- **New Computer Modern 字体** —— 学术级衬线字形，支持现代希腊语与古希腊语
- **经典 LaTeX 排版** —— 两端对齐正文、统一间距与编号公式
- **GitHub 风格 Alerts / Callouts** —— 与 Typora 1.8+ 兼容的主题原生提醒样式
- **Noto Nastaliq** —— 通过 HTML `lang` 属性增强乌尔都语与波斯语的正确字形渲染
- **跨平台 CJK 字体支持** —— macOS 使用 Songti SC / Heiti SC 与 STSong / PingFang SC，Windows 使用 SimSun / NSimSun / Microsoft YaHei / SimHei，Linux 使用 Source Han / Noto CJK 字体
- **离线可用且自包含** —— 所有字体均本地打包，无需外部依赖或 CDN
- **跨平台细节打磨** —— 侧边栏、源码模式与打印/导出样式一致，并包含 macOS 交通灯区域修复

## 自动安装

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

自动检测当前平台并安装到正确的 Typora 主题目录，支持 macOS、Linux 与 Windows（Git Bash / WSL）。

## 手动安装

1. 从 releases 页面下载并解压最新版本。
2. 在 Typora 中，前往 **Preferences → Appearance → Open Theme Folder**。
3. 将 `latex.css`、`latex-dark.css`、`latex-dev-dark.css` 以及 `latex_fonts/` 文件夹复制到主题目录中。
4. 重启 Typora，然后从 **Themes** 菜单选择对应主题。

<details>
<summary>安装选项</summary>

| 参数 | 说明 |
| :-- | :-- |
| `--theme-dir PATH` | 手动指定 Typora 主题目录 |
| `--ref REF` | 从指定分支、标签或提交安装 |

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```

默认主题目录：

| 平台 | 路径 |
| :-- | :-- |
| macOS | `~/Library/Application Support/abnerworks.Typora/themes`（或沙盒等效路径） |
| Linux | `~/.config/Typora/themes` |
| Windows | `%APPDATA%\Typora\themes` |

</details>

#### 尽情享受 ❤️!

---

## `latex-dev-dark` — 开发者变体

<div align="center">
  <img width="85%" src="https://github.com/user-attachments/assets/9a19c61b-fe83-4be8-95bc-6491db57ab73" alt="开发者深色模式" />
  <br />
  <sub>💻 <strong>开发者深色模式</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code></sub>
</div>

<br />

面向 README、API 文档、设计规范与变更日志打造。在 `latex-dark` 基础上扩展：

- **JuliaMono** 用于代码块，**iA Writer Mono** 用于行内代码与界面强调
- 左对齐布局，优化纵向扫描体验
- 围栏代码块上方独立显示语言标签
- 为 `kbd` 快捷键、diff、callout 与宽表格提供更强的视觉权重

参考演示文件：[`docs/dev-demo.md`](./docs/dev-demo.md)  
学术主题演示：[`docs/demo.md`](./docs/demo.md)

---

## 说明

- 采用 **Apache-2.0** 许可证发布，重新分发主题时请保留 `LICENSE`。
- 内置字体的署名与许可证说明见 [`docs/THIRD_PARTY_NOTICES.md`](./docs/THIRD_PARTY_NOTICES.md)；重新分发打包字体时请保留其中相关说明。
- 在 macOS 上设计与测试，Windows 与 Linux 上应同样可用。
- 如需自定义颜色或间距，可编辑各主题文件顶部的 `:root` 变量。
