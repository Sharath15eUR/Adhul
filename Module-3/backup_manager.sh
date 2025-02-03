#!/bin/bash

# Validate the number of arguments passed to the script
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_dir> <backup_dir> <file_extension>"
    exit 1
fi

# Assign arguments to variables
SOURCE="$1"
BACKUP="$2"
EXT="$3"

# Ensure the source directory exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: The source directory '$SOURCE' does not exist."
    exit 1
fi

# Create the backup directory if it doesn't exist
if [ ! -d "$BACKUP" ]; then
    mkdir -p "$BACKUP" || { echo "Error: Unable to create backup directory."; exit 1; }
fi

# Enable globbing, but prevent errors if no matching files are found
shopt -s nullglob
FILES=("$SOURCE"/*"$EXT")

# Check if there are any files to back up
if [ ${#FILES[@]} -eq 0 ]; then
    echo "No files with extension '$EXT' found in '$SOURCE'."
    exit 0
fi

# Initialize counters
BACKED_UP=0
TOTAL_SIZE=0

# Display the list of files that will be backed up
echo "Files identified for backup:"
for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    filesize=$(stat -c %s "$file")
    echo "  $filename - $filesize bytes"
done

# Start the backup process
for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    destination="$BACKUP/$filename"

    # Check if file already exists in the backup folder
    if [ -e "$destination" ]; then
        # Compare timestamps to decide whether to update the backup
        if [ "$file" -nt "$destination" ]; then
            cp "$file" "$destination"
            echo "Updated: $filename"
        else
            echo "Skipped (up-to-date): $filename"
            continue
        fi
    else
        # Copy the file if it doesn't exist in the backup
        cp "$file" "$destination"
        echo "Backed up: $filename"
    fi

    # Update the backup statistics
    BACKED_UP=$((BACKED_UP + 1))
    TOTAL_SIZE=$((TOTAL_SIZE + $(stat -c %s "$file")))
done

# Generate a summary report
REPORT_PATH="$BACKUP/backup_summary.log"
{
    echo "Backup Summary"
    echo "=============="
    echo "Files backed up: $BACKED_UP"
    echo "Total backup size: $TOTAL_SIZE bytes"
    echo "Backup location: $BACKUP"
    echo "Backup completed at: $(date "+%Y-%m-%d %H:%M:%S")"
} > "$REPORT_PATH"

# Notify the user about the completion
echo "Backup process complete. Summary report saved to: $REPORT_PATH"
