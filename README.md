<div align="center">

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/a093ed6e-a166-4c0e-accf-852dc034dd4a" alt="Light Mode" />
      <br />
      <sub>☀️ <strong>Light Mode</strong> &nbsp;—&nbsp; <code>latex.css</code></sub>
    </td>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/677f5f36-a9cc-4867-9fee-1d7f6ff4ca28" alt="Dark Mode" />
      <br />
      <sub>🌙 <strong>Dark Mode</strong> &nbsp;—&nbsp; <code>latex-dark.css</code></sub>
    </td>
  </tr>
</table>

<br />

<img width="50%" src="https://github.com/user-attachments/assets/9a19c61b-fe83-4be8-95bc-6491db57ab73" alt="Developer Dark Mode" />
<br />
<sub>💻 <strong>Developer Dark Mode</strong> &nbsp;—&nbsp; <code>latex-dev-dark.css</code></sub>

</div>



# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

A family of Typora themes inspired by classic LaTeX documents, including a more code-forward dark variant for developer-heavy Markdown.

- `latex.css` for light mode
- `latex-dark.css` for dark mode
- `latex-dev-dark.css` for developer-focused dark mode
- Bundled New Computer Modern, Latin Modern, JuliaMono, iA Writer Mono, and Noto Nastaliq Urdu assets for offline use

## Features

- New Computer Modern body text with strong modern/polytonic Greek coverage, plus Latin Modern for code and UI accents
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

In `latex` or `latex-dark`, serif body text uses bundled New Computer Modern, which includes modern and polytonic Greek (including Ancient Greek editorial marks and numerals) in a Computer Modern-compatible academic style.

Greek text works out of the box, but adding language tags can improve tooling and export semantics:

```html
<p lang="el">Η τυπογραφία του κειμένου διατηρεί καθαρό ρυθμό και σαφήνεια.</p>
<p lang="grc">Ἐν ἀρχῇ ἦν ὁ λόγος, καὶ ὁ λόγος ἦν πρὸς τὸν θεόν.</p>
```

Arabic-script text can still fall through to bundled Noto Nastaliq Urdu while typing. Add `lang="ur"` or `lang="fa"` when you also want the RTL layout, alignment, and taller Nastaliq spacing rules:

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
