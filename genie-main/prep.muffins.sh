#!/bin/bash

# Usage:
# ./prep.muffins.sh master_config user_config_dir user_config_base total_time chunk_length

set -e

# ------------- INPUT CHECKING -------------
if [ "$#" -lt 5 ]; then
  echo "Usage: $0 <master_config> <user_config_dir> <user_config_base> <total_time> <chunk_length>"
  exit 1
fi

master_config="$1"
user_config_dir="$2"
user_config_base="$3"
total_time="$4"
chunk_length="$5"

# Strip trailing slash if present
user_config_dir="${user_config_dir%/}"

# Ensure master config exists and is a file
if [ ! -f "$master_config" ]; then
  echo "❌ ERROR: Master config does not exist or is not a file: $master_config"
  exit 1
fi

# Ensure user_config_dir exists and is a directory
if [ ! -d "$user_config_dir" ]; then
  echo "Creating user_config_dir: $user_config_dir"
  mkdir -p "$user_config_dir"
fi

# ------------- CALCULATIONS -------------
n_chunks=$(( total_time / chunk_length ))
if (( total_time % chunk_length != 0 )); then
  echo "⚠️ Warning: total_time is not divisible by chunk_length. Last chunk may be shorter."
  (( n_chunks++ ))
fi

echo "Preparing $n_chunks chunk configs in: $user_config_dir/$user_config_base/"

chunk_output_dir="$user_config_dir/$user_config_base"
mkdir -p "$chunk_output_dir"

# ------------- SPLITTING LOOP -------------
for ((i=1; i<=n_chunks; i++)); do
  start_time=$(( (i - 1) * chunk_length ))
  end_time=$(( i * chunk_length > total_time ? total_time : i * chunk_length ))

  outfile="$chunk_output_dir/${i}.chunk"

  echo "Writing chunk $i: $start_time → $end_time kyr to $outfile"

  # Read all lines from original config
  mapfile -t CONFIG_LINES < "$master_config"
  > "$outfile"

  inserted=0

  for ((j=0; j<${#CONFIG_LINES[@]}; j++)); do
    line="${CONFIG_LINES[$j]}"

    # Remove any existing bg_par_misc_t_start line
    if [[ "$line" =~ ^[[:space:]]*bg_par_misc_t_start ]]; then
      continue
    fi

    echo "$line" >> "$outfile"

    # Detect END block (including *** END ***, etc.)
    if [[ "$line" =~ ^#.*\bEND\b ]] && [ "$inserted" -eq 0 ]; then
      echo "# --- START YEAR ---------------------------------------------   # added by prep.muffins.sh" >> "$outfile"
      echo "bg_par_misc_t_start = $start_time                               # added by prep.muffins.sh" >> "$outfile"
      echo "# Calculated as chunk $i of $n_chunks: $start_time → $end_time kyr" >> "$outfile"
      inserted=1
    fi
  done
done

echo "✅ Done: created $n_chunks chunked configs in: $chunk_output_dir"
