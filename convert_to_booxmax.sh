#!/bin/bash

# Default resolution (BOOX Note Max, portrait)
WIDTH=2400
HEIGHT=3200

# Allow user reslution override
if [[ -n "$1" && -n "$2" ]]; then
  WIDTH=$1
  HEIGHT=$2
  echo "Using custom resolution: ${WIDTH}x${HEIGHT}"
else
  echo "Using default resolution: ${WIDTH}x${HEIGHT}"
fi

for file in *.jpg *.jpeg *.png; do
  [ -e "$file" ] || continue
  filename="${file%.*}"

  magick "$file" \
    -rotate 90 \
    -colorspace Lab \
    -filter LanczosSharp \
    -distort Resize ${HEIGHT}x${WIDTH}! \
    -colorspace sRGB \
    -background white -gravity center -extent ${HEIGHT}x${WIDTH}! \
    -grayscale Rec709Luminance \
    -colorspace sRGB \
    -dither FloydSteinberg \
    -remap _eink_cmap.gif \
    -rotate -90 \
    -quality 75 "${filename}_booxmax.jpg"
done

