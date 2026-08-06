#!/usr/bin/env bash
#
# Regenerates the WebP derivatives that the site actually serves.
#
#   images/vista/*.JPG|JPEG   (originals, read-only inputs — never modified)
#     -> images/vista/grid/<base>.webp   ~1000px, timeline thumbnails
#     -> images/vista/full/<base>.webp   ~2200px, lightbox
#   images/profile.jpg        -> images/profile.webp   ~400px
#
# EXIF is dropped: cwebp writes no metadata unless asked, which also strips the
# GPS coordinates present in several of the originals.
#
# Requires: cwebp (brew install webp), sips (macOS built-in).
# Safe to re-run; existing derivatives are overwritten.

set -euo pipefail

cd "$(dirname "$0")/.."

GRID_MAX=1000
GRID_Q=78
FULL_MAX=2200
FULL_Q=80

command -v cwebp >/dev/null || { echo "cwebp not found — run: brew install webp" >&2; exit 1; }

# encode <src> <out> <max-edge> <quality> <width> <height>
encode() {
  local src=$1 out=$2 max=$3 q=$4 w=$5 h=$6
  local -a resize=()
  if [ "$w" -ge "$h" ]; then
    [ "$w" -gt "$max" ] && resize=(-resize "$max" 0)
  else
    [ "$h" -gt "$max" ] && resize=(-resize 0 "$max")
  fi
  cwebp -quiet -q "$q" "${resize[@]}" "$src" -o "$out"
}

dimensions() {
  sips -g pixelWidth -g pixelHeight "$1" | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w, h}'
}

mkdir -p images/vista/grid images/vista/full

# nocaseglob so lowercase .jpg files are picked up too; nullglob so an unmatched
# pattern expands to nothing rather than a literal string.
shopt -s nocaseglob nullglob

count=0
for src in images/vista/*.jpg images/vista/*.jpeg; do
  base=$(basename "$src"); base=${base%.*}
  read -r w h < <(dimensions "$src")
  encode "$src" "images/vista/grid/$base.webp" "$GRID_MAX" "$GRID_Q" "$w" "$h"
  encode "$src" "images/vista/full/$base.webp" "$FULL_MAX" "$FULL_Q" "$w" "$h"
  count=$((count + 1))
  printf '\r  %s photos encoded' "$count"
done
printf '\n'

read -r w h < <(dimensions images/profile.jpg)
encode images/profile.jpg images/profile.webp 400 82 "$w" "$h"
echo "  profile.webp"

# Social preview images. These stay JPEG because link crawlers handle WebP
# inconsistently. Going via cwebp first is deliberate: it writes no metadata, so
# the images crawlers fetch carry none of the originals' EXIF or GPS tags.
og_image() {
  local src=$1 out=$2 tmp
  tmp=$(mktemp -t ogimg).webp
  read -r w h < <(dimensions "$src")
  encode "$src" "$tmp" 1200 88 "$w" "$h"
  sips -s format jpeg -s formatOptions 85 "$tmp" --out "$out" >/dev/null
  rm -f "$tmp"
}

og_image images/profile.jpg images/og-profile.jpg
og_image images/vista/kodachadri.jpg images/og-vista.jpg
echo "  og-profile.jpg, og-vista.jpg"

echo
echo "originals:   $(du -sh --exclude=grid --exclude=full images/vista 2>/dev/null | cut -f1 ||
                     du -sh -I grid -I full images/vista | cut -f1)"
echo "grid tier:   $(du -sh images/vista/grid | cut -f1)"
echo "full tier:   $(du -sh images/vista/full | cut -f1)"
