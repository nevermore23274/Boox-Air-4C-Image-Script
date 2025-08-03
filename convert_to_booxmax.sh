#!/bin/bash

# Default configuration
WIDTH=2400
HEIGHT=3200
USE_GRAYSCALE=true
QUALITY=75
DRY_RUN=false
AUTO_YES=false

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [WIDTH HEIGHT]

Process images for BOOX Note Max e-reader.

OPTIONS:
    --color, -c     Use color mode (default: grayscale)
    --quality, -q   JPEG quality (default: 75)
    --dry-run       Show configuration and exit without processing
    --yes, -y       Skip confirmation prompt
    --help, -h      Show this help

ARGUMENTS:
    WIDTH HEIGHT    Custom resolution (default: 2400x3200)

EXAMPLES:
    $0                      # Process with defaults (grayscale, 2400x3200)
    $0 --color              # Process in color mode
    $0 1200 1600            # Custom resolution, grayscale
    $0 --color 1200 1600    # Custom resolution, color mode
    $0 --dry-run            # Show settings without processing
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --color|-c)
            USE_GRAYSCALE=false
            shift
            ;;
        --quality|-q)
            QUALITY="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            # Handle positional arguments (width/height)
            if [[ "$1" =~ ^[0-9]+$ ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                WIDTH="$1"
                HEIGHT="$2"
                shift 2
            else
                echo "Error: Invalid arguments. Use --help for usage." >&2
                exit 1
            fi
            ;;
    esac
done

# Validate inputs
if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick (magick command) not found" >&2
    exit 1
fi

if [[ ! "$QUALITY" =~ ^[0-9]+$ ]] || [[ "$QUALITY" -lt 1 || "$QUALITY" -gt 100 ]]; then
    echo "Error: Quality must be between 1-100" >&2
    exit 1
fi

echo "Configuration:"
echo "  Resolution: ${WIDTH}x${HEIGHT}"
echo "  Mode: $([ "$USE_GRAYSCALE" = true ] && echo "Grayscale" || echo "Color")"
echo "  Quality: ${QUALITY}"
echo

# Find image files
shopt -s nullglob
image_files=(*.jpg *.jpeg *.png *.JPG *.JPEG *.PNG)
shopt -u nullglob

if [[ ${#image_files[@]} -eq 0 ]]; then
    echo "No image files found in current directory" >&2
    exit 1
fi

# Show configuration and handle dry-run/confirmation
echo "Will process ${#image_files[@]} image(s)"

if [[ "$DRY_RUN" = true ]]; then
    echo "Dry run - no files will be processed"
    exit 0
fi

if [[ "$AUTO_YES" = false ]]; then
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
fi

# Build ImageMagick command
magick_cmd=(
    -rotate 90
    -colorspace Lab
    -filter LanczosSharp
    -distort Resize "${HEIGHT}x${WIDTH}!"
    -colorspace sRGB
    -background white -gravity center -extent "${HEIGHT}x${WIDTH}!"
)

# Add grayscale conversion if needed
if [[ "$USE_GRAYSCALE" = true ]]; then
    magick_cmd+=(
        -colorspace Gray           # Convert to grayscale
        -contrast-stretch 2%x98%   # Gentle contrast stretch, preserves midtones
        -gamma 1.1                 # Slightly brighten
        -unsharp 0x1+0.5+0         # Enhance local contrast/details
        -dither FloydSteinberg     # Add dithering to prevent banding on e-readers
    )
fi

magick_cmd+=(
    -rotate -90
    -quality "$QUALITY" +profile "*"
)

# Process files
processed=0
failed=0

for file in "${image_files[@]}"; do
    filename="${file%.*}"
    output="${filename}_booxmax.jpg"
    
    echo -n "Processing: $file → $output ... "
    
    if magick "$file" "${magick_cmd[@]}" "$output" 2>/dev/null; then
        echo "✓"
        ((processed++))
    else
        echo "✗ (failed)"
        ((failed++))
    fi
done

echo
echo "Results: $processed processed, $failed failed"
