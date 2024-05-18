#!/bin/bash

# Set the directory to scan - default is the current directory
base_dir="${1:-.}"

# Output file to store the results
output_file="gif_loop_fix_report.csv"

# Function to fix loop setting and record changes
fix_gif_loops() {
    local filepath="$1"
    # Use gifsicle to get current loop info
    local current_info=$(gifsicle --info "$filepath")
    local current_loop=$(echo "$current_info" | grep 'loop count' | sed -n 's/.*loop count \([0-9]\+\).*/\1/p')
    local size_before=$(stat -c %s "$filepath")

    # Determine if GIF is already set to infinite looping
    if echo "$current_info" | grep -q 'loop forever'; then
        current_loop="Infinite loop"
    elif [ -z "$current_loop" ]; then
        current_loop="No explicit loop count"
    else
        current_loop="Loops $current_loop times"
    fi

    # Set to loop infinitely
    gifsicle --batch --loopcount=0 "$filepath"

    # Verify changes
    local new_info=$(gifsicle --info "$filepath")
    local new_loop=$(echo "$new_info" | grep -q 'loop forever' && echo "Infinite loop" || echo "Failed to set infinite, verify manually")
    local size_after=$(stat -c %s "$filepath")

    # Output before and after in CSV format if changed
    echo "\"$(basename "$filepath")\",\"$filepath\",\"$current_loop\",\"$new_loop\",\"$size_before\",\"$size_after\""
}

# Start the scan and output results
echo "Scanning directory: $base_dir"
echo "\"Filename\",\"Path\",\"Before Loop\",\"After Loop\",\"Size Before (bytes)\",\"Size After (bytes)\"" > "$output_file"

# Find all GIF files and process them
find "$base_dir" -type f -name "*.gif" -print0 | while IFS= read -r -d $'\0' file; do
    fix_report=$(fix_gif_loops "$file")
    echo "$fix_report" >> "$output_file"
done

echo "Completed. Loop fix report saved to $output_file."

