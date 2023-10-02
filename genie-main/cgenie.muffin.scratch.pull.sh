#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github directory that was cloned as URL
# should be run like: ./cgenie.muffin.scratch.sh https://github.com/derpycode/cgenie.muffin.git 40
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.pull.sh


find . -mindepth 1 -maxdepth 1 -type d | wc -l
cd '/scratch/$USER/cgenie.muffins'
for clone in $(seq $(find . -mindepth 1 -maxdepth 1 -type d | wc -l))
do
[ -d "/scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone" ] && git pull $1 /scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone
echo "cgenie.muffin.clone.$clone updated"
done
