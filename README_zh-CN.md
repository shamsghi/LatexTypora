<div align="center">

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/a093ed6e-a166-4c0e-accf-852dc034dd4a" alt="浅色模式" />
      <br />
      <sub>☀️ <strong>浅色模式</strong> &nbsp;—&nbsp; <code>latex.css</code></sub>
    </td>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/677f5f36-a9cc-4867-9fee-1d7f6ff4ca28" alt="深色模式" />
      <br />
      <sub>🌙 <strong>深色模式</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>
    </td>
  </tr>
</table>

</div>

# ✍️ LaTeX Typora 主题

> 英文说明请见：[English README](./README.md)

受经典 LaTeX 文档启发的 Typora 主题 —— 为论文、文章与长篇阅读打造的学术排版风格。附带一个面向代码密集型 Markdown 的开发者深色变体。

## 特性

- **New Computer Modern** 衬线正文字体，完整支持现代希腊语与 Polytonic 古希腊字符
- **经典 LaTeX** 两端对齐排版、行距与编号公式，适用于 `latex` / `latex-dark`
- 通过 `lang="el"`、`lang="grc"`、`lang="ur"` / `lang="fa"` 属性支持**希腊语/古希腊语、乌尔都语与波斯语**的增强排版
- 侧边栏、源码模式与打印/导出样式保持统一
- 所有字体本地打包，无需 CDN，完全支持离线使用
- 修复 macOS 下侧边栏与交通灯按钮区域重叠的问题

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

自动检测当前平台并安装到正确的 Typora 主题目录，支持 macOS、Linux 与 Windows（Git Bash / WSL）。

<details>
<summary>手动安装</summary>

1. 从 releases 页面下载并解压最新版本。
2. 在 Typora 中，前往 **Preferences → Appearance → Open Theme Folder**。
3. 将 `latex.css`、`latex-dark.css`、`latex-dev-dark.css` 以及 `latex_fonts/` 文件夹复制到主题目录中。
4. 重启 Typora，然后从 **Themes** 菜单选择对应主题。

</details>

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

专为 README、API 文档、设计说明与变更日志打造，在 `latex-dark` 基础上扩展了以下特性：

- **JuliaMono** 用于代码块，**iA Writer Mono** 用于行内代码与界面细节
- 左对齐布局，更适合纵向快速浏览
- 代码块语言标签独立显示在块上方
- 对 `kbd` 快捷键、diff、callout 与宽表格提供更强的视觉表现

参考演示文件：[`docs/dev-demo.md`](./docs/dev-demo.md)  
学术主题演示：[`docs/demo.md`](./docs/demo.md)

---

## 说明

- 采用 **Apache-2.0** 许可证发布，重新分发时请保留 `LICENSE` 与 `NOTICE` 中的署名信息。
- 字体许可证详见 [`docs/THIRD_PARTY_NOTICES.md`](./docs/THIRD_PARTY_NOTICES.md)。
- 在 macOS 上设计与测试，Windows 与 Linux 上应同样可用。
- 如需自定义颜色或间距，可编辑各主题文件顶部的 `:root` 变量。