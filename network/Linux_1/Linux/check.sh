
#!/bin/bash

# Check no of arguments

if [ "$#" -ne 3 ]; then
    echo "Input Format: $0 <source_dir path><backup_dir path><file_extensions to be backed up>"
    exit 1
fi

Source_dir="$1"
Dest_dir="$2"
Extension="$3"

if [ -d "$Source_dir" ]; then
    
    echo "Source directory exist."
    echo "Check for files with given extension in the source directory 
     "
    if ! [[ -z "$(ls -A "$Source_dir")" ]]; then
		echo "Files or subdirectories exist"
		echo ""
	else
		echo "No files exist in the given source directory" >&2
		exit 1
	fi
else
	echo "Source directory does not exist." >&2
    exit 1

fi

if [ -d "$Dest_dir" ]; then
    
    echo "Destination directory exist."
    
else
	echo "Destination directory does not exist." >&2
    echo "Creating directory"
    mkdir -p "$Dest_dir" || {echo "Attempt to create backup directory provided failed...." >&2; exit 1;}
fi
FILES=($Source_dir/*$Extension)

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No files with extension $extension found in $Source_dir ."
    exit 1
fi

# Initialize backup count
export BACKUP_COUNT=0
TOTAL_SIZE=0

# Perform backup
for FILE in "${FILES[@]}"; do
    Basename=$(basename "$FILE")
    Dest_file="$Dest_dir/$Basename"
    File_size=$(stat -c%s "$FILE")
    echo "Backing up: $Basename ($File_size bytes)"
    
    if [ -f "$Dest_file" ]; then
        if [ "$FILE" -nt "$Dest_file" ]; then
            cp "$FILE" "$Dest_file"
            echo "Updated: $Basename"
            ((BACKUP_COUNT++))
            TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
        else
            echo "Skipping: $Basename (Already up-to-date)"
        fi
    else
        cp "$FILE" "$Dest_file"
        echo "Copied: $Basename"
        ((BACKUP_COUNT++))
        TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
    fi

done
