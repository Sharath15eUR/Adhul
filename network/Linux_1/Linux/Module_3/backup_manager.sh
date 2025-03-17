#!/bin/bash

# Checking correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

# Assigning arguments to variables
SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Creating backup directory if it does not exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory doesn't exist. Creating Backup directory $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR" || { echo "Error: Failed to create backup directory."; exit 1; }
fi

# 1 way to find files 
# mapfile -t FILES < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*$EXTENSION")


# Checking the files using Globing as stated
FILES=("$SOURCE_DIR"/*"$EXTENSION")

# Check if there are files to backup since the failure of globing doesnt result in empty array also to address null glob
if [ "${FILES[0]}" = "$SOURCE_DIR/*$EXTENSION" ]; then
    echo "No files with extension $EXTENSION found in $SOURCE_DIR."
    exit 1
fi

# Initialize backup count
BACKUP_COUNT=0
TOTAL_SIZE=0

# Perform backup
for FILE in "${FILES[@]}"; do
    BASENAME=$(basename "$FILE") # equals to awk -F/ '{print $NF}'
    DEST_FILE="$BACKUP_DIR/$BASENAME"
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
REPORT_FILE="$BACKUP_DIR/backup_report.log"
{
    echo "Backup Summary:"
    echo "Total files processed: $BACKUP_COUNT"
    echo "Total size of files backed up: $TOTAL_SIZE bytes"
    echo "Backup directory: $BACKUP_DIR"
} > "$REPORT_FILE"

echo "Backup completed. Report saved to $REPORT_FILE"

