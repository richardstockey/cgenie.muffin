#!/bin/bash -e
#
#####################################################################
### SCIPT TO RUN ./RUNMUFFIN.SH ON REDHAT HPC #######################
### WITH AUTOMATIC RESTARTS #########################################
#####################################################################

# designing self-restarting ensemble loops...
# begin with n (n<40) directories of cgenie jobs
# supply primary directory to runmuffin-basket.sh
# within that, have n (n<40) directories of cgenie jobs
# within those, have user-config files (same number for each directory in theory, might not matter)

# runmuffin-basket command should look like
# ./runmuffin-basket.sh [email@uni.ac.uk] [primary-directory] [model-years-per-job]

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

# 20230923
# adapting runmuffin-basket-scratch to run in scratch using multiple cgenie.muffin.clones

cd /scratch/rgs1e22/cgenie.muffins
muffins=( $(find . -maxdepth 2 -mmin +5 | grep 'genie-main') )

# loop over it
for i in ${muffins[@]}
do
    echo "we are in dirctory ${i:1}"
    cd /scratch/rgs1e22/cgenie.muffins${i:1}
    ls
done