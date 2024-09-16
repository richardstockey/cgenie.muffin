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
[ -d "/scratch/$USER/cgenie.muffin/genie-main-$clone" ] && rm -r /scratch/$USER/cgenie.muffin/genie-main-$clone
[ -d "/scratch/$USER/cgenie.muffin/genie-lib-$clone" ] && rm -r /scratch/$USER/cgenie.muffin/genie-lib-$clone
[ -d "/scratch/$USER/cgenie.muffin/genie-plasim-$clone" ] && rm -r /scratch/$USER/cgenie.muffin/genie-plasim-$clone

# svn checkouts
svn checkout https://github.com/$1/cgenie.muffin/trunk/genie-main /scratch/$USER/cgenie.muffin/genie-main-$clone
svn checkout https://github.com/$1/cgenie.muffin/trunk/genie-lib /scratch/$USER/cgenie.muffin/genie-lib-$clone
svn checkout https://github.com/$1/cgenie.muffin/trunk/genie-plasim /scratch/$USER/cgenie.muffin/genie-plasim-$clone

# change names in genie-main-1
cd /scratch/$USER/cgenie.muffin/genie-main-$clone
grep -l -r 'genie-main' | xargs sed -i "s/genie-main/genie-main-$clone/g"
grep -l -r 'genie-lib' | xargs sed -i "s/genie-lib/genie-lib-$clone/g"
grep -l -r 'genie-plasim' | xargs sed -i "s/genie-plasim/genie-plasim-$clone/g"
# change names in genie-lib-1
cd /scratch/$USER/cgenie.muffin/genie-lib-$clone
grep -l -r 'genie-main' | xargs sed -i "s/genie-main/genie-main-$clone/g"
grep -l -r 'genie-lib' | xargs sed -i "s/genie-lib/genie-lib-$clone/g"
# grep -l -r 'genie-plasim' | xargs sed -i "s/genie-plasim/genie-plasim-$clone/g" # no files
# change names in genie-plasim-1
cd /scratch/$USER/cgenie.muffin/genie-plasim-$clone
grep -l -r 'genie-main' | xargs sed -i "s/genie-main/genie-main-$clone/g"
# grep -l -r 'genie-lib' | xargs sed -i "s/genie-lib/genie-lib-$clone/g" # no files
grep -l -r 'genie-plasim' | xargs sed -i "s/genie-plasim/genie-plasim-$clone/g"
# install netcdf libraries
cd ~/genie.install.stuff
./netcdf.libraries.install.sh $clone
# return home
cd /home/$USER/
# say we're done with that clone
echo "cgenie.muffin/genie-main-$clone created"
done
