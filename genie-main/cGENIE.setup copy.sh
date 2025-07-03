#!/bin/bash
### CGENIE LIBRARIES SETUP AND GENERAL INSTALL ###

cd $HOME

### Establishing where we are installing ###
echo "Hi there, are you trying to install cGENIE on a HPC user account (Iridis/Lyceum at Southampton) or a local Ubuntu machine (NOTE - you must accurately type one of the options in the square brackets for all questions) [hpc/local]?"
read machine
echo "Great - running setup for $machine!"
sleep 1s

### Establishing if we need a new copy of cGENIE from github ###
echo "Do you already have a version of cGENIE installed from github (it is easy to install here if not)? [yes/no]"
read genie
if [ "$genie" = "yes" ]
    then
    echo "Okay - we will assume that you have a functional download of cGENIE and have appropriately edited the user.mak file following the cGENIE.muffin manual (section 1.2.3 Configuring the code). If the testbiogem run at the end of this program fails, consider rerunning the program and selecting 'no' here."
fi
if [ "$genie" = "no" ]
    then
    echo "Great - we will also install cGENIE towards the end of this program."
fi
sleep 1s

### Do we need to install basic fortran libraries (e.g. for a clean Ubuntu install?) ###
if [ "$machine" = "local" ]
then
echo "If you're installing on a local machine, it is suggested that you use Ubuntu 20.04 LTS (or earlier, this program has just been tested on 20.04...). Have you just done a clean install of Ubuntu? i.e. do you need to install gfortran, g++, m4, make, python2.7, git, xsltproc, ldconfig? [yes/no]"
read clean
if [ "$clean" = "yes" ]
    then
    echo "Great - as you have a clean install of Ubuntu, we will install those now!"
fi
if [ "$clean" = "no" ]
    then
    echo "Okay - we will assume that you have functional versions of the software mentioned above. If you encounter issues with this program, check that you have working versions of these (e.g. run "gfortran --version" in terminal). They can be individually installed, or you can rerun the program and change your answer to this question (although note that this will likely overwrite any existing versions [assuming you have the admin rights to do so...])."
fi
fi
sleep 1s

if [ "$machine" = "local" ] && [ "$clean" = "yes" ]
then

# no need to install gfortran on iridis – comment out for ubuntu local machine
# on 20230628 – Iridis has GNU Fortran (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44)
### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install gfortran

# no need to install g++ on iridis – comment out for ubuntu local machine
# on 20230628 – Iridis has g++ (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44)
### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install g++

# no need to install m4 on iridis – comment out for ubuntu local machine
# on 20230628 – Iridis has m4 (GNU M4) 1.4.16
### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install m4

# no need to install make on iridis – comment out for ubuntu local machine
# on 20230628 – Iridis has GNU Make 3.82
### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install make
fi

if [ "$machine" = "hpc" ] # - want to make netcdf.mod (and other files) with the same version of gfortran that we will then use for sbatch slurm jobs
then
module load gcc/6.4.0
module load gnumake
fi

### Install netcdf-4.6.1 ###
FILE=v4.6.1.tar.gz
if [ -f "$FILE" ]; then
    echo "$FILE has been downloaded already."
else
    echo "$FILE requires download and will be downloaded now."
    # wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz [old muffin manual version - broken link?]
    wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.1.tar.gz
fi
# tar xzf netcdf-4.6.1.tar.gz [old muffin manual version - broken link?]
tar xzf v4.6.1.tar.gz
# cd netcdf-4.6.1 [old muffin manual version - broken link?]
cd netcdf-c-4.6.1
if [ "$machine" = "local" ]
then
### UBUNTU ONLY [line below] ###
./configure --disable-netcdf-4 --disable-dap
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) ###
./configure --prefix=$HOME --disable-netcdf-4 --disable-dap
fi
if [ "$machine" = "local" ]
then
# change line 7472 of ~/netcdf-4.6.1/libtool [add "/" before ""$dir""] (has been required on Ubuntu)
read -p "Change line 7472 of ~/netcdf-4.6.1/libtool [add "/" before ""$dir""]. Once you've done this, press any key!" -n1 -s
fi
make clean
make check
if [ "$machine" = "local" ]
then
###  UBUNTU LOCAL ONLY [line below] ###
sudo make install
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below]  ###
make install
fi
cd ~

### Install netcdf-cxx-4.2 ###
FILE=netcdf-cxx-4.2.tar.gz
if [ -f "$FILE" ]; then
    echo "$FILE has been downloaded already."
else
    echo "$FILE requires download and will be downloaded now."
    # wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-cxx-4.2.tar.gz [old muffin manual version - broken link?]
    wget https://downloads.unidata.ucar.edu/netcdf-cxx/4.2/netcdf-cxx-4.2.tar.gz
fi
tar xzf netcdf-cxx-4.2.tar.gz
cd netcdf-cxx-4.2
if [ "$machine" = "local" ]
then
### UBUNTU ONLY [2 lines below] ###
export CPPFLAGS=-I$/usr/include # (has been required on some machines)
export LDFLAGS=-L$/usr/lib # (has been required on some machines)
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [2 lines below] ###
export CPPFLAGS=-I$HOME/include #(has been required on some machines)
export LDFLAGS=-L$HOME/lib #(has been required on some machines)
fi
if [ "$machine" = "local" ]
then
### UBUNTU ONLY [line below] ###
./configure
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below] ###
./configure --prefix=$HOME
fi
if [ "$machine" = "local" ]
then
# change line 5324 of ~/netcdf-cxx-4.2/libtool [add "/" before ""$dir""] (has been required on Ubuntu machines)
read -p "Change line 5324 of ~/netcdf-cxx-4.2/libtool [add "/" before ""$dir""]. Once you've done this, press any key!" -n1 -s
fi
make clean
make check
if [ "$machine" = "local" ]
then
###  UBUNTU LOCAL ONLY [line below] ###
sudo make install
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below] ###
make install
fi
cd ~

### Install netcdf-fortran-4.4.4 ###
FILE=v4.4.4.tar.gz
if [ -f "$FILE" ]; then
    echo "$FILE has been downloaded already."
else
    echo "$FILE requires download and will be downloaded now."
    # wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz [old muffin manual version - broken link?]
    wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.4.4.tar.gz
    # or can use (if prefer archive or github archive not maintained longterm)
    # wget https://artifacts.unidata.ucar.edu/repository/downloads-netcdf-fortran/4.4.4/netcdf-fortran-4.4.4.tar.gz
fi
#tar xzf netcdf-fortran-4.4.4.tar.gz [old muffin manual version - broken link?]
tar xzf v4.4.4.tar.gz
cd netcdf-fortran-4.4.4
if [ "$machine" = "local" ]
then
### UBUNTU ONLY [line below] ###
LD_LIBRARY_PATH=/usr/lib
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below]  ###
LD_LIBRARY_PATH=$HOME/lib
fi
export LD_LIBRARY_PATH
if [ "$machine" = "local" ]
then
### UBUNTU ONLY [line below] ###
./configure
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below] ###
./configure --prefix=$HOME
fi
if [ "$machine" = "local" ]
then
# change line 6000 of ~/netcdf-fortran-4.4.4/libtool [add "/" before ""$dir""] (has been required on Ubuntu machines)
read -p "Change line 6000 of ~/netcdf-fortran-4.4.4/libtool [add "/" before ""$dir""]. Once you've done this, press any key!" -n1 -s
fi
make clean
make check
if [ "$machine" = "local" ]
then
###  UBUNTU LOCAL ONLY [line below] ###
sudo make install
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [line below] ###
make install
fi
cd ~


if [ "$machine" = "local" ] && [ "$clean" = "yes" ]
then
### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo ldconfig

### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install xsltproc

### CLEAN UBUNTU INSTALL ONLY [line below] ###
sudo apt install git

### CLEAN UBUNTU INSTALL ONLY [2 lines below] ###
sudo apt install python2.7
sudo ln -s /usr/bin/python2.7 /usr/bin/python
fi


if [ "$genie" = "no" ]
then
git clone https://github.com/derpycode/cgenie.muffin
if [ "$machine" = "hpc" ]
then
cp $HOME/cgenie.muffin.mix/user.mak $HOME/cgenie.muffin/genie-main/user.mak
echo "We have also copied a new version of user.mak into cgenie.muffin/genie-main"
fi
fi

if [ "$machine" = "local" ]
then
### UBUNTU ONLY [2 lines below] ###
LD_LIBRARY_PATH=usr/local/lib
export LD_LIBRARY_PATH
fi
if [ "$machine" = "hpc" ]
then
### Iridis (Red Hat) [2 lines below] - not necessary? ###
LD_LIBRARY_PATH=$HOME/lib
export LD_LIBRARY_PATH
fi

# make cgenie.jobs directory
cd ~
mkdir cgenie.jobs

### Testing cGENIE ###
echo "*** We will now test whether cGENIE is running properly on your machine - cross your fingers! ***"
sleep 3s

# Test installed cGENIE version
cd cgenie.muffin/genie-main
make cleanall
make testbiogem
echo "If the above text reads '*TEST OK*', breathe a sigh of relief... you have a working version of cGENIE!!! If instead you see error messages, try to trace them. Which netcdf library isn't working? Which files can't cGENIE find? If you've tried this, taken a break, and tried again to no avail, consider chatting to your IT folks and let Rich Stockey know on r.g.stockey@soton.ac.uk (or just come by if you're a Southampton person!)."
