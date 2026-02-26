#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
run_id="$(date '+%Y-%m-%dT%H:%M:%S%z')"

input_dir="/mnt/bigdata/mapp/public/QE_plus_unifr/raw"
output_dir="/mnt/bigdata/mapp/public/QE_plus_unifr/converted"
log_file="/mnt/bigdata/mapp/public/QE_plus_unifr/logfile.log"
processed_files="/mnt/bigdata/mapp/public/QE_plus_unifr/processed_files.txt"
failed_files="/mnt/bigdata/mapp/public/QE_plus_unifr/failed_files.txt"
lock_file="/mnt/bigdata/mapp/public/QE_plus_unifr/convert_new_files.lock"
ignore_files="/mnt/bigdata/mapp/public/QE_plus_unifr/ignore_files.txt"
SKIP_PREVIOUS_FAILURES=true
VERBOSE_PREVIOUS_FAILURE_LOGS=false
declare -A failed_map=()

mkdir -p "$(dirname "$log_file")"
mkdir -p "$input_dir" "$output_dir"
touch "$processed_files" "$failed_files" "$ignore_files"

shopt -s nullglob

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S%z') [run=$run_id] $*" >> "$log_file"
}

cleanup() {
    rm -f "$lock_file"
}

trap cleanup EXIT INT TERM

exec 200>"$lock_file"
if ! flock -n 200; then
    log "Script is already running."
    exit 0
fi

trap 'log "ERROR at line $LINENO: ${BASH_COMMAND}"' ERR

source_marker() {
    local file_path="$1"
    local size
    size="$(stat -c '%s' "$file_path")"
    echo "${file_path}|${size}"
}

is_processed() {
    local descriptor="$1"
    grep -Fxq "$descriptor" "$processed_files"
}

is_failed() {
    local descriptor="$1"
    [[ -n "${failed_map[$descriptor]+x}" ]]
}

is_ignored() {
    local file_path="$1"
    local file_name
    file_name="$(basename "$file_path")"
    grep -Fxq "$file_path" "$ignore_files" || grep -Fxq "$file_name" "$ignore_files"
}

is_stable_file() {
    local file_path="$1"
    local size_a
    local size_b
    size_a="$(stat -c '%s' "$file_path")"
    sleep 5
    size_b="$(stat -c '%s' "$file_path")"
    [[ "$size_a" == "$size_b" ]]
}

convert_file() {
    local file_path="$1"
    local output_file="$2"

    log "Converting file $file_path"
    if ! docker run --rm -e WINEDEBUG=-all \
        -v "$input_dir:/data" \
        -v "$output_dir:/output" \
        chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
        wine msconvert "/data/$(basename "$file_path")" --outdir /output --mzML --64 --zlib; then
        log "Conversion failed for $file_path"
        return 1
    fi

    if [ ! -s "$output_file" ]; then
        log "Conversion output missing or empty for $file_path ($output_file)"
        return 1
    fi

    log "Finished converting file $file_path"
    return 0
}

base_name_from_path() {
    local file_path="$1"
    local file_name
    file_name="$(basename "$file_path")"
    echo "${file_name%.[Rr][Aa][Ww]}"
}

mark_failed() {
    local file_path="$1"
    local descriptor="$2"
    if is_failed "$descriptor"; then
        log "Failed marker already present for: $file_path|$descriptor"
        return 0
    fi
    log "Marking failed file: $file_path|$descriptor"
    echo "$(date '+%Y-%m-%d %H:%M:%S%z')|$file_path|$descriptor" >> "$failed_files"
    failed_map["$descriptor"]=1
}

mark_processed() {
    local descriptor="$1"
    echo "$descriptor" >> "$processed_files"
}

load_failed_cache() {
    local tmp_file
    tmp_file="$(mktemp)"
    if [ -s "$failed_files" ]; then
        awk -F'|' '
            NF >= 4 {
                key = $3 "|" $4
                if (!seen[key]++) print
            }
            NF == 2 {
                key = $1 "|" $2
                if (!seen[key]++) print
            }
        ' "$failed_files" > "$tmp_file"
        mv "$tmp_file" "$failed_files"
    else
        : > "$tmp_file"
        mv "$tmp_file" "$failed_files"
    fi

    while IFS='|' read -r _ maybe_path maybe_file maybe_size _rest; do
        if [[ -n "${maybe_size:-}" && -n "${maybe_file:-}" ]]; then
            failed_map["$maybe_file|$maybe_size"]=1
            continue
        fi

        if [[ -n "${maybe_path:-}" && -n "${maybe_file:-}" && -z "${maybe_size:-}" ]]; then
            failed_map["$maybe_path|$maybe_file"]=1
        fi
    done < "$failed_files"
}

count_failed_total() {
    echo "${#failed_map[@]}"
}

log "Starting conversion scan"
load_failed_cache
if ! ls "$input_dir"/*.[Rr][Aa][Ww] >/dev/null 2>&1; then
    log "No RAW files found in $input_dir"
else
    total_files=0
    converted_files=0
    skipped_files=0
    unstable_files=0
    failed_count=0
    previously_failed_count=0
    ignored_files_count=0

    for file in "$input_dir"/*.[Rr][Aa][Ww]; do
        total_files=$((total_files + 1))
        descriptor="$(source_marker "$file")"
        base_name="$(base_name_from_path "$file")"
        output_file="$output_dir/$base_name.mzML"

        if is_ignored "$file"; then
            skipped_files=$((skipped_files + 1))
            ignored_files_count=$((ignored_files_count + 1))
            log "Ignoring file: $file"
            continue
        fi

        if [ -s "$output_file" ] && is_processed "$descriptor"; then
            skipped_files=$((skipped_files + 1))
            continue
        fi

        if [ -s "$output_file" ] && ! is_processed "$descriptor"; then
            skipped_files=$((skipped_files + 1))
            log "Output exists for ${file}; adding processed marker."
            mark_processed "$descriptor"
            continue
        fi

        if [ ! -s "$output_file" ] && is_processed "$descriptor"; then
            log "Processed marker exists but output missing/empty: $file"
        fi

        if [ "$SKIP_PREVIOUS_FAILURES" = true ] && is_failed "$descriptor"; then
            skipped_files=$((skipped_files + 1))
            previously_failed_count=$((previously_failed_count + 1))
            if [ "$VERBOSE_PREVIOUS_FAILURE_LOGS" = true ]; then
                log "Skipping previously failed file: $file"
            fi
            continue
        fi

        if ! is_stable_file "$file"; then
            skipped_files=$((skipped_files + 1))
            unstable_files=$((unstable_files + 1))
            continue
        fi

        if convert_file "$file" "$output_file"; then
            converted_files=$((converted_files + 1))
            mark_processed "$descriptor"
        else
            failed_count=$((failed_count + 1))
            mark_failed "$file" "$descriptor"
        fi
    done

    failed_total="$(count_failed_total)"
    log "Finished conversion scan. total=$total_files converted=$converted_files skipped=$skipped_files (already_failed=$previously_failed_count ignored=$ignored_files_count unstable=$unstable_files) failed_new=$failed_count failed_total=$failed_total"
fi
