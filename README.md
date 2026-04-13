<div align="center">

<img src="https://github.com/user-attachments/assets/a093ed6e-a166-4c0e-accf-852dc034dd4a" alt="Light Mode" width="49%" /> <img src="https://github.com/user-attachments/assets/677f5f36-a9cc-4867-9fee-1d7f6ff4ca28" alt="Dark Mode" width="49%" />

<br />
<sub>☀️ <strong>Light Mode</strong> &nbsp;—&nbsp; <code>latex.css</code> &nbsp;&nbsp;|&nbsp;&nbsp; 🌙 <strong>Dark Mode</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>

</div>

# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

Typora themes inspired by classic LaTeX documents — clean academic typography for essays, papers, and long-form reading. Includes a developer-focused dark variant built for code-heavy Markdown.

## Features

- **New Computer Modern** serif body text with full modern and polytonic Greek coverage
- **Classic LaTeX** justified prose, spacing, and numbered display equations in `latex` / `latex-dark`
- **Greek/Ancient Greek, Urdu and Farsi** Nastaliq and Greek improved support via `lang="el"`, `lang="grc"`,`lang="ur"` / `lang="fa"` attributes
- Consistent sidebar, source mode, and print/export styling
- All fonts bundled locally — no CDN, works fully offline
- macOS traffic lights sidebar offset fix

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
  <img width="85%" src="https://github.com/user-attachments/assets/9a19c61b-fe83-4be8-95bc-6491db57ab73" alt="Developer Dark Mode" />
  <br />
  <sub>💻 <strong>Developer Dark Mode</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code></sub>
</div>

<br />

Built for READMEs, API docs, design specs, and changelogs. Extends `latex-dark` with:

- **JuliaMono** for code blocks, **iA Writer Mono** for inline code and UI accents
- Left-aligned layout optimised for vertical scanning
- Detached language label above fenced code blocks
- Stronger visual weight for `kbd` shortcuts, diffs, callouts, and wide tables

Reference demo: [`docs/dev-demo.md`](./docs/dev-demo.md)  
Academic theme demo: [`docs/demo.md`](./docs/demo.md)

---

## Notes

- Licensed under **Apache-2.0**. Keep `LICENSE` when redistributing the theme.
- Bundled font attribution and license details are in [`docs/THIRD_PARTY_NOTICES.md`](./docs/THIRD_PARTY_NOTICES.md); keep the relevant notices when redistributing bundled assets.
- Designed and tested on macOS; should work on Windows and Linux.
- Customize colors and spacing via `:root` variables at the top of each theme file.
