#!/bin/bash -e
#
# UPDATES BY RGS TO runmuffin.sh TO RUN ON SCRATCH AND HAVE MULTIPLE INSTANCES OF cgenie.muffin to avoid I/O errors
# 20230927 - started w default Andy runmuffin shell script. for each run, copy cgenie.muffin to scratch and rename it by appending the same thing as $3 (the userconfig)
#####################################################################
### SCIPT TO META-CONFIGURE AND RUN CGENIE.MUFFIN ###################
#####################################################################
#
echo ""
# (0) NEW cgenie.muffin DIRECTORY IN SCRATCH
# ----------------
#####################################################################
date
cp -R $HOME/cgenie.muffin /scratch/$USER/cgenie.muffin.$3
date
#
# (0) USER OPTIONS
# ----------------
#####################################################################
# CHANGE THIS FOR INSTALLATIONS OTHER THAN IN $HOME
# SET THE SAME AS IN user.mak AND user.sh
# set home directory
HOMEDIR=/scratch/$USER/
# RGS ADDIN 20230927 - copy new default user.mak and user.sh files for SCRATCH
#sed -i 's+$(HOME)/cgenie.muffin+/scratch/$USER/cgenie.muffin.$3+g' /scratch/$USER/cgenie.muffin.$3/genie-main/user.mak
