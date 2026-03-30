<p align="center">
  <img src="https://github.com/user-attachments/assets/afc4addd-05d3-46bf-8ebf-2a5b738b70e6" alt="light" width="48%" />
  <img src="https://github.com/user-attachments/assets/19cd41a2-cd5c-4776-93ff-231792d32d2f" alt="dark" width="48%" />
</p>


# ✍️ LaTeX Typora Theme

> 中文说明请见：[简体中文 README](./README_zh-CN.md)

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

The installer auto-detects the common Typora theme location on macOS and copies `latex.css`, `latex-dark.css`, and `latex_fonts/` into there.

If your Typora install uses a custom theme folder, pass it explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-macos.sh | bash -s -- --theme-dir "$HOME/Library/Application Support/abnerworks.Typora/themes"
```

Default Typora theme folder on macOS:

- `~/Library/Application Support/abnerworks.Typora/themes`

### Linux

Run this on Linux to install the current theme directly into Typora's default theme folder:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-linux.sh | bash
```

The Linux installer uses Typora's default theme location, `~/.config/Typora/themes`, and also accepts `--theme-dir` if your setup uses a different folder.

If you want to point it at a custom theme folder, pass it explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-linux.sh | bash -s -- --theme-dir "/path/to/Typora/themes"
```

Default Typora theme folder on Linux:

- `~/.config/Typora/themes`

### Windows

Run this in PowerShell to install the current theme directly into Typora's default theme folder:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "irm https://raw.githubusercontent.com/shamsghi/LatexTypora/main/install-windows.ps1 | iex"
```

If you already downloaded the repo, you can also run the installer locally:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows.ps1
```

The Windows installer uses Typora's default theme location, `%APPDATA%\Typora\themes`, and also accepts `-ThemeDir` if your setup uses a different folder.

If you want to point it at a custom theme folder, pass it explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-windows.ps1 -ThemeDir "C:\path\to\Typora\themes"
```

Default Typora theme folder on Windows:

- `%APPDATA%\Typora\themes`

### Manual install

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
- The theme works offline once installed because the Computer Modern fonts are bundled locally.
- Windows and Linux installer defaults follow Typora's documented theme folders: `%APPDATA%\Typora\themes` on Windows and `~/.config/Typora/themes` on Linux.
- To customize colors or spacing, edit the `:root` variables at the top of each theme file.
