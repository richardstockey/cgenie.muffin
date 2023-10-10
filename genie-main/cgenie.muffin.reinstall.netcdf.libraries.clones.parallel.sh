#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 number of times to clone
# should be run like: ./cgenie.muffin.reinstall.netcdf.libraries.clones.parallel.sh 40
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.reinstall.netcdf.libraries.clones.sh
module load gcc/6.4.0
module load gnumake

# for all batch files we start with the same code here... 
printf "#!/bin/sh

#SBATCH --nodes=1                # Number of nodes requested
#SBATCH --ntasks-per-node=40     # Tasks per node
#SBATCH --time=1:00:00
#SBATCH --mail-user=r.g.stockey@soton.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=~/cgenie.jobs/reinstall.netcdf.libraries.clones.out

module load gcc/6.4.0
module load gnumake

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

cd ~/genie.install.stuff
" > ~/cgenie.jobs/reinstall.netcdf.libraries.clones.sbatch

for clone in $(seq $1)
do
printf "./netcdf.libraries.reinstall.sh $clone &> ~/cgenie.jobs/reinstall.netcdf.libraries.clones-${clone}.out &
" >> ~/cgenie.jobs/reinstall.netcdf.libraries.clones.sbatch

done

printf "
wait
" >> ~/cgenie.jobs/reinstall.netcdf.libraries.clones.sbatch
cd ~/cgenie.jobs
sbatch reinstall.netcdf.libraries.clones.sbatch