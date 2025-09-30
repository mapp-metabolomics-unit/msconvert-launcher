#!/bin/bash

# Define input and output directories
input_dir="/media/share/mapp/public/QE_HFX_unifr/raw"
output_dir="/media/share/mapp/public/QE_HFX_unifr/converted"
log_file="/media/share/mapp/public/QE_HFX_unifr/logfile.log"
processed_files="/media/share/mapp/public/QE_HFX_unifr/processed_files.txt"
lock_file="/media/share/mapp/public/QE_HFX_unifr/convert_new_files.lock"

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

# Ensure only one instance of the script runs at a time
if [ -e "$lock_file" ] && kill -0 $(cat "$lock_file"); then
    echo "$(date): Script is already running." >> "$log_file"
    exit
fi

# Create a lock file with the current PID
echo $$ > "$lock_file"

# Ensure lock file is removed on script exit
trap "rm -f $lock_file" EXIT

# Check for new .raw files and process them
for file in "$input_dir"/*.raw; do
    if ! grep -Fxq "$(basename "$file")" "$processed_files"; then
        echo "$(date): Detected new file: $file" >> "$log_file"
        convert_file "$file"
        echo "$(basename "$file")" >> "$processed_files"
    fi
done
