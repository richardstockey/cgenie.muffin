#!/bin/bash
# prep.muffins.sh
# Splits a user config into multiple chunks with incremental start years.
# For use with cGENIE SLURM runs or long experiments.
#
# Usage:
# ./prep.muffins.sh <base_exp_name> <user_config_dir> <base_user_config_filename> <final_len> <final_exp_name> <chunk_len>

set -e

# Get arguments
BASE_EXP_NAME="$1"
USER_CONFIG_SUB_DIR="$2"
USER_CONFIG_BASENAME="$3"
FINAL_LEN="$4"
CHUNK_DIR_NAME="$5"
CHUNK_LEN="$6"

if [ -z "$USER_CONFIG_BASENAME" ] || [ -z "$USER_CONFIG_SUB_DIR" ]; then
  echo "❌ ERROR: Missing arguments. Please provide at least <base_user_config_filename> and <user_config_dir>."
  exit 1
fi

USER_CONFIG_DIR="$HOME/cgenie.muffin/genie-userconfigs/$USER_CONFIG_SUB_DIR"

# Full path to user config (with or without .config)
USER_CONFIG_PATH="$USER_CONFIG_DIR/$USER_CONFIG_BASENAME"
if [ ! -f "$USER_CONFIG_PATH" ]; then
  if [ -f "${USER_CONFIG_PATH}.config" ]; then
    USER_CONFIG_PATH="${USER_CONFIG_PATH}.config"
  else
    echo "❌ ERROR: User config file not found: $USER_CONFIG_PATH"
    exit 1
  fi
fi

# Output chunks directory (inside user_config_dir, named after user config file)
CHUNKS_DIR="$USER_CONFIG_DIR/$CHUNK_DIR_NAME"
mkdir -p "$CHUNKS_DIR"

# Read full config into array
CONFIG_LINES=()
while IFS= read -r line; do
  CONFIG_LINES+=("$line")
done < "$USER_CONFIG_PATH"

# Find insertion point (line containing "# --- END ---" or similar)
END_INDEX=-1
for i in "${!CONFIG_LINES[@]}"; do
if [[ "${CONFIG_LINES[$i]}" =~ ^[[:space:]]*#.*END ]]; then
    END_INDEX="$i"
    break
  fi
done

if [ "$END_INDEX" -eq -1 ]; then
  echo "❌ ERROR: Could not find '# --- END ---' in config file."
  exit 1
fi

# Remove any existing bg_par_misc_t_start lines
CONFIG_LINES=( "${CONFIG_LINES[@]/bg_par_misc_t_start*/}" )

# Total run length
TOTAL_LEN=$((FINAL_LEN))
CHUNK_LEN_INT=$((CHUNK_LEN))
NUM_CHUNKS=$((TOTAL_LEN / CHUNK_LEN_INT))
if (( TOTAL_LEN % CHUNK_LEN_INT != 0 )); then
  NUM_CHUNKS=$((NUM_CHUNKS + 1))
fi

START_YEAR=0
for CHUNK_INDEX in $(seq 1 "$NUM_CHUNKS"); do
  THIS_LEN=$CHUNK_LEN_INT
  if (( CHUNK_INDEX == NUM_CHUNKS )); then
    REMAINING=$((TOTAL_LEN - (CHUNK_LEN_INT * (NUM_CHUNKS - 1))))
    THIS_LEN=$REMAINING
  fi

  CHUNK_EXP_NAME="${CHUNK_DIR_NAME}.${CHUNK_INDEX}.chunk"
  CHUNK_FILE="$CHUNKS_DIR/$CHUNK_EXP_NAME"

  {
    for ((i=0; i<END_INDEX; i++)); do
      echo "${CONFIG_LINES[$i]}"
    done

    echo "# --- START YEAR ---------------------------------------------  # added by prep.muffins.sh"
    echo "bg_par_misc_t_start = $START_YEAR                               # added by prep.muffins.sh"

    for ((i=END_INDEX; i<${#CONFIG_LINES[@]}; i++)); do
      echo "${CONFIG_LINES[$i]}"
    done

    echo "# Run chunk $CHUNK_INDEX of $NUM_CHUNKS; duration = $THIS_LEN, start = $START_YEAR  # added by prep.muffins.sh"
  } > "$CHUNK_FILE"

  echo "✅ Wrote chunk: $CHUNK_FILE (duration: $THIS_LEN, start year: $START_YEAR)"

  START_YEAR=$((START_YEAR + THIS_LEN))
done
