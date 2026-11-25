#!/usr/bin/env bash
# Copies the Skribble faces the app letters with from `skribble_font_recursive`
# into `assets/fonts/`, trimmed for size.
#
# The upstream package registers 129 faces (60 MB). Every one of them would
# ship in each app binary, and Flutter web downloads every registered face
# before it draws the first frame. OpenBudget letters with three families
# (see `obDisplayTypeface`, `obTextTypeface` and `obStampTypeface` in
# `lib/src/theme/openbudget_theme.dart`), so only their weights in use are
# kept. Each face keeps every character it has; only stylistic alternates the
# app never asks for are dropped, which halves its size.
#
# Run from `openbudget_ui/` with fonttools on the PATH, for example:
#
#   nix shell nixpkgs#python3Packages.fonttools -c tool/subset_fonts.sh
#
# Bump VERSION to pick up a new upstream release, then run the script again.
set -euo pipefail

VERSION=0.3.1
FACES=(
	# Display: page titles, headlines and hero amounts (w800, w900).
	Skribble-Bold
	Skribble-ExtraBold
	Skribble-Black
	# Text and amounts: body, labels, titles and eyebrows (w400 to w900).
	SkribbleLinearPlayful-Regular
	SkribbleLinearPlayful-Italic
	SkribbleLinearPlayful-Medium
	SkribbleLinearPlayful-MediumItalic
	SkribbleLinearPlayful-SemiBold
	SkribbleLinearPlayful-Bold
	SkribbleLinearPlayful-ExtraBold
	SkribbleLinearPlayful-Black
	# Stamps and seals (w800).
	SkribbleMonoPlayful-Bold
	SkribbleMonoPlayful-ExtraBold
	SkribbleMonoPlayful-Black
)
# Kerning, ligatures and contextual forms keep the lettering as designed;
# mark positioning keeps accented letters right; tnum, lnum and pnum serve
# `FontFeature.tabularFigures()` and friends.
FEATURES=kern,liga,clig,calt,ccmp,locl,mark,mkmk,tnum,lnum,pnum,case,frac,sups,subs,ordn

source_dir="$(find "${PUB_CACHE:-$HOME/.pub-cache}/hosted/pub.dev" -maxdepth 1 \
	-name "skribble_font_recursive-$VERSION" | head -1)"
if [[ -z $source_dir ]]; then
	dart pub cache add skribble_font_recursive --version "$VERSION" >/dev/null
	source_dir="${PUB_CACHE:-$HOME/.pub-cache}/hosted/pub.dev/skribble_font_recursive-$VERSION"
fi
fonts="$source_dir/assets/fonts"
out="$(dirname "$0")/../assets/fonts"

rm -f "$out"/*.ttf
for face in "${FACES[@]}"; do
	pyftsubset "$fonts/$face.ttf" \
		--output-file="$out/$face.ttf" \
		--unicodes='*' \
		--layout-features="$FEATURES" \
		--name-IDs='*' --name-languages='*' \
		--no-glyph-names
done
cp "$fonts/OFL.txt" "$out/OFL.txt"
du -ch "$out"/*.ttf | tail -1
