# ✍️ LaTeX Typora 主题

一个受经典 LaTeX 文档启发的 Typora 明暗双主题。

- `latex.css` 用于浅色模式
- `latex-dark.css` 用于深色模式
- 内置 Computer Modern Web 字体，支持离线使用

## 特性

- 为正文、代码和界面细节提供 Computer Modern 字体风格
- 干净的 LaTeX 式间距、居中标题与两端对齐段落
- 以极简单色风格呈现表格、引用块、链接、脚注与数学公式
- 与 Typora 侧边栏、源码模式以及打印/导出效果保持一致
- 修复 macOS 下侧边栏与交通灯按钮区域重叠的问题

## 安装

### macOS

在 Mac 上运行以下命令，可将当前主题直接安装到 Typora 的主题目录：

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-macos.sh | bash
```

安装脚本会自动检测 macOS 上常见的 Typora 主题目录，并将 `latex.css`、`latex-dark.css` 和 `latex_fonts/` 复制到该目录中。

如果你的 Typora 使用的是自定义主题目录，可以显式传入路径：

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-macos.sh | bash -s -- --theme-dir "$HOME/Library/Application Support/abnerworks.Typora/themes"
```

### Windows/Linux

1. 从 releases 页面下载 zip 文件并解压。
2. 打开 Typora。
3. 进入 Preferences -> Appearance。
4. 点击 Open Theme Folder。
5. 将 `latex.css`、`latex-dark.css` 和 `latex_fonts` 文件夹复制进去。
6. 重启 Typora，或在 Themes 菜单中切换一次主题以刷新加载。

#### 尽情享受 ❤️

## 说明

- 仓库中的主题代码采用 Apache-2.0 许可证发布。重新分发时请保留 `LICENSE` 和 `NOTICE` 中的署名信息。
- 字体来源说明见 `THIRD_PARTY_NOTICES.md`。
- 由于 Computer Modern 字体已随主题一并打包，安装后可离线使用。
- 主要在 macOS 上设计和测试；Windows/Linux 未完全测试，但理论上应可正常使用。
- 如果你想自定义颜色或间距，可编辑每个主题文件顶部的 `:root` 变量。
