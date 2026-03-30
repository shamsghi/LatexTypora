<p align="center">
  <img src="https://github.com/user-attachments/assets/afc4addd-05d3-46bf-8ebf-2a5b738b70e6" alt="light" width="48%" />
  <img src="https://github.com/user-attachments/assets/19cd41a2-cd5c-4776-93ff-231792d32d2f" alt="dark" width="48%" />
</p>


# ✍️ LaTeX Typora Theme

## 中文说明请见：[简体中文 README](./README_zh-CN.md)

A light and dark Typora theme pair inspired by classic LaTeX documents.

- `latex.css` for light mode
- `latex-dark.css` for dark mode
- Bundled Computer Modern web fonts for offline use

## Features

- Computer Modern typography for text, code, and UI accents
- Clean LaTeX-style spacing, centered titles, and justified paragraphs
- Minimal monochrome styling for tables, blockquotes, links, footnotes, and math
- Matching Typora sidebar, source mode, and print/export presentation
- MacOS traffic lights sidebar offset fix

## Installation

### macOS

Run this on a Mac to install the current theme directly into Typora's theme folder:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-macos.sh | bash
```

The installer auto-detects the common Typora theme location on macOS and copies `latex.css`, `latex-dark.css`,`latex_fonts/` into there.

If your Typora install uses a custom theme folder, pass it explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-macos.sh | bash -s -- --theme-dir "$HOME/Library/Application Support/abnerworks.Typora/themes"
```

### Windows/Linux

1. Download the zip file from releases, then unzip it.
2. Open Typora.
3. Go to Preferences -> Appearance.
4. Click Open Theme Folder.
5. Copy latex.css, latex-dark.css and latex_fonts folder into there.
6. Restart Typora or switch themes from the Themes menu to reset.

#### Enjoy ❤️!

## Notes

- The repo theme code is licensed under Apache-2.0. Keep the `LICENSE` and `NOTICE` attribution information when redistributing it.
- Font source notes are documented in `THIRD_PARTY_NOTICES.md`.
- The theme's work offline once installed because the Computer Modern fonts are bundled locally.
- Designed and tested on macOS. Not fully tested, but should work for Windows/Linux.
- To customize colors or spacing, edit the `:root` variables at the top of each theme file.
