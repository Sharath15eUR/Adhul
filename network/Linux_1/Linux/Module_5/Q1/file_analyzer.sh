#!/bin/bash

# Error log file
ERROR_LOG="errors.log"

# Function to log errors
echo_error() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG"
}

# Recursive function to search for a keyword in files within a directory
search_directory() {
    local dir="$1"
    local keyword="$2"
    
    if [[ ! -d "$dir" ]]; then
        echo_error "Invalid directory: $dir"
        return
    fi
    
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            search_directory "$file" "$keyword"
        elif [[ -f "$file" ]]; then
            grep -Hn "$keyword" "$file" 2>/dev/null
        fi
    done
}

# Function to search for a keyword in a file
search_file() {
    local file="$1"
    local keyword="$2"
    
    if [[ ! -f "$file" ]]; then
        echo_error "File does not exist: $file"
        return
    fi
    
    grep -Hn "$keyword" "$file" 2>/dev/null
}

# Display help menu using a here document
show_help() {
    cat << EOF
Usage: $0 [options]
Options:
  -d <directory>  Search for a keyword recursively in a directory.
  -f <file>       Search for a keyword in a specific file.
  -k <keyword>    Keyword to search for.
  --help          Display this help menu.

Example:
  $0 -d logs -k error
  $0 -f script.sh -k echo
EOF
}

# Validate inputs using regular expressions
validate_input() {
    local keyword="$1"
    if [[ -z "$keyword" ]]; then
        echo_error "Keyword cannot be empty."
        exit 1
    fi
}


if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi


# Parse command-line arguments using getopts
while getopts ":d:f:k:h" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        f) file="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        h) show_help; exit 0 ;;
        ?) echo_error "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done


# Ensure at least one valid option is provided
if [[ -z "$directory" && -z "$file" ]]; then
    echo_error "You must specify either -d <directory> or -f <file>."
    exit 1
fi

# Validate keyword
validate_input "$keyword"

# Execute the appropriate function
if [[ -n "$directory" ]]; then
    search_directory "$directory" "$keyword"
elif [[ -n "$file" ]]; then
    search_file "$file" "$keyword"
fi

exit 0
