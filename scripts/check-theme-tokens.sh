#!/usr/bin/env bash
#
# A check, and only a check. This script reads latex.css and prints what it
# finds. It never edits a file, installs anything, or touches your Typora
# theme folder, so running it cannot break the theme or your setup. The
# worst it can do is tell you something is wrong.
#
# It is also no part of installation. Nothing runs it for you: not
# scripts/install.sh, which only copies latex*.css and the fonts into the
# Typora theme folder, and not any git hook. It is a maintainer's tool --
# run it yourself, whenever you want to confirm the colours are still in
# order. Users installing the theme never need it.
#
# What it confirms: that latex.css keeps every colour in a var() token.
#
# latex-dark.css imports latex.css and overrides only :root, so a colour
# written as a literal in a rule body reaches the dark variants unchanged.
# A light value on a black page is usually wrong, and because it renders
# correctly in the light theme it is easy to ship without noticing.
#
# Only latex.css is bound by this. latex-dark.css may use literals freely:
# the one file importing it, latex-dev-dark.css, is also dark.
#
# Exits 0 when clean, 1 when a literal is found.

set -euo pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [FILE...]

Reports colours written as literals outside the :root block. With no
arguments, checks latex.css at the repository root.

Comments and the :root block are ignored. Metrics, geometry and font
stacks are not checked -- the constraint is on colour alone.
EOF
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -gt 0 ]]; then
    FILES=("$@")
else
    FILES=("${REPO_ROOT}/latex.css")
fi

for f in "${FILES[@]}"; do
    [[ -f "$f" ]] || { printf 'No such file: %s\n' "$f" >&2; exit 2; }
done

if perl -e '
    my $found = 0;

    for my $path (@ARGV) {
        open my $fh, "<", $path or die "cannot read $path: $!\n";
        my $src = do { local $/; <$fh> };
        close $fh;

        my @original = split /\n/, $src, -1;

        # Blank out comments and :root, keeping line numbers intact.
        $src =~ s{/\*.*?\*/}{ my $t = $&; $t =~ s/[^\n]/ /g; $t }gse;
        $src =~ s{:root\s*\{.*?\n\}}{ my $t = $&; $t =~ s/[^\n]/ /g; $t }gse;

        # A bare word is only a colour when it is not part of a longer
        # identifier, which is what keeps white-space out of this.
        my $named = join "|", qw(
            white black red blue green gray grey silver yellow orange
            purple pink brown navy teal olive maroon lime aqua fuchsia
            cyan magenta gold
        );

        my $n = 0;
        for my $line (split /\n/, $src, -1) {
            $n++;
            next unless $line =~ m{
                  \# [0-9a-fA-F]{3,8} \b
                | \b (?: rgba? | hsla? | hwb | oklch | oklab | lab | lch | color ) \(
                | (?<! [-\w] ) (?: $named ) (?! [-\w] )
            }x;
            printf "%s:%d: colour literal outside :root -- %s\n",
                $path, $n, ($original[$n - 1] =~ s/^\s+|\s+$//gr);
            $found = 1;
        }
    }

    exit($found ? 1 : 0);
' "${FILES[@]}"; then
    printf 'ok: every colour comes from a :root token\n'
else
    status=$?
    [[ $status -eq 1 ]] || exit "$status"
    printf '\nEach line above hardcodes a colour that the dark variants will\n'
    printf 'inherit as-is. Move it to a :root token and reference it with var().\n'
    exit 1
fi
