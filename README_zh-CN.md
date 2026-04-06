<p align="center">
  <img src="https://github.com/user-attachments/assets/afc4addd-05d3-46bf-8ebf-2a5b738b70e6" alt="light" width="48%" />
  <img src="https://github.com/user-attachments/assets/19cd41a2-cd5c-4776-93ff-231792d32d2f" alt="dark" width="48%" />
</p>


# ✍️ LaTeX Typora 主题

> 英文说明请见：[English README](./README.md)

一组受经典 LaTeX 文档启发的 Typora 主题，并提供更偏向代码阅读与编写的深色开发者变体。

- `latex.css` 用于浅色模式
- `latex-dark.css` 用于深色模式
- `latex-dev-dark.css` 用于面向开发者的深色模式
- 内置 Latin Modern、JuliaMono、iA Writer Mono 与 Noto Nastaliq Urdu 字体资源，支持离线使用

## 特性

- 为正文、代码和界面细节提供 Latin Modern 字体风格
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

如需在 `latex` 或 `latex-dark` 中为乌尔都语或波斯语启用 Nastaliq 排版，可在块级或行内内容上添加 `lang="ur"` 或 `lang="fa"`：

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
