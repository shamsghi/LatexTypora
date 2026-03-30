# LaTeX Typora Theme

## Abstract

The quick brown fox jumps over the lazy dog while **bold text**, *italic text*, `inline code`, and ==highlighted text== sit together in the same paragraph. A link to [Typora](https://typora.io) keeps the treatment minimal and print-friendly.[^demo-note]

> Good document themes disappear into the reading experience while still giving structure, hierarchy, and a little ceremony to the page.

## Formulas

Inline math such as $e^{i\pi} + 1 = 0$ blends into the prose, while display math gets a little more room:
$$
\int_0^1 x^2 \, dx = \frac{1}{3}
$$

## Structure

### Lists

- Serif body text for long-form reading
- Monospace blocks for code and metadata
- Subtle rules for quotes, tables, and footnotes

1. Open the file in Typora.
2. Switch between `latex` and `latex-dark`.
3. Scroll slowly and notice the spacing.

### Table

| Element | What to notice |
| :-- | :-- |
| Heading | Centered title and calm hierarchy |
| Paragraph | Justified body copy with even texture |
| Code | Computer Modern Typewriter with thin borders |
| Table | Top and bottom rules in a classic academic style |

## Technical Samples

Inline math such as $e^{i\pi} + 1 = 0$ blends into the prose, while display math gets a little more room:

$$
\int_0^1 x^2 \, dx = \frac{1}{3}
$$

```python
def greet(theme: str) -> str:
    return f"{theme} makes Markdown feel typeset."

print(greet("LaTeX Typora"))
```

---

## Closing Note

This short file is meant to be scanned, not studied, so each block exists to show a different piece of the theme in a single page.

[^demo-note]: Footnotes are styled quietly so they read like scholarly apparatus instead of UI chrome.
