#!/bin/bash -e
#
#####################################################################
### SCIPT TO RUN ./RUNMUFFIN.SH ON REDHAT HPC #######################
#####################################################################
module load gcc/6.4.0
module load gnumake

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

printf "#!/bin/sh

#SBATCH --nodes=1                # Number of nodes requested
#SBATCH --time=48:00:00
#SBATCH --output=runmuffin-to-go.out

module load gcc/6.4.0
module load gnumake

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

cd ~/cgenie.muffin/genie-main

make cleanall &> ~/cgenie_log/cleanall_trash.txt; 
./runmuffin.sh $1 $2 $3 $4 $5 &> ~/cgenie_log/cGEnIE.output_$(date '+%F_%H.%M').log
" > ~/cgenie.jobs/muffin-to-go.sbatch

sbatch ~/cgenie.jobs/muffin-to-go.sbatch
#rm ~/cgenie.jobs/muffin-to-go.sbatch
