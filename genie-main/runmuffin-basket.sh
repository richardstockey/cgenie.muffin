#!/bin/bash -e
#
#####################################################################
### SCIPT TO RUN ./RUNMUFFIN.SH ON REDHAT HPC #######################
### WITH AUTOMATIC RESTARTS #########################################
#####################################################################

# designing self-restarting ensemble loops...
# begin with n (n<40) directories of cgenie jobs
# supply primary directory to runmuffin-basket-test.sh
# within that, have n (n<40) directories of cgenie jobs
# within those, have user-config files (same number for each directory in theory, might not matter)

# runmuffin-basket-test command should look like
# ./runmuffin-basket-test.sh [email@uni.ac.uk] [primary-directory] [model-years-per-job]

# what shell script will need to do
# - load dependencies
# - read contents of primary directory
# – use this to establish names of recurring jobs (directory called in runmuffin)
# – [all user-configs will have the same name as the recurring jobs, but with a number at the end]
# – identify first job for each of n directories as job in directory with appendix `-1`
# – generate .sbatch file with all initial n jobs in it
# – submit .sbatch file to slurm
# – store job_id of job
# – [this job will be used to set the dependency for the next job with the restarts]
# – then need to begin a loop of restarts. 
# - [we will use the slurm dependency `sbatch --dependency=afterok:$job_id job2.sh`]

module load gcc/6.4.0
module load gnumake

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

short_name=$(echo $2 | sed 's:.*/::')
iteration="1"

# for all batch files we start with the same code here... 
printf "#!/bin/sh

#SBATCH --nodes=1                # Number of nodes requested
#SBATCH --ntasks-per-node=40     # Tasks per node
#SBATCH --time=48:00:00
#SBATCH --mail-user=$1
#SBATCH --mail-type=BEGIN,END,FAIL

module load gcc/6.4.0
module load gnumake

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

cd ~/cgenie.muffin/genie-main
" > ~/cgenie.jobs/muffin-basket-$short_name-$iteration.sbatch

i=0
for line in $(ls ~/cgenie.muffin/genie-userconfigs/$2)
do
# for each line, we get an experiment with multiple restarts
# experiment naming should be set up such that:
# the base-config should be the text before a certain flag (e.g. first "-") in the directory name (line from our ls call on primary directory)
# the directory name will of course be the [secondary] directory now named $line
# the user-config should be the full secondary directory name with "-1" afterwards for the first job. Restarts should follow sequentially as "-2", "-3", etc.
# this will make life dramatically easier as can just set job number in loop. 
# all runs should be the same duration at this stage.
# could eventually update this in the future for mixed plasim runs, gemlite runs, etc.

# set seconds to sleep before running each cGENIE job so that they don't interfere with each other. The 5 represents 5 mins. 
secs=$((i*10*60))
# need to adapt the printf command to read in from ls
printf "(cd /scratch/$USER/cgenie.muffin-$i/genie-main; make cleanall; LD_LIBRARY_PATH=/scratch/rgs1e22/cgenie.muffin-$i/netcdf_libs/lib; export LD_LIBRARY_PATH; ./runmuffin.sh $line $2/$line ${line}-${iteration}.config $3 &> ~/cgenie_log/muffin-basket-$(date '+%F_%H.%M')-${line}-${iteration}.log) &
"  >> ~/cgenie.jobs/muffin-basket-$short_name-$iteration.sbatch
i=$((i+1))
done 

# take the final ampersand away!
truncate -s -2 ~/cgenie.jobs/muffin-basket-$short_name-$iteration.sbatch

sbatch ~/cgenie.jobs/muffin-basket-$short_name-$iteration.sbatch

#job_id=`grep -Eo '[0-9\.]+' ~/cgenie.jobs/muffin-basket-test-job.txt`
#echo $job_id
