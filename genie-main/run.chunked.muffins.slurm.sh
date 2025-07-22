#!/bin/bash
# run.chunked.muffins.slurm.sh

# Usage:
# ./run.chunked.muffins.slurm.sh <your@email.com> <base_exp_name> <user_config_dir> <chunk_dir_name> <base_user_config_name> <final_len> <chunk_len> [optional_restart]

set -e

# Input arguments
EMAIL="$1"
BASE_EXP_NAME="$2"
USER_CONFIG_SUB_DIR="$3"
CHUNK_DIR_NAME="$4"
USER_CONFIG_BASENAME="$5"
FINAL_LEN="$6"
CHUNK_LEN="$7"
FIRST_RESTART="${8:-}"  # optional

# Derived paths
USER_CONFIG_BASE_PATH="$HOME/cgenie.muffin/genie-userconfigs/$USER_CONFIG_SUB_DIR"
CHUNK_DIR="$USER_CONFIG_BASE_PATH/$CHUNK_DIR_NAME"
CHUNK_DIR_SUB_PATH="$USER_CONFIG_SUB_DIR/$CHUNK_DIR_NAME"
NUM_CHUNKS=$(( (FINAL_LEN + CHUNK_LEN - 1) / CHUNK_LEN ))

echo "🌊 Running $NUM_CHUNKS chunked cGENIE experiments via SLURM"

# Start submitting jobs
PREV_JOBID=""
for CHUNK_INDEX in $(seq 1 "$NUM_CHUNKS"); do
    EXP_NAME="${BASE_EXP_NAME}.${CHUNK_INDEX}"
    USER_CONFIG_CHUNK="${USER_CONFIG_BASENAME}.${CHUNK_INDEX}.chunk"
    RUNTIME=$CHUNK_LEN

    # Adjust runtime for last chunk if needed
    if (( CHUNK_INDEX == NUM_CHUNKS )); then
        REMAINING=$((FINAL_LEN - (CHUNK_LEN * (NUM_CHUNKS - 1)) ))
        RUNTIME=$REMAINING
    fi

    # Restart logic
    if (( CHUNK_INDEX == 1 )); then
        RESTART_ARG="$FIRST_RESTART"
    else
        PREV_EXP="${USER_CONFIG_BASENAME}.$((CHUNK_INDEX - 1)).chunk"
        RESTART_ARG="$PREV_EXP"
    fi

    # Create a wrapper sbatch script that uses job dependencies
    SBATCH_SCRIPT="$HOME/cgenie.jobs/muffin-to-go-${EXP_NAME}.sbatch"
    LOG_FILE="$HOME/cgenie_log/cGENIE.output_${EXP_NAME}_$(date '+%F_%H.%M').log"

    # Generate the sbatch script
{
  echo "#!/bin/bash"
  echo "#SBATCH --nodes=1"
  echo "#SBATCH --time=48:00:00"
  echo "#SBATCH --job-name=$EXP_NAME"
  echo "#SBATCH --mail-user=$EMAIL"
  echo "#SBATCH --mail-type=BEGIN,END,FAIL"
  echo "#SBATCH --output=$LOG_FILE"
  echo
  echo "module load gcc/6.4.0"
  echo "module load gnumake"
  echo "export LD_LIBRARY_PATH=\$HOME/lib"
  echo "cd \$HOME/cgenie.muffin/genie-main"
  echo "make cleanall &> /dev/null"
  if [ -n "$RESTART_ARG" ]; then
    echo "./runmuffin.sh $BASE_EXP_NAME $CHUNK_DIR_SUB_PATH $USER_CONFIG_CHUNK $RUNTIME $RESTART_ARG"
  else
    echo "./runmuffin.sh $BASE_EXP_NAME $CHUNK_DIR_SUB_PATH $USER_CONFIG_CHUNK $RUNTIME"
  fi
} > "$SBATCH_SCRIPT"

    # Submit with optional dependency
    CMD="sbatch"
    if [ -n "$PREV_JOBID" ]; then
        CMD="$CMD --dependency=afterok:$PREV_JOBID"
    fi

    echo "🚀 Submitting $EXP_NAME (restart from: $RESTART_ARG)"
    JOB_OUTPUT=$($CMD "$SBATCH_SCRIPT")
    echo "$JOB_OUTPUT"

    # Capture job ID
    PREV_JOBID=$(echo "$JOB_OUTPUT" | awk '{print $4}')
done
