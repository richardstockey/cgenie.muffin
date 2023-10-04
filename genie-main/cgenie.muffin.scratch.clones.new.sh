#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github user - assuming that genie-main sits in https://github.com/[user]/cgenie.muffin/trunk/genie-main
# input variable $2 number of times to clone
# should be run like: ./cgenie.muffin.scratch.clones.sh richardstockey 40
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.clones.sh

## Change log
# 20231004 - reorder so that checkouts come first then changing all the names comes next...
for clone in $(seq $2)
do
## Clean up
[ -d "/scratch/$USER/cgenie.muffin-$clone" ] && rm -r /scratch/$USER/cgenie.muffin-$clone

# git clone
git clone https://github.com/$1/cgenie.muffin/ /scratch/$USER/cgenie.muffin-$clone


# change names in cgenie.muffin-1
cd /scratch/$USER/cgenie.muffin-$clone
grep -l -r 'cgenie.muffin' | xargs sed -i "s/cgenie.muffin/cgenie.muffin-$clone/g"

cd ~/genie.install.stuff
./netcdf.libraries.install.new.sh $clone
# return home
cd /home/$USER/
# say we're done with that clone
echo "cgenie.muffin-$clone created"
done
