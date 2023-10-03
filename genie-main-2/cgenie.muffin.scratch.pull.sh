#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github directory that was cloned as URL
# should be run like: ./cgenie.muffin.scratch.pull.sh
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.pull.sh


cd /scratch/$USER/cgenie.muffins
echo "found $(find . -mindepth 1 -maxdepth 1 -type d | wc -l) cgenie.muffin.clones to update"
for clone in $(seq $(find . -mindepth 1 -maxdepth 1 -type d | wc -l))
do
[ -d "/scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone" ] && cd /scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone && git pull && cd /scratch/$USER/cgenie.muffins 
echo "cgenie.muffin.clone.$clone updated"
done
