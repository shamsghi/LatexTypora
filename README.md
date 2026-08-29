<div align="center">

<img src="./docs/screenshots/latex-light-promo.png" alt="LaTeX Typora light theme" width="45%" />&nbsp;&nbsp;&nbsp;<img src="./docs/screenshots/latex-dark-promo.png" alt="LaTeX Typora dark theme" width="45%" />

<sub>☀️ <strong>Light</strong> &nbsp;—&nbsp; <code>latex.css</code> &nbsp;&nbsp;|&nbsp;&nbsp; 🌙 <strong>Dark</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>

<img src="./docs/screenshots/attention-promo.png" alt="Attention Is All You Need rendered with the light LaTeX Typora theme" width="53%" />

<br />
<sub>📄 <strong>Attention Is All You Need</strong> rendered with the light theme</sub>
<br />
<sub>The screenshots above were captured in Typora at <strong>150% zoom</strong>.</sub>

</div>

# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

Typora themes inspired by classic LaTeX documents — clean academic typography for essays, papers, and long-form reading. Includes a developer-focused dark variant built for code-heavy Markdown.

## Automatic Installation

macOS and Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

Windows PowerShell (no Git, Git Bash, or WSL required):

```powershell
irm https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install-windows.ps1 | iex
```

Both installers detect the correct Typora theme folder. If `install.sh` is run from Git Bash, MSYS2, Cygwin, or WSL, it automatically hands the install to the native PowerShell installer.

## Manual Installation

1. Download and unzip the latest release.
2. In Typora, go to **Preferences → Appearance → Open Theme Folder**.
3. Copy `latex.css`, `latex-dark.css`, `latex-dev-dark.css`, and the `latex_fonts/` folder into the themes directory.
4. Restart Typora, then pick a theme from the **Themes** menu.
<details>
<summary>Install options</summary>

| Purpose | macOS / Linux | Windows PowerShell |
| :-- | :-- | :-- |
| Override the target directory | `--theme-dir PATH` | `-ThemeDir PATH` |
| Install a branch, tag, or commit | `--ref REF` | `-Ref REF` |
| Keep stale files | `--no-prune` | `-NoPrune` |
| Disable animations | `--no-anim` | `-NoAnim` |
| Disable colors and animations | `--plain` | `-Plain` |

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install-windows.ps1'))) -ThemeDir 'C:\path\to\Typora\themes'
```

Default theme folders:

| Platform | Path |
| :-- | :-- |
| macOS | `~/Library/Application Support/abnerworks.Typora/themes` (or sandboxed equivalent) |
| Linux | `~/.config/Typora/themes` |
| Windows | `%APPDATA%\Typora\themes` |

</details>

## Features

- **New Computer Modern:** Serif, Sans, and Mono faces give prose, interface labels, and code one consistent LaTeX type family.
- **LaTeX page layout:** A 32em text column, paragraph indents, heading scale, and section spacing follow the 11pt `article` class on letter paper.
- **Automatic section numbers:** `##`, `###`, and `####` render as `1`, `1.1`, and `1.1.1`, while `#` remains the unnumbered document title.
- **`\tableofcontents` contents:** `[toc]` prints under a `Contents` heading — or `\contentsname` in the tagged language, from `目录` to `Inhaltsverzeichnis` to `فہرست` — with the section number on every entry, starting at `##` — the `#` title stays out of its own contents, as in LaTeX. Entries are body-black and unruled, the way `hyperref`'s `hidelinks` sets them.
- **LaTeX details throughout:** Lists, quotations, `booktabs` tables, and footnotes use LaTeX-style marks, rules, and spacing.
- **Abstract environment:** A blockquote directly under the `#` title renders as LaTeX's `abstract` — centred heading, `\small` quotation, both margins pulled in. `class="abstract"` does the same anywhere in the document.
- **CJK and Nastaliq support:** Cross-platform CJK font stacks cover Chinese, Japanese, and Korean. Noto Nastaliq handles Urdu and Persian through HTML `lang` attributes.
- **Works offline:** The theme bundles its Latin and Nastaliq fonts and uses CJK fonts supplied by macOS, Windows, or Linux. It makes no CDN or font requests.
- **Fonts survive HTML export:** Embedded WOFF2 subsets keep New Computer Modern in exported HTML, even on a computer without the theme installed.

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
- Left-aligned layout on a ~76-character monospace measure — no first-line indent, no section numbers, no `[toc]` title, and a quote under the title stays a quote rather than becoming an abstract
- **Persistent language label** above every fenced block, in reading mode and in exports, not only while the fence has focus
- **Diff review styling** — `+` and `-` lines in a `diff` fence tint the whole row and carry a gutter mark
- **Documentation tables** — left-aligned headers, striped rows, and cells that wrap long paths and URLs
- **Visible scrollbars** on fences, wide tables and diagrams

Fences use iA Writer Mono, which carries no ligature lookups. Point
`--monospace` at the `"JuliaMono"` stack defined just above it in the file if
you want `->`, `=>` and `<->` to ligate into arrows — the contextual-alternates
rule is already in place. Neither bundled face ligates `!=`, `==` or `::`.

Reference demo: [`docs/dev-demo.md`](./docs/dev-demo.md)  
Academic theme demo: [`docs/demo.md`](./docs/demo.md)

---

## Customization

Every shared LaTeX metric is a `:root` variable at the top of `latex.css`, while `latex-dark.css` imports that canonical stylesheet and keeps only its dark palette and dark-only UI rules. You can retune the page without hunting through selectors.

| Variable | Default | What it controls |
| :-- | :-- | :-- |
| `--content-measure` | `32em` | Text measure. `32em` is `article.cls`'s 345pt `\textwidth` and gives ~70 characters per line; raise it for a wider column. |
| `--paragraph-indent` | `1.55em` | `\parindent`. Set to `0em` and raise `--paragraph-spacing` for spaced rather than indented paragraphs. |
| `--paragraph-spacing` | `0em` | `\parskip`. |
| `--body-line-height` | `1.38` | Leading. LaTeX's own `\baselineskip` ratio at 11pt is `1.236`. |
| `--cjk-paragraph-indent` | `2em` | First-line indent for `zh`/`ja`/`ko` paragraphs — two full-width characters, per CJK convention. |
| `--section-number-h2/h3/h4` | `counter(...)` | Heading numbers. Set all three to `""` to switch numbering off. |
| `--equation-number` | `""` | Display-equation numbers. `$$…$$` is LaTeX's unnumbered `\[ \]`, so this is off by default; set it to `"(" counter(latex-equation) ")"` to number equations flush right like `equation`. |
| `--toc-title` | `"Contents"` | Title printed above `[toc]`, like `\contentsname`, for a document with no language tagged. Set to `""` to drop it. |
| `--toc-title-zh/ja/ko/de/fr/es/ar/ur/fa` | `"目录"`, `"目次"`, `"목차"`, `"Inhaltsverzeichnis"`, `"Table des matières"`, `"Índice"`, `"الفهرس"`, `"فہرست"`, `"فهرست مطالب"` | The same title where the document is tagged in one of these languages — `\contentsname` as `babel`, `ctex` and `polyglossia` set it. The three right-to-left titles are set in the script's own hand: Naskh for Arabic, Nastaliq for Urdu and Persian. Set them all to one string to print that title regardless of language. |
| `--toc-number-h2/h3/h4` | `counter(...)` | Entry numbers inside `[toc]`, matching the heading numbers. Set all three to `""` to list the headings unnumbered. |
| `--abstract-title` | `"Abstract"` | `\abstractname`, centred above the abstract. Set to `""` to drop the heading. |
| `--abstract-indent`, `--abstract-font-size`, `--abstract-paragraph-indent` | `2.5em`, `0.91em`, `1.5em` | The `abstract` environment: `quotation` margins, `\small`, and the `\listparindent` every paragraph in it carries — the first one included. |
| `--quote-indent`, `--quote-rule-width`, `--quote-padding`, `--quote-tint` | `2.5em`, `0px`, `0em`, `transparent` | Blockquotes render as LaTeX's bare `quote` environment. For the framed panel look, set the rule width to `2px`, the padding to `0.9em 1.2em 0.9em 1.4em` and the tint to `var(--quote-bg-color)`. |
| `--inline-code-bg-color` | faint tint | Inline `code` has no border, matching `\texttt`. Set to `transparent` to remove the tint too. |
| `--table-bleed` | `var(--page-padding-x)` | How far a table too wide for the measure may extend into the page margin before the figure scrolls. Set to `0em` to keep every table inside the measure. |
| `--list-indent`, `--list-topsep`, `--list-itemsep` | `2.5em`, `0.7em`, `0.32em` | `\leftmargini`, `\topsep` and `\itemsep`. |

`latex-dev-dark.css` overrides these, there is no indentation, no section numbers, no `[toc]` title, a 46em monospace measure (~76 characters), left-aligned text, framed blockquotes, and full-width tables that may bleed into the page margin. It adds a few variables of its own:

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
- LaTeX metrics live in `latex.css`; each dark variant imports its parent and adds only the tokens and rules that differ — see [Customization](#customization).
- The `@font-face` rules live in `latex_fonts/embedded-fonts.css` and `latex_fonts/embedded-fonts-dev.css`, which `latex.css` and `latex-dev-dark.css` import. Both files are generated by [`scripts/build-embedded-fonts.py`](./scripts/build-embedded-fonts.py) and should not be hand-edited; regenerate them after changing which faces a theme declares or replacing a bundled font.
