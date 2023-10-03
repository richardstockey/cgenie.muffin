#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github directory that was cloned as URL
# should be run like: ./cgenie.muffin.scratch.pull.sh
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.pull.sh


cd /scratch/$USER/cgenie.muffin
echo "found $(find . -mindepth 1 -maxdepth 1 -type d -name "genie-main-*" | wc -l) genie-main clones to update"
for clone in $(seq $(find . -mindepth 1 -maxdepth 1 -type d -name "genie-main-*" | wc -l))
do
[ -d "/scratch/$USER/cgenie.muffins/cgenie.muffin/genie-main-$clone" ] && svn update genie-main-$clone
echo "genie-main clone $clone updated"
done
