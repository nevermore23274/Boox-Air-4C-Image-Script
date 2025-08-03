# NASA Poster Converter for BOOX Note Max
A simple script to resize some of the NASA images for either a Screen Saver or Notebook Cover. This was intended for my Note Max with a 13.3" screen.

This script is designed to convert high-resolution, portrait-oriented images—like NASA's [Visions of the Future](https://www.jpl.nasa.gov/galleries/visions-of-the-future/) posters—into grayscale, BOOX-ready 3200×2400 JPEGs optimized for the Note Max's ePaper display.

**Original Poster**  
![Original TRAPPIST-1 Poster](example_images/trappist.jpg)

**Converted for BOOX Note Max**  
![Converted Version](example_images/trappist_booxmax.jpg)

## Why This Script?

The original idea and conversion approach came from [this excellent Reddit post](https://www.reddit.com/r/Onyx_Boox/comments/w9zili/nasa_posters_adapted_for_eink/), which resized NASA posters to fit older BOOX devices. However, the original script:
- Targeted a smaller screen resolution (1072×1448)
- Used Windows batch syntax (I'm on Linux)
- Didn’t directly support the 13.3" BOOX Note Max (Carta 1300, 300 ppi, 3200×2400)

This script adapts that process for **Linux users** and **larger BOOX screens** while preserving the original intent: **no cropping, no distortion, and optimized grayscale conversion**.

## Features

- Rotates images temporarily to better scale tall portraits
- Resizes to fit 3200×2400 without cropping or adding bars
- Applies grayscale (Rec709), contrast boosting, and dithering
- Optional remapping using an eInk palette (`_eink_cmap.gif`)
- Converts to high-quality JPEG ready for BOOX wallpaper or display use

## Optional: Upscale First

Some posters (especially older scans) may benefit from upscaling before conversion. If you use the script and you see bars along the top or bottom of your image, or the image is stretched then you can use [Upscayl](https://github.com/upscayl/upscayl) first and would just do a 2x or 3x with the Digital Art model.

## Usage

1. Place your `.png` or `.jpg` poster(s) in the folder
2. Make sure `_eink_cmap.gif` (if used) is in the same directory
3. Run:

```bash
chmod +x convert_to_booxmax.sh
```

4. Run:
```bash
./convert_to_booxmax.sh
```

## Optional: Custom Screen Sizes
You can also pass a custom resolution to adapt the script for other e-ink devices:
```bash
./convert_to_booxmax.sh [WIDTH] [HEIGHT]
```

## Examples:
- Nova Air C (7.8"):
```bash
./convert_to_booxmax.sh 1404 1872
```
- Tab Ultra (10.3"):
```bash
./convert_to_booxmax.sh 1872 1404
```
- BOOX Note Max (portrait view):
```bash
./convert_to_booxmax.sh 2400 3200
```

The converted images will be named with the `_booxmax.jpg` suffix and saved in the same directory
