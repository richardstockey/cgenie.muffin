#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github directory that was cloned as URL
# should be run like: ./cgenie.muffin.scratch.pull.new.sh
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.pull.new.sh
module load gcc/6.4.0
module load gnumake

cd /scratch/$USER
echo "found $(find . -mindepth 1 -maxdepth 1 -type d -name "cgenie.muffin-*" | wc -l) cgenie.muffin clones to update"
for clone in $(seq $(find . -mindepth 1 -maxdepth 1 -type d -name "cgenie.muffin-*" | wc -l))
do
[ -d "/scratch/$USER/cgenie.muffin-$clone" ] && cd "/scratch/$USER/cgenie.muffin-$clone" && git pull
echo "cgenie.muffin clone $clone updated"
cd /scratch/$USER
done
