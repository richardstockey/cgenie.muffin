#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### N TIMES TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github user - assuming that genie-main sits in https://github.com/[user]/cgenie.muffin/trunk/genie-main
# input variable $2 number of times to clone
# should be run like: ./cgenie.muffin.reinstall.netcdf.libraries.clones.sh richardstockey 40
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.reinstall.netcdf.libraries.clones.sh
module load gcc/6.4.0
module load gnumake

for clone in $(seq $2)
do
cd ~/genie.install.stuff
./netcdf.libraries.reinstall.sh $clone
# return home
cd /home/$USER/
# say we're done with that clone
echo "cgenie.muffin-$clone netcdf libraries reinstalled"
done
