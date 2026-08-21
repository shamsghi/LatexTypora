<div align="center">

<img src="./docs/screenshots/latex-light-promo.png" alt="LaTeX Typora light theme" width="43%" /> <img src="./docs/screenshots/latex-dark-promo.png" alt="LaTeX Typora dark theme" width="43%" />

<sub>☀️ <strong>Light</strong> &nbsp;—&nbsp; <code>latex.css</code> &nbsp;&nbsp;|&nbsp;&nbsp; 🌙 <strong>Dark</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>

<br>
<img src="./docs/screenshots/attention-promo.png" alt="Attention Is All You Need rendered with the light LaTeX Typora theme" width="52%" />

<br />
<sub>📄 <strong>Attention Is All You Need</strong> rendered with the light theme</sub>
<br />
<sub>All screenshots were captured in Typora at <strong>150% zoom</strong>.</sub>

</div>

# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

Typora themes inspired by classic LaTeX documents — clean academic typography for essays, papers, and long-form reading. Includes a developer-focused dark variant built for code-heavy Markdown.

## Features

- **New Computer Modern typeface** — Academic-quality serif with support for a wider amount of characters
- **`article` class geometry** — Line measure, `\parindent`, `\parskip`, heading sizes and section skips taken from `article.cls` at 11pt on letterpaper
- **Numbered sections** — `##`/`###`/`####` are numbered `1`, `1.1`, `1.1.1` and separated from the title by a `\quad`, exactly like `\section`
- **LaTeX environments** — First-line paragraph indentation, `quote`-style blockquotes, `itemize`/`enumerate` label glyphs (`•` `–` `∗`, `1.` `(a)` `i.`), `booktabs` rules on tables, and `\footnotesize` footnotes under a `\footnoterule`
- **Noto Nastaliq** — Enhanced support for Urdu, and Farsi with proper script rendering using html lang attributes
- **Cross-platform CJK font support** —
  - Uses Songti SC / Heiti SC and STSong / PingFang SC on macOS
  - SimSun / NSimSun / Microsoft YaHei / SimHei on Windows
  - Source Han / Noto CJK fonts on Linux
- **Offline & self-contained** — All fonts bundled locally, no external dependencies or CDN required. CJK fonts are bundled by your current OS natively

## Automatic Installation

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

Detects your platform automatically and installs to the correct Typora theme folder. Works on macOS, Linux, and Windows (Git Bash / WSL).

## Manual Installation

1. Download and unzip the latest release.
2. In Typora, go to **Preferences → Appearance → Open Theme Folder**.
3. Copy `latex.css`, `latex-dark.css`, `latex-dev-dark.css`, and the `latex_fonts/` folder into the themes directory.
4. Restart Typora, then pick a theme from the **Themes** menu.
<details>
<summary>Install options</summary>

| Flag | Description |
| :-- | :-- |
| `--theme-dir PATH` | Override the target Typora theme directory |
| `--ref REF` | Install from a specific branch, tag, or commit |

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```
Default theme folders:

| Platform | Path |
| :-- | :-- |
| macOS | `~/Library/Application Support/abnerworks.Typora/themes` (or sandboxed equivalent) |
| Linux | `~/.config/Typora/themes` |
| Windows | `%APPDATA%\Typora\themes` |

</details>

#### Enjoy ❤️!

---

## `latex-dev-dark` — Developer Variant

<div align="center">
  <img width="78%" src="./docs/screenshots/latex-dev-promo.png" alt="Developer Dark Mode" />
  <br />
  <sub>💻 <strong>Developer Dark Mode</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code> &nbsp;·&nbsp; captured at <strong>125% zoom</strong></sub>
</div>

<br />

Built for READMEs, API docs, design specs, and changelogs. Extends `latex-dark` with:

- **JuliaMono** for body text, **iA Writer Mono** for inline code and UI accents
- Left-aligned layout on a ~76-character monospace measure — no first-line indent, no section numbers, no `[toc]` title
- **Persistent language label** above every fenced block, in reading mode and in exports, not only while the fence has focus
- **Diff review styling** — `+` and `-` lines in a `diff` fence tint the whole row and carry a gutter mark
- **Documentation tables** — left-aligned headers, striped rows, and cells that wrap long paths and URLs instead of forcing a scroll
- **Visible scrollbars** on fences, wide tables and diagrams, so overflow reads as scrollable rather than truncated
- **Light PDF export** — printing flips to ink-on-paper with syntax highlighting kept, while the screen stays dark
- Framed callouts and blockquotes, and `kbd` shortcuts carried over from `latex-dark`

Fences use iA Writer Mono, which carries no ligature lookups. Point
`--monospace` at the `"JuliaMono"` stack defined just above it in the file if
you want `->`, `=>` and `<->` to ligate into arrows — the contextual-alternates
rule is already in place. Neither bundled face ligates `!=`, `==` or `::`.

Reference demo: [`docs/dev-demo.md`](./docs/dev-demo.md)  
Academic theme demo: [`docs/demo.md`](./docs/demo.md)

---

## Customization

Every LaTeX metric the themes depend on is a `:root` variable at the top of `latex.css` and `latex-dark.css`, so you can retune the page without hunting through selectors.

| Variable | Default | What it controls |
| :-- | :-- | :-- |
| `--content-measure` | `32em` | Text measure. `32em` is `article.cls`'s 345pt `\textwidth` and gives ~70 characters per line; raise it for a wider column. |
| `--paragraph-indent` | `1.55em` | `\parindent`. Set to `0em` and raise `--paragraph-spacing` for spaced rather than indented paragraphs. |
| `--paragraph-spacing` | `0em` | `\parskip`. |
| `--body-line-height` | `1.38` | Leading. LaTeX's own `\baselineskip` ratio at 11pt is `1.236`. |
| `--cjk-paragraph-indent` | `2em` | First-line indent for `zh`/`ja`/`ko` paragraphs — two full-width characters, per CJK convention. |
| `--section-number-h2/h3/h4` | `counter(...)` | Heading numbers. Set all three to `""` to switch numbering off. |
| `--equation-number` | `""` | Display-equation numbers. `$$…$$` is LaTeX's unnumbered `\[ \]`, so this is off by default; set it to `"(" counter(latex-equation) ")"` to number equations flush right like `equation`. |
| `--toc-title` | `"Contents"` | Title printed above `[toc]`, like `\tableofcontents`. Set to `""` to drop it. |
| `--quote-indent`, `--quote-rule-width`, `--quote-padding`, `--quote-tint` | `2.5em`, `0px`, `0em`, `transparent` | Blockquotes render as LaTeX's bare `quote` environment. For the framed panel look, set the rule width to `2px`, the padding to `0.9em 1.2em 0.9em 1.4em` and the tint to `var(--quote-bg-color)`. |
| `--inline-code-bg-color` | faint tint | Inline `code` has no border, matching `\texttt`. Set to `transparent` to remove the tint too. |
| `--table-bleed` | `var(--page-padding-x)` | How far a table too wide for the measure may extend into the page margin before the figure scrolls. Set to `0em` to keep every table inside the measure. |
| `--list-indent`, `--list-topsep`, `--list-itemsep` | `2.5em`, `0.7em`, `0.32em` | `\leftmargini`, `\topsep` and `\itemsep`. |

`latex-dev-dark.css` overrides these for developer documentation: no indentation, no section numbers, no `[toc]` title, a 46em monospace measure (~76 characters), left-aligned text, framed blockquotes, and full-width tables that may bleed into the page margin. It adds a few variables of its own:

| Variable | Default | What it controls |
| :-- | :-- | :-- |
| `--diff-add-bg-color`, `--diff-remove-bg-color` | faint green / red | Row tint behind `+` and `-` lines in a `diff` fence. |
| `--table-stripe-color` | faint white | Zebra stripe on even table rows. Set to `transparent` to drop striping. |
| `--scrollbar-thumb-color`, `--scrollbar-thumb-hover-color` | translucent white | Scrollbars on fences, wide tables and diagrams. |
| `--nastaliq-line-height` | `1.95` | Urdu/Farsi leading, tightened from the base theme's `2.15`. |

## Notes

- Licensed under **Apache-2.0**. Keep `LICENSE` when redistributing the theme.
- Bundled font attribution and license details are in [`docs/THIRD_PARTY_NOTICES.md`](./docs/THIRD_PARTY_NOTICES.md); keep the relevant notices when redistributing bundled assets.
- Designed and tested on macOS; should work on Windows and Linux.
- Colors, fonts and every LaTeX metric are `:root` variables at the top of each theme file — see [Customization](#customization).
