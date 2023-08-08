#!/bin/bash

# To use this file, make sure your WM produces a stream/file of keycodes, one keycode per line.

input_file_content=$(xkbcomp -xkb $DISPLAY - | grep "> =" | grep -v "alias" |  sed 's/\(.*\) = \(.*\);/\1 \2/')
# if you want to specify a filename with keycodes, use
# reference_file_content=$(cat "$1")

# if you want to pipe it, use:
reference_file_content=$(cat)

usedKeys=$(awk -v input_file_content="$input_file_content" -v reference_file_content="$reference_file_content" '
    BEGIN {
        split(input_file_content, input_lines, "\n")
        split(reference_file_content, reference_lines, "\n")
        
        for (i in input_lines) {
            split(input_lines[i], input_fields)
            a[input_fields[2]] = input_fields[1]
        }
        
        for (i in reference_lines) {
            if (reference_lines[i] in a) {
                print a[reference_lines[i]]
            }
        }
    }
') 

# Convert to array
usedKeys_arr=($usedKeys)
pscontent=$(xkbprint "${DISPLAY}" -)

psoutput=""

while IFS= read -r line; do
    for search_term in "${usedKeys_arr[@]}"; do
        if [[ "$line" == *" % $search_term" ]]; then
            # Additional line for '$search_term'
	    output+="1 0 0 setrgbcolor\n" # paint red!
        fi
    done
    output+="$line\n"

    # lazy way of doing "before and after" modification
    for search_term in "${usedKeys_arr[@]}"; do
        if [[ "$line" == *" % $search_term" ]]; then
            # Additional line for '$search_term'
	    output+="0 0 0 setrgbcolor\n" # remove paint from brush
        fi
    done
done <<< "$pscontent"

# If you want to inspect the generated postscript:
# echo -e "$output"
echo -e "$output" | ps2pdf - # > result.pdf



