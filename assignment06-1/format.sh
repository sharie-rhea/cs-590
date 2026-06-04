#!/bin/bash

INPUT_FILE="Module_Six_Nut_Descs_Original.csv"
OUTPUT_FILE="Module_Six_Nut_Descs.csv"

# use sed to swap MM/DD/YYYY to YYYY-MM-DD using regex
# this regex looks for 1-2 digits / 1-2 digits / 4 digits
sed -E 's/([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/\3-\1-\2/g' "$INPUT_FILE" > "$OUTPUT_FILE"

INPUT_FILE="Module_Six_Nut_Vals_Original.csv"
OUTPUT_FILE="Module_Six_Nut_Vals.csv"

sed -E 's/([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/\3-\1-\2/g' "$INPUT_FILE" > "$OUTPUT_FILE"
