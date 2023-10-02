#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github directory to clone as URL
# input variable $2 number of times to clone
# should be run like: ./cgenie.muffin.scratch.sh https://github.com/derpycode/cgenie.muffin.git 40
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.clones.sh

for clone in $(seq $2)
do
[ -d "/scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone" ] && rm -r /scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone
git clone $1 /scratch/$USER/cgenie.muffins/cgenie.muffin.clone.$clone
echo "cgenie.muffin.clone.$clone created"
done
