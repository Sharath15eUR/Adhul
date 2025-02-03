#!/bin/bash

# Log file to store errors
LOG_FILE="error_log.txt"

# Function to search files recursively in a given directory
search_in_directory() {
    local target_dir="$1"
    local search_term="$2"

    for current_file in "$target_dir"/*; do
        if [ -d "$current_file" ]; then
            search_in_directory "$current_file" "$search_term"  # Recursive call for subdirectory
        elif [ -f "$current_file" ]; then
            grep -l "$search_term" "$current_file" 2>/dev/null && echo "Match found in: $current_file"
        fi
    done
}

# Function to display the help menu
display_help() {
    cat << HELP
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Recursively search in the specified directory.
  -k <keyword>     Search for the specified keyword.
  -f <file>        Search for the keyword in a specific file.
  --help           Display this help menu.

Example:
  $0 -d logs -k error
  $0 -f myscript.sh -k TODO
HELP
}

# Validate the keyword input
validate_keyword() {
    local search_string="$1"
    if [[ -z "$search_string" || ! "$search_string" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid or empty keyword provided." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Parse command-line arguments
while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) search_directory="$OPTARG" ;;
        k) search_keyword="$OPTARG" ;;
        f) search_file="$OPTARG" ;;
        -) case "$OPTARG" in
               help) display_help; exit 0 ;;
               *) echo "Unknown option: --$OPTARG" | tee -a "$LOG_FILE"; exit 1 ;;
           esac ;;
        ?) echo "Invalid option: -$OPTARG" | tee -a "$LOG_FILE"; exit 1 ;;
    esac
done

# Ensure that either -d or -f is provided
if [[ -z "$search_directory" && -z "$search_file" ]]; then
    echo "Error: Please specify either -d or -f." | tee -a "$LOG_FILE"
    exit 1
fi

# Validate the search keyword
validate_keyword "$search_keyword"

# Perform the search in the specified directory (recursive)
if [[ -n "$search_directory" ]]; then
    if [[ -d "$search_directory" ]]; then
        search_in_directory "$search_directory" "$search_keyword"
    else
        echo "Directory '$search_directory' not found." | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# Perform the search in a specific file
if [[ -n "$search_file" ]]; then
    if [[ -f "$search_file" ]]; then
        grep "$search_keyword" "$search_file" && echo "Keyword found in $search_file"
    else
        echo "File '$search_file' not found." | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# Return the script's exit status
exit_code=$?
echo "Script finished with exit code: $exit_code"
