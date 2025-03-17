#!/bin/bash

# Check for the input arument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi
# Create or clear the output.txt file
# > output.txt
> output1.txt 

# Process the entire input file line by line
# while read -r line; do
head -n 3000 "$1" | while read -r line; do
    # Match lines containing frame.time, wlan.fc.type, or wlan.fc.subtype
    echo "$line" | sed -E 's/"(frame\.time|wlan\.fc\.type|wlan\.fc\.subtype)": "(.+)"/\1": "\2"/' | while read -r param value; do
        # Write the output in the desired format
        echo "$param: $value" >> output1.txt # >> output.txt
    done
done 
