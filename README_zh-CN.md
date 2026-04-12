<div align="center">

<table>
  <tr>
    <td align="center" width="33%">
      <img src="https://github.com/user-attachments/assets/a093ed6e-a166-4c0e-accf-852dc034dd4a" alt="浅色模式" />
      <br />
      <sub>☀️ <strong>浅色模式</strong> &nbsp;—&nbsp; <code>latex.css</code></sub>
    </td>
    <td align="center" width="33%">
      <img src="https://github.com/user-attachments/assets/677f5f36-a9cc-4867-9fee-1d7f6ff4ca28" alt="深色模式" />
      <br />
      <sub>🌙 <strong>深色模式</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>
    </td>
    <td align="center" width="33%">
      <img src="https://github.com/user-attachments/assets/9a19c61b-fe83-4be8-95bc-6491db57ab73" alt="开发者深色模式" />
      <br />
      <sub>💻 <strong>开发者深色模式</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code></sub>
    </td>
  </tr>
</table>

</div>



# ✍️ LaTeX Typora 主题

> 英文说明请见：[English README](./README.md)

一组受经典 LaTeX 文档启发的 Typora 主题，并提供更偏向代码阅读与编写的深色开发者变体。

- `latex.css` 用于浅色模式
- `latex-dark.css` 用于深色模式
- `latex-dev-dark.css` 用于面向开发者的深色模式
- 内置 New Computer Modern、Latin Modern、JuliaMono、iA Writer Mono 与 Noto Nastaliq Urdu 字体资源，支持离线使用

## 特性

- 正文默认使用 New Computer Modern（对现代希腊语与 Polytonic/古希腊字符覆盖更完整），代码与界面细节保留 Latin Modern 风格
- `latex` / `latex-dark` 保留经典 LaTeX 式间距与两端对齐正文，`latex-dev-dark` 则采用更利于扫读的左对齐开发者布局
- 在 `latex` / `latex-dark` 中，可通过在块级或行内内容上添加 `lang="ur"` / `lang="fa"` 来启用乌尔都语与波斯语的 Nastaliq 排版
- 更适合开发文档的内联代码、带独立语言标签的代码块、表格、图表、链接、截图与快捷键样式
- 与 Typora 侧边栏、源码模式以及打印/导出效果保持一致
- 修复 macOS 下侧边栏与交通灯按钮区域重叠的问题

## 主题选择建议

- `latex` / `latex-dark`：更适合论文、文章与长篇阅读
- `latex-dev-dark`：更适合深色模式下的 README、设计文档、API 说明、变更日志和代码较多的 Markdown，代码使用 JuliaMono，并将代码块语言标签独立显示在下方

演示文件：

- 通用演示：`docs/demo.md`
- 开发者深色演示：`docs/dev-demo.md`

## 语言支持

在 `latex` 或 `latex-dark` 中，正文衬线字体默认使用 New Computer Modern，能够较好支持现代希腊语与 Polytonic/古希腊排版（含学术场景常见字符）。

希腊语内容可直接输入；如需更好的工具链与导出语义，建议添加语言标签：

```html
<p lang="el">Η τυπογραφία του κειμένου διατηρεί καθαρό ρυθμό και σαφήνεια.</p>
<p lang="grc">Ἐν ἀρχῇ ἦν ὁ λόγος, καὶ ὁ λόγος ἦν πρὸς τὸν θεόν.</p>
```

输入阿拉伯文字时仍会优先回退到内置的 Noto Nastaliq Urdu。若还需要 RTL 布局、对齐方式与更高的 Nastaliq 行高，再为块级或行内内容添加 `lang="ur"` 或 `lang="fa"`：

```html
<p lang="ur">یہ پیراگراف نستعلیق میں دکھایا جائے گا۔</p>
<p>English text with <span lang="fa">این بخش فارسی</span> 行内显示。</p>
```

## 安装

在 macOS、Linux 或 Windows（Git Bash / WSL）上统一使用一个命令。安装脚本会自动检测系统、显示清晰的分步日志，并自动完成安装：

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

Typora 默认主题目录：

- macOS：`~/Library/Application Support/abnerworks.Typora/themes`（或沙盒路径）
- Linux：`~/.config/Typora/themes`
- Windows：`%APPDATA%\Typora\themes`

可选参数：

- `--theme-dir "/path/to/Typora/themes"`：手动指定安装目录
- `--ref "<branch|tag|commit>"`：从指定 Git 分支/标签/提交安装

示例：

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```


### 手动安装

1. 从 releases 页面下载 zip 文件并解压。
2. 打开 Typora。
3. 进入 Preferences -> Appearance。
4. 点击 Open Theme Folder。
5. 将 `latex.css`、`latex-dark.css`、`latex-dev-dark.css` 和 `latex_fonts` 文件夹复制进去。
6. 重启 Typora，或在 Themes 菜单中切换到 `latex`、`latex-dark` 或 `latex-dev-dark` 以重新加载。

#### 尽情享受 ❤️!

## 说明

- 仓库中的主题代码采用 Apache-2.0 许可证发布。重新分发时请保留 `LICENSE` 和 `NOTICE` 中的署名信息。
- 字体来源说明见 `docs/THIRD_PARTY_NOTICES.md`。
- 由于所需字体资源已随主题一并打包，安装后可离线使用。
- 设计并在 macOS 上测试。未进行完整测试，但应适用于 Windows/Linux。
- 如果你想自定义颜色或间距，可编辑每个主题文件顶部的 `:root` 变量。
