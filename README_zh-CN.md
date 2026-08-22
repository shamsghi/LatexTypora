<div align="center">

<img src="./docs/screenshots/latex-light-promo.png" alt="LaTeX Typora 浅色主题" width="45%" />&nbsp;&nbsp;&nbsp;<img src="./docs/screenshots/latex-dark-promo.png" alt="LaTeX Typora 深色主题" width="45%" />

<sub>☀️ <strong>浅色模式</strong> &nbsp;—&nbsp; <code>latex.css</code> &nbsp;&nbsp;|&nbsp;&nbsp; 🌙 <strong>深色模式</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>

<img src="./docs/screenshots/attention-promo.png" alt="使用 LaTeX Typora 浅色主题渲染的《Attention Is All You Need》" width="53%" />

<br />
<sub>📄 使用浅色主题渲染的 <strong>《Attention Is All You Need》</strong></sub>
<br />
<sub>以上截图均在 Typora 中以 <strong>150% 缩放比例</strong>拍摄。</sub>

</div>

# ✍️ LaTeX Typora 主题

> 英文说明请见：[English README](./README.md)

受经典 LaTeX 文档启发的 Typora 主题 —— 为论文、文章与长篇阅读打造的学术排版风格。附带一个面向代码密集型 Markdown 的开发者深色变体。

## 特性

- **New Computer Modern 字体** —— 学术级衬线字体，支持更广泛的字符集
- **`article` 类页面几何** —— 行长、`\parindent`、`\parskip`、标题字号与章节间距均取自 letterpaper 11pt 的 `article.cls`
- **章节自动编号** —— `##`/`###`/`####` 依次编号为 `1`、`1.1`、`1.1.1`，编号与标题之间以 `\quad` 分隔，与 `\section` 一致
- **LaTeX 环境还原** —— 首行缩进、`quote` 式引用块、`itemize`/`enumerate` 标号（`•` `–` `∗`，`1.` `(a)` `i.`）、表格 `booktabs` 横线，以及 `\footnoterule` 下的 `\footnotesize` 脚注
- **`abstract` 环境** —— 紧接 `#` 标题的引用块会渲染为 LaTeX 的 `abstract`：居中标题、`\small` 字号、左右各内缩一段；文档任意位置的 `class="abstract"` 同样有效
- **Noto Nastaliq** —— 通过 HTML `lang` 属性增强乌尔都语与波斯语的正确字形渲染
- **跨平台 CJK 字体支持** ——
  - macOS 使用 Songti SC / Heiti SC 与 STSong / PingFang SC
  - Windows 使用 SimSun / NSimSun / Microsoft YaHei / SimHei
  - Linux 使用 Source Han / Noto CJK 字体
- **离线可用且自包含** —— 所有字体均在本地打包，无需外部依赖或 CDN；CJK 字体则使用当前操作系统自带的字体
- **导出仍保留字体** —— Typora 导出 HTML 时会删除主题的 `@font-face` 规则，导出文件通常只能回退到阅读者系统自带的字体。本主题的每个字形都在样式表内嵌入了自身的 WOFF2 子集，因此导出的 HTML 在从未安装过主题的机器上依然是 New Computer Modern

## 自动安装

macOS 与 Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

Windows PowerShell（无需 Git、Git Bash 或 WSL）：

```powershell
irm https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install-windows.ps1 | iex
```

两个安装器都会自动找到正确的 Typora 主题目录。如果从 Git Bash、MSYS2、Cygwin 或 WSL 运行 `install.sh`，它会自动将安装交给原生 PowerShell 安装器。

## 手动安装

1. 从 releases 页面下载并解压最新版本。
2. 在 Typora 中，前往 **Preferences → Appearance → Open Theme Folder**。
3. 将 `latex.css`、`latex-dark.css`、`latex-dev-dark.css` 以及 `latex_fonts/` 文件夹复制到主题目录中。
4. 重启 Typora，然后从 **Themes** 菜单选择对应主题。

<details>
<summary>安装选项</summary>

| 用途 | macOS / Linux | Windows PowerShell |
| :-- | :-- | :-- |
| 手动指定主题目录 | `--theme-dir PATH` | `-ThemeDir PATH` |
| 从指定分支、标签或提交安装 | `--ref REF` | `-Ref REF` |
| 保留旧版本文件 | `--no-prune` | `-NoPrune` |
| 禁用动画 | `--no-anim` | `-NoAnim` |
| 禁用颜色与动画 | `--plain` | `-Plain` |

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install-windows.ps1'))) -ThemeDir 'C:\path\to\Typora\themes'
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
  <img width="78%" src="./docs/screenshots/latex-dev-promo.png" alt="开发者深色模式" />
  <br />
  <sub>💻 <strong>开发者深色模式</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code> &nbsp;·&nbsp; 以 <strong>125% 缩放比例</strong>拍摄</sub>
</div>

<br />

面向 README、API 文档、设计规范与变更日志打造。在 `latex-dark` 基础上扩展：

- **JuliaMono** 用于正文，**iA Writer Mono** 用于行内代码与界面强调
- 左对齐布局，版心约 76 个等宽字符——取消首行缩进、章节编号、`[toc]` 标题，标题下的引用块也仍是普通引用块而非摘要
- **常驻语言标签**：每个围栏代码块上方都显示语言，阅读模式与导出同样保留，而不仅在获得焦点时出现
- **diff 审阅样式**：`diff` 围栏中的 `+`／`-` 行整行着色并带有左侧标记
- **文档型表格**：表头左对齐、隔行底色，单元格会换行显示长路径与 URL
- **可见滚动条**：用于围栏代码、宽表格与图表

围栏代码使用的 iA Writer Mono 不含任何连字查找表。若希望 `->`、`=>`、`<->`
连写成箭头，只需把 `--monospace` 指向文件中紧邻上方的 `"JuliaMono"` 字体
栈——相关的 contextual-alternates 规则已经就位。两款内置字体都不会把 `!=`、
`==`、`::` 连写。

参考演示文件：[`docs/dev-demo.md`](./docs/dev-demo.md)  
学术主题演示：[`docs/demo.md`](./docs/demo.md)

---

## 自定义

主题共用的 LaTeX 度量都集中在 `latex.css` 顶部的 `:root` 变量中；`latex-dark.css` 会导入这份规范样式表，并只保留深色配色与少量深色专用 UI 规则。无需翻找选择器即可调整版面。

| 变量 | 默认值 | 作用 |
| :-- | :-- | :-- |
| `--content-measure` | `32em` | 正文行长。`32em` 即 `article.cls` 的 345pt `\textwidth`，约每行 70 字符；需要更宽的版心可调大。 |
| `--paragraph-indent` | `1.55em` | `\parindent`。若偏好段间留白而非首行缩进，可设为 `0em` 并调大 `--paragraph-spacing`。 |
| `--paragraph-spacing` | `0em` | `\parskip`。 |
| `--body-line-height` | `1.38` | 行距。LaTeX 在 11pt 下的 `\baselineskip` 比例为 `1.236`。 |
| `--cjk-paragraph-indent` | `2em` | `zh`/`ja`/`ko` 段落的首行缩进，按中文排版惯例为两个全角字符。 |
| `--section-number-h2/h3/h4` | `counter(...)` | 标题编号。三者均设为 `""` 即可关闭编号。 |
| `--equation-number` | `""` | 行间公式编号。`$$…$$` 对应 LaTeX 不编号的 `\[ \]`，故默认关闭；设为 `"(" counter(latex-equation) ")"` 可像 `equation` 那样右对齐编号。 |
| `--toc-title` | `"Contents"` | `[toc]` 上方的标题，对应 `\tableofcontents`。设为 `""` 即可去掉。 |
| `--abstract-title` | `"Abstract"` | 摘要上方居中的 `\abstractname`。设为 `""` 即可去掉该标题。 |
| `--abstract-indent`、`--abstract-font-size`、`--abstract-paragraph-indent` | `2.5em`、`0.91em`、`1.5em` | `abstract` 环境：`quotation` 的左右边距、`\small` 字号，以及其中每个段落（含首段）的 `\listparindent`。 |
| `--quote-indent`、`--quote-rule-width`、`--quote-padding`、`--quote-tint` | `2.5em`、`0px`、`0em`、`transparent` | 引用块按 LaTeX 的 `quote` 环境渲染。若想恢复带边框的面板样式，可将线宽设为 `2px`、内边距设为 `0.9em 1.2em 0.9em 1.4em`、底色设为 `var(--quote-bg-color)`。 |
| `--inline-code-bg-color` | 极浅底色 | 行内 `code` 不再描边，与 `\texttt` 一致。设为 `transparent` 可连底色一并去掉。 |
| `--table-bleed` | `var(--page-padding-x)` | 表格宽于版心时，可向页边距外延伸的距离；超出后由 figure 横向滚动。设为 `0em` 可让所有表格严格保持在版心内。 |
| `--list-indent`、`--list-topsep`、`--list-itemsep` | `2.5em`、`0.7em`、`0.32em` | 对应 `\leftmargini`、`\topsep` 与 `\itemsep`。 |

`latex-dev-dark.css` 会覆盖上述变量：取消首行缩进、取消章节编号、取消 `[toc]` 标题，版心为 46em 等宽（约 76 字符）、左对齐正文、带边框的引用块，以及可延伸到页边距的满宽表格。它还新增了几个变量：

| 变量 | 默认值 | 作用 |
| :-- | :-- | :-- |
| `--diff-add-bg-color`、`--diff-remove-bg-color` | 淡绿／淡红 | `diff` 围栏中 `+`／`-` 行的整行底色。 |
| `--table-stripe-color` | 极淡白色 | 表格偶数行的隔行底色，设为 `transparent` 可关闭。 |
| `--scrollbar-thumb-color`、`--scrollbar-thumb-hover-color` | 半透明白色 | 围栏代码、宽表格与图表的滚动条颜色。 |
| `--nastaliq-line-height` | `1.95` | 乌尔都语／波斯语行距，较基础主题的 `2.15` 更紧凑。 |

## 说明

- 采用 **Apache-2.0** 许可证发布，重新分发主题时请保留 `LICENSE`。
- 内置字体的署名与许可证说明见 [`docs/THIRD_PARTY_NOTICES.md`](./docs/THIRD_PARTY_NOTICES.md)；重新分发打包字体时请保留其中相关说明。
- 在 macOS 上设计与测试，Windows 与 Linux 上应同样可用。
- LaTeX 度量集中在 `latex.css`；两个深色变体会逐层导入父主题，仅新增各自差异化的变量与规则，详见[自定义](#自定义)。
- `@font-face` 规则位于 `latex_fonts/embedded-fonts.css` 与 `latex_fonts/embedded-fonts-dev.css`，由 `latex.css` 和 `latex-dev-dark.css` 导入。这两个文件由 [`scripts/build-embedded-fonts.py`](./scripts/build-embedded-fonts.py) 生成，请勿手工编辑；更换内置字体或改动主题声明的字形后重新生成即可。
