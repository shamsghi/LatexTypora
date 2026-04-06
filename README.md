<p align="center">
  <img src="https://github.com/user-attachments/assets/afc4addd-05d3-46bf-8ebf-2a5b738b70e6" alt="light" width="48%" />
  <img src="https://github.com/user-attachments/assets/19cd41a2-cd5c-4776-93ff-231792d32d2f" alt="dark" width="48%" />
</p>


# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

A family of Typora themes inspired by classic LaTeX documents, including a more code-forward dark variant for developer-heavy Markdown.

- `latex.css` for light mode
- `latex-dark.css` for dark mode
- `latex-dev-dark.css` for developer-focused dark mode
- Bundled Latin Modern, JuliaMono, iA Writer Mono, and Noto Nastaliq Urdu assets for offline use

## Features

- Latin Modern typography for text, code, and UI accents
- Classic LaTeX-style spacing and justified prose in `latex` / `latex-dark`, plus a scan-friendly left-aligned layout in `latex-dev-dark`
- Urdu and Persian Nastaliq support in `latex` / `latex-dark` via `lang="ur"` and `lang="fa"` on block or inline content
- Stronger developer ergonomics for inline code, fenced blocks with a separate language label, tables, diagrams, links, screenshots, and keyboard shortcuts
- Matching Typora sidebar, source mode, and print/export presentation
- macOS traffic lights sidebar offset fix

## Which theme to use

- `latex` / `latex-dark`: best for essays, papers, and long-form reading
- `latex-dev-dark`: best for READMEs, design docs, API notes, changelogs, and code-heavy Markdown in dark mode, with JuliaMono for code and a detached fenced-code language label

Demos:

- General demo: `docs/demo.md`
- Developer demo for `latex-dev-dark`: `docs/dev-demo.md`

## Language Support

For Urdu and Persian Nastaliq text in `latex` or `latex-dark`, add `lang="ur"` or `lang="fa"` to a block or inline span:

```html
<p lang="ur">یہ پیراگراف نستعلیق میں دکھایا جائے گا۔</p>
<p>English text with <span lang="fa">این بخش فارسی</span> inline.</p>
```

## Installation

Run one command on macOS, Linux, or Windows (Git Bash / WSL). The installer detects your platform, prints clear step-by-step logs, and installs the files automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash
```

Default Typora theme folders:

- macOS: `~/Library/Application Support/abnerworks.Typora/themes` (or sandboxed path)
- Linux: `~/.config/Typora/themes`
- Windows: `%APPDATA%\Typora\themes`

Optional flags:

- `--theme-dir "/path/to/Typora/themes"` to force an install path
- `--ref "<branch|tag|commit>"` to install from a specific Git ref

Example:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/scripts/install.sh | bash -s -- --theme-dir "/custom/themes/path"
```

### Manual install

1. Download the zip file from releases, then unzip it.
2. Open Typora.
3. Go to Preferences -> Appearance.
4. Click Open Theme Folder.
5. Copy `latex.css`, `latex-dark.css`, `latex-dev-dark.css`, and the `latex_fonts` folder into there.
6. Restart Typora or switch to `latex`, `latex-dark`, or `latex-dev-dark` from the Themes menu to reload.

#### Enjoy ❤️!

## Notes

- The repo theme code is licensed under Apache-2.0. Keep the `LICENSE` and `NOTICE` attribution information when redistributing it.
- Font source notes are documented in `docs/THIRD_PARTY_NOTICES.md`.
- The theme works offline once installed because the required font assets are bundled locally.
- Designed and tested on macOS. Not fully tested, but should work for Windows/Linux.
- To customize colors or spacing, edit the `:root` variables at the top of each theme file.
