#!/bin/bash

# Define input and output directories
input_dir="/media/share/mapp/public/QE_plus_unifr/test/raw"
output_dir="/media/share/mapp/public/QE_plus_unifr/test/converted"
log_file="/media/share/mapp/public/QE_plus_unifr/test/logfile.log"
processed_files="/media/share/mapp/public/QE_plus_unifr/test/processed_files.txt"

# Create processed_files.txt if it doesn't exist
if [ ! -f "$processed_files" ]; then
    touch "$processed_files"
fi

# Function to convert a file
convert_file() {
    local file="$1"
    echo "$(date): Converting file $file" >> "$log_file"
    docker run --rm -e WINEDEBUG=-all \
    -v "$input_dir:/data" \
    -v "$output_dir:/output" \
    chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert "/data/$(basename "$file")" --outdir /output --mzML --64 --zlib
    echo "$(date): Finished converting file $file" >> "$log_file"
}

# Check for new .raw files and process them
for file in "$input_dir"/*.raw; do
    if ! grep -Fxq "$(basename "$file")" "$processed_files"; then
        echo "$(date): Detected new file: $file" >> "$log_file"
        convert_file "$file"
        echo "$(basename "$file")" >> "$processed_files"
    fi
done
