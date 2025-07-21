#!/bin/bash

# === Parse arguments or prompt ===

if [ $# -lt 6 ]; then
  read -p "Base config name (#1): " base_config
  read -p "User config directory (#2): " user_config_dir
  read -p "User config filename (#3): " user_config_file
  read -p "Total run length in model years (#4): " total_years
  read -p "Output subdirectory name (#5): " output_subdir
  read -p "Chunk length in model years (#6): " chunk_length
else
  base_config=$1
  user_config_dir=$2
  user_config_file=$3
  total_years=$4
  output_subdir=$5
  chunk_length=$6
fi

# === Validate input config file ===

input_file="${user_config_dir}/${user_config_file}"

if [ ! -e "$input_file" ]; then
  echo "❌ ERROR: Input file does not exist: $input_file"
  exit 1
elif [ -d "$input_file" ]; then
  echo "❌ ERROR: Input path is a directory, not a file: $input_file"
  exit 1
fi

# === Prepare output directory ===

output_dir="${user_config_dir}/${output_subdir}"
mkdir -p "$output_dir"

# === Extract start year (or default to 0) ===

initial_start=$(grep -E '^bg_par_misc_t_start=' "$input_file" | cut -d= -f2 | tr -d '[:space:]')
if [ -z "$initial_start" ]; then
  initial_start=0
fi

# === Number of chunks ===

num_chunks=$(( (total_years + chunk_length - 1) / chunk_length ))

echo "Preparing $num_chunks chunks from: $input_file"
echo "Output will be written to: $output_dir"
echo "Initial model year: $initial_start, chunk length: $chunk_length"

# === Loop to generate chunked configs ===

for (( i=1; i<=num_chunks; i++ )); do
  start_year=$(( initial_start + (i - 1) * chunk_length ))
  chunk_file="${output_dir}/${user_config_file}.${i}.chunk"

  awk -v sy="$start_year" -v i="$i" -v n="$num_chunks" -v cl="$chunk_length" '
    BEGIN {
      insert_block = "# --- START YEAR  ---------------------------------------------   # added by prep.muffins.sh\n"
      insert_block = insert_block "bg_par_misc_t_start=" sy "                                         # added by prep.muffins.sh\n"
      insert_block = insert_block "# This is chunk " i " of " n ". Start year = " sy ". Chunk length = " cl "   # added by prep.muffins.sh"
    }
    # Remove any existing bg_par_misc_t_start line
    /^bg_par_misc_t_start=/ { next }
    # Insert before the END marker
    /^# *--- *END/ {
      print insert_block
    }
    { print }
  ' "$input_file" > "$chunk_file"

  echo "  ✅ Created chunk $i → $chunk_file"
done

echo "🎉 All $num_chunks chunked configs written to: $output_dir"
