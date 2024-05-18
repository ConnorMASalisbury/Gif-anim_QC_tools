#!/bin/bash

# Set the directory to scan - default is the current directory
base_dir="${1:-.}"

# Output file to store the results
output_file="gif_loop_info.csv"

# Function to extract loop information and file size from a GIF
get_gif_info() {
    local filepath="$1"
    # Use gifsicle to extract detailed info about the GIF
    local info=$(gifsicle --info "$filepath")

    # Get file size in bytes
    local size=$(stat -c %s "$filepath")

    # Check if the GIF is set to loop infinitely
    if echo "$info" | grep -q 'loop forever'; then
        loop_desc="GOOD: 0 set to Infinite loop"
    elif echo "$info" | grep -q 'loop count'; then
        # Extract the number of loops
        local loop=$(echo "$info" | grep 'loop count' | sed -n 's/.*loop count \([0-9]\+\).*/\1/p')
        loop_desc="Loops $loop times"
    else
        loop_desc="Not Good: does not loop infinitely"
    fi

    # Output in CSV format: filename, path, loop description, size
    echo "\"$(basename "$filepath")\",\"$filepath\",\"$loop_desc\",\"$size\""
}

# Start the scan and output results
echo "Scanning directory: $base_dir"
echo "\"Filename\",\"Path\",\"Loop Description\",\"File Size (bytes)\"" > "$output_file"

# Find all GIF files and process them
find "$base_dir" -type f -name "*.gif" -print0 | while IFS= read -r -d $'\0' file; do
    gif_info=$(get_gif_info "$file")
    echo "$gif_info" >> "$output_file"
done

echo "Completed. GIF info saved to $output_file."

