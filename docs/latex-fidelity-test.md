# On the Typographic Fidelity of Screen Renderings

Open this file with `latex` or `latex-dark` selected. Each section states what
it is checking, so a regression is visible without measuring anything.

## Paragraph indentation

*Check: this first paragraph sits flush left. Every later paragraph in the
section starts with an indent, and there is no blank band between them.*

Typography is the craft of arranging type to make written language legible, readable, and appealing when displayed. The arrangement of type involves selecting typefaces, point sizes, line lengths, line-spacing, and letter-spacing, and adjusting the space between pairs of letters.

The term typography is also applied to the style, arrangement, and appearance of the letters, numbers, and symbols created by the process. Type design is a closely related craft, sometimes considered part of typography; most typographers do not design typefaces, and some type designers do not consider themselves typographers.

Typography also may be used as a decorative device, unrelated to the communication of information. Typography is the work of typesetters, compositors, typographers, graphic designers, art directors, manga artists, comic book artists, and clerical workers.[^one]

### Line measure and hyphenation

*Check: roughly 70 characters per line, right edge flush, words hyphenated at
the break rather than leaving rivers of white space.*

Until the Digital Age, typography was a specialized occupation. Digitization opened up typography to new generations of previously unrelated designers and lay users. As the capability to create typography has become ubiquitous, the application of principles and best practices developed over generations of skilled workers and professionals has diminished.

#### Fourth level heading

*Check: numbered `1.1.1`, set at body size, bold.*

The word *typography* comes from the Greek roots τύπος **typos** "impression" and -γραφία **-graphia** "writing". Nested emphasis such as *an aside with *a stress* inside it* should go upright on the inner span, the way `\emph` toggles.

##### Fifth level stands in for LaTeX's paragraph
*Check: bold, with the body text tight underneath it.*

###### Sixth level stands in for subparagraph
*Check: bold italic, indented by `\parindent`.*

## Mathematics

*Check: display math is centred with about one blank line above and below, and
the paragraph after it is **not** indented, because `$$…$$` is `\[ \]`.*

Inline math such as $e^{i\pi} + 1 = 0$ blends into the prose, while display math gets its own measure:

$$
\int_0^1 x^2 \, dx = \frac{1}{3}
$$

A second paragraph after the display equation continues the same thought, so LaTeX leaves it flush.

$$
\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}
$$

To number these, set `--equation-number: "(" counter(latex-equation) ")"` in
`:root` and reload the theme; the numbers appear flush right.

## Lists

*Check: `•` then `–` then `∗` down the levels, and `1.` then `(a)` then `i.`
for enumerations — these are LaTeX's `\labelitemi..iv` and `\labelenumi..iv`.*

- Serif body text for long-form reading, with a line long enough to wrap so that the hanging indentation is visible.
- Monospace blocks for code and metadata
  - A nested item
  - Another nested item
    - And a third level
- Subtle rules for quotes, tables, and footnotes

1. Open the file in Typora.
2. Switch between `latex` and `latex-dark`, then watch a longer enumerated item wrap across more than one line of measure.
   1. A nested enumeration
   2. With two items
3. Scroll slowly and notice the spacing.

*Check: this paragraph after the list **is** indented — a blank line started a
new paragraph, which is what LaTeX indents.*

## Quotations

*Check: indented on both sides, no rule, no tint, no size change — LaTeX's
`quote` environment. Alerts keep their frame because they are a GitHub
construct, not a LaTeX one.*

> Good document themes disappear into the reading experience while still giving structure, hierarchy, and a little ceremony to the page.

Some following prose to check the spacing after a quotation block.

> [!NOTE]
> Typora renders GitHub-style alerts when the feature is enabled in preferences.

> [!CAUTION]
> This syntax is less portable than plain blockquotes across older tooling.

## Tables

*Check: booktabs rules — a heavier rule top and bottom, a lighter one under the
header — and the table set at its natural width, centred, not stretched to the
full measure.*

| Element | Alignment | What to notice |
| :-- | :-: | --: |
| Heading | center | Centered title and calm hierarchy |
| Paragraph | center | Justified body copy with even texture |
| Code | center | Latin Modern Mono inside a thin frame |

<figure>
  <table>
    <thead><tr><th>Symbol</th><th>Meaning</th></tr></thead>
    <tbody>
      <tr><td>c</td><td>Speed of light</td></tr>
      <tr><td>m</td><td>Mass</td></tr>
    </tbody>
  </table>
  <figcaption>Table 1: a caption sits close under its table, centred and small.</figcaption>
</figure>

## Code

*Check: inline code has no border or rounded chip — just the monospace face,
like `\texttt`. Fenced blocks keep a thin frame, like a `listings` box.*

```python
def greet(theme: str) -> str:
    """Return a greeting for the given theme."""
    return f"Hello from {theme}!"
```

Inline `code` inside a sentence, a keyboard shortcut <kbd>Cmd</kbd> + <kbd>P</kbd>, and a long URL: <https://example.org/a/very/long/path/that/might/overflow/the/measure>.

## Description list

<dl>
  <dt>Typography</dt>
  <dd>The craft of arranging type.</dd>
  <dt>Kerning</dt>
  <dd>Adjusting the space between pairs of letters.</dd>
</dl>

## CJK

*Check: the first paragraph after the heading is flush, later ones indent by
exactly two full-width characters.*

<p lang="zh">排版是一门关于文字编排的技艺，目的在于使书面语言在展示时清晰、易读且美观。文字的编排包括字体的选择、字号、行长、行距以及字距的调整。</p>

<p lang="zh">排版一词同样用于描述通过这一过程所产生的字母、数字与符号的样式、编排与外观。字体设计是与之密切相关的技艺，有时被视为排版的一部分。</p>

<p lang="ja">これは日本語本文のテストです。句読点、括弧「サンプル」、中黒・ダッシュ、そして English words を混ぜたときの読みやすさを確認します。</p>

## Right to left

<p lang="ur">یہ ایک اردو جملہ ہے جو نستعلیق رسم الخط میں لکھا گیا ہے اور دائیں سے بائیں بہتا ہے۔</p>

<p lang="fa">این یک جملهٔ فارسی است که با همان قلم نستعلیق نمایش داده می‌شود.</p>

## Footnotes

*Check: the footnote block below sits under a short rule — 40% of the measure,
flush left — and is set in `\footnotesize`.*

The end.[^two]

[^one]: A footnote with some explanatory text that runs a little long, so its second line is visible.
[^two]: A second footnote.
