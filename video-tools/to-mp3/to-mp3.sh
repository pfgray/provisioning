#!/bin/bash

# Script to convert OPUS files to MP3
# Usage: ./opus-to-mp3.sh file1.opus file2.opus ...
#    or: ./opus-to-mp3.sh *.opus

# Check if any arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <opus_files...>"
    echo "Example: $0 *.opus"
    echo "Example: $0 file1.opus file2.opus file3.opus"
    exit 1
fi

# Check if ffmpeg is available
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed or not in PATH"
    exit 1
fi

# Default settings (you can modify these)
BITRATE="192k"
CODEC="libmp3lame"

# Process each file
total_files=$#
current_file=0

echo "Converting $total_files OPUS file(s) to MP3..."
echo "Settings: Codec=$CODEC, Bitrate=$BITRATE"
echo "----------------------------------------"

for opus_file in "$@"; do
    current_file=$((current_file + 1))
    
    # Check if file exists and has .opus extension
    if [[ ! -f "$opus_file" ]]; then
        echo "[$current_file/$total_files] ❌ File not found: $opus_file"
        continue
    fi
    
    if [[ "$opus_file" != *.opus ]]; then
        echo "[$current_file/$total_files] ❌ Skipping non-OPUS file: $opus_file"
        continue
    fi
    
    # Generate output filename
    mp3_file="${opus_file%.opus}.mp3"
    
    # Check if output file already exists
    if [[ -f "$mp3_file" ]]; then
        echo "[$current_file/$total_files] ⚠️  Output file already exists: $mp3_file"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping: $opus_file"
            continue
        fi
    fi
    
    echo "[$current_file/$total_files] 🔄 Converting: $opus_file → $mp3_file"
    
    # Run ffmpeg conversion
    if ffmpeg -i "$opus_file" -codec:a "$CODEC" -b:a "$BITRATE" "$mp3_file" -y -loglevel warning; then
        echo "[$current_file/$total_files] ✅ Successfully converted: $opus_file"
    else
        echo "[$current_file/$total_files] ❌ Failed to convert: $opus_file"
    fi
    echo
done

echo "----------------------------------------"
echo "Conversion complete!"