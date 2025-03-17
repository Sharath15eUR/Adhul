#!/bin/bash

# Ensure correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <Dest_directory> <file_extension>"
    exit 1
fi

# Assigning arguments to variables
SOURCE_DIR="$1"
Dest_dir="$2"
EXTENSION="$3"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Create backup directory if it does not exist
if [ ! -d "$Dest_dir" ]; then
    mkdir -p "$Dest_dir" || { echo "Error: Failed to create backup directory."; exit 1; }
fi

# Find files matching the extension
FILES=($SOURCE_DIR/*$EXTENSION)

# Check if there are files to backup
if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No files with extension $EXTENSION found in $SOURCE_DIR."
    exit 1
fi

# Initialize backup count
export BACKUP_COUNT=0
TOTAL_SIZE=0

# Perform backup
for FILE in "${FILES[@]}"; do
    BASENAME=$(basename "$FILE")
    DEST_FILE="$Dest_dir/$BASENAME"
    FILE_SIZE=$(stat -c%s "$FILE")
    echo "Backing up: $BASENAME ($FILE_SIZE bytes)"
    
    if [ -f "$DEST_FILE" ]; then
        if [ "$FILE" -nt "$DEST_FILE" ]; then
            cp "$FILE" "$DEST_FILE"
            echo "Updated: $BASENAME"
            ((BACKUP_COUNT++))
            TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
        else
            echo "Skipping: $BASENAME (Already up-to-date)"
        fi
    else
        cp "$FILE" "$DEST_FILE"
        echo "Copied: $BASENAME"
        ((BACKUP_COUNT++))
        TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
    fi

done

# Generate report
REPORT_FILE="$Dest_dir/backup_report.log"
echo "Backup Summary:" > "$REPORT_FILE"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size of files backed up: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup directory: $Dest_dir" >> "$REPORT_FILE"

echo "Backup completed. Report saved to $REPORT_FILE"
