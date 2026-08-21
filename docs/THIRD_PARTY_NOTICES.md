# Third-Party Notices

## Embedded subsets

Besides the original font files, this repository ships two generated
stylesheets — `latex_fonts/embedded-fonts.css` and
`latex_fonts/embedded-fonts-dev.css` — in which every `@font-face` rule
carries a modified copy of its font inline as a `data:` URI. Those copies are
converted to WOFF2 and, for every face except `Noto Nastaliq Urdu`, reduced to
a subset of their codepoints (Latin, Greek including the polytonic ranges,
punctuation, currency, letterlike symbols, arrows, mathematical operators,
geometric shapes and the Latin ligatures). They exist because Typora's HTML
export deletes `@font-face` rules from a theme stylesheet, which would
otherwise leave an exported document without the theme's typefaces.

They are modified versions of the upstream fonts, and they are not
substitutes for them: the unmodified files remain in `latex_fonts/`, each
face's rule loads its original file first, and the licences below cover both.
`scripts/build-embedded-fonts.py` regenerates the stylesheets and documents
exactly what it does to each font.

## New Computer Modern

This repository bundles local `otf` assets for the following font families used by the Typora themes:

- `New Computer Modern` (serif body text)
- `New Computer Modern Sans` (captions, UI and diagram labels)
- `New Computer Modern Mono` (code)

All three come from the same upstream release, version 7.1.1.

Source of bundled font files:

- CTAN package `newcomputermodern`
- <https://ctan.org/pkg/newcomputermodern>
- <https://download.gnu.org.ua/release/newcm/>

License note:

- CTAN lists the `newcomputermodern` package under the GUST Font License (GFL).
- The CTAN package metadata attributes the fonts to Antonis Tsolomitis.
- A local copy of the GFL text is included at `docs/LICENSES/GUST-FONT-LICENSE.md`.

If you redistribute the bundled `New Computer Modern` files, keep the license text and attribution with them.

## iA Writer Mono

This repository also bundles local `ttf` assets for `iA Writer Mono` as a legacy mono font set retained in the repository.

Source of bundled font files:

- iA Fonts repository
- <https://github.com/iaolo/iA-Fonts>
- <https://github.com/iaolo/iA-Fonts/tree/master/iA%20Writer%20Mono>

License note:

- The upstream `iA Writer Mono` package includes the SIL Open Font License 1.1.
- The repository notes that the typeface is based on IBM Plex and uses the reserved font name `iA Writer`.
- A local copy of the upstream license is included at `docs/LICENSES/iA-Writer-Mono-LICENSE.md`.

If you redistribute the bundled `iA Writer Mono` files, keep the license text and attribution with them.

## JuliaMono

This repository also bundles local `ttf` assets for `JuliaMono`, which is used by the developer-focused dark theme for code.

Source of bundled font files:

- JuliaMono project
- <https://juliamono.netlify.app>
- CTAN package `juliamono`
- <https://ctan.org/pkg/juliamono>

License note:

- The JuliaMono font files are distributed under the SIL Open Font License.
- The CTAN `juliamono` package metadata points to the JuliaMono project and packages the upstream font files.
- A local copy of the upstream license is included at `docs/LICENSES/JuliaMono-LICENSE.md`.

If you redistribute the bundled `JuliaMono` files, keep the license text and attribution with them.

## Noto Nastaliq Urdu

This repository also bundles a local `ttf` asset for `Noto Nastaliq Urdu`, which is used for Urdu and Persian Nastaliq content when `lang="ur"` or `lang="fa"` is present.

Source of bundled font files:

- Noto Nastaliq project
- <https://notofonts.github.io/nastaliq/>
- <https://github.com/notofonts/nastaliq>

License note:

- The `Noto Nastaliq Urdu` font files are distributed under the SIL Open Font License 1.1.
- The upstream source repository attributes the font to The Noto Project Authors.
- A local copy of the upstream license is included at `docs/LICENSES/NotoNastaliqUrdu-LICENSE.md`.

If you redistribute the bundled `Noto Nastaliq Urdu` file, keep the license text and attribution with it.
