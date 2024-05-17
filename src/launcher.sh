#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -i INPUT_PATH -o OUTPUT_DIR"
    exit 1
}

# Parse command line arguments
while getopts "i:o:" opt; do
    case $opt in
        i) input_path="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if both input path and output directory are provided
if [ -z "$input_path" ] || [ -z "$output_dir" ]; then
    usage
fi

# Ensure the output directory exists
mkdir -p "$output_dir"

# Check if the input path is a directory
if [ -d "$input_path" ]; then
    # Loop through each file in the input directory
    for file in "$input_path"/*; do
        msconvert "$file" -o "$output_dir" --mzML --64 --zlib
    done
elif [ -f "$input_path" ]; then
    # Process the single file
    msconvert "$input_path" -o "$output_dir" --mzML --64 --zlib
else
    echo "Error: Input path is not a valid file or directory."
    exit 1
fi
