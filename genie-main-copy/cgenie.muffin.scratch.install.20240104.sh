#!/bin/bash -e
#
#####################################################################
### SCIPT TO DOWNLOAD CLONE cgenie.muffin DIRECTORY 
### TO SCRATCH ON REDHAT HPC
#####################################################################

# input variable $1 github user - assuming that genie-main sits in https://github.com/[user]/cgenie.muffin/trunk/genie-main
# should be run like: ./cgenie.muffin.scratch.install.sh richardstockey
# will need to change permissions using chmod +x ~/cgenie.muffin/genie-main/cgenie.muffin.scratch.install.sh
# NOTE - 20240104 - ended up running this line by line to get it to work... but then it worked just fine. 
# could just make it a shell script, might be easier. 
# NOTE - 20240104b - now it is just a shell script. 

module load gcc/6.4.0
module load gnumake
module load git 

LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH

[ -d '/scratch/rgs1e22/cgenie.muffin' ] && rm -rf /scratch/rgs1e22/cgenie.muffin
git clone https://github.com/$1/cgenie.muffin/ /scratch/$USER/cgenie.muffin

cd /home/$USER/genie.install.stuff
./netcdf.libraries.install.new2.sh
# return home
cd /home/$USER/
