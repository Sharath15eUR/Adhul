#!/bin/bash

# Check if exactly one argument is provided (input file)
if [ "$#" -ne 1 ]; then
    echo "Error: You must specify the input file."
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Assign the argument to a variable
INPUT_FILE="$1"

# Validate if the input file exists and is a regular file
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: The specified file '$INPUT_FILE' does not exist or is not a regular file."
    exit 1
fi

# Define the output file name
OUTPUT_FILE="extracted_data.txt"

# Clear the output file if it exists, or create it
: > "$OUTPUT_FILE"

# Define the search pattern for matching lines
SEARCH_PATTERN="frame.time|wlan.fc.type|wlan.fc.subtype"

# Extract matching lines from the input file and save them to the output file
grep -E -w "$SEARCH_PATTERN" "$INPUT_FILE" > "$OUTPUT_FILE"

# Count how many lines matched the pattern
MATCHED_LINES=$(grep -c -E -w "$SEARCH_PATTERN" "$INPUT_FILE")

# Count the total number of lines in the input file
TOTAL_LINES=$(wc -l < "$INPUT_FILE")

# Display results to the terminal
echo "$MATCHED_LINES lines matched the search criteria."
echo "Results have been saved to: $OUTPUT_FILE"
echo "Total number of lines in the input file: $TOTAL_LINES"

# Save a summary report to the output file
{
    echo "Total lines in the input file: $TOTAL_LINES"
    echo "Lines matching the search pattern: $MATCHED_LINES"
    echo "The filtered data has been saved to: $OUTPUT_FILE"
} >> "$OUTPUT_FILE"
