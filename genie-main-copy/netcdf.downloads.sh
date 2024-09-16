#!/bin/bash
### Borrowing code from cGENIE.setup.sh on 20231003
### just trying to download and compile netcdf libraries into genie-main svn checkouts so each has its own netcdf library...
# $1 is the clone number, assuming multiple genie-main directorues
cd $1

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

./configure --prefix=$1 --disable-netcdf-4 --disable-dap
make clean
make check
make install
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
export CPPFLAGS=-I$1/include #(has been required on some machines)
export LDFLAGS=-L$1/lib #(has been required on some machines)
./configure --prefix=$1
make clean
make install
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
LD_LIBRARY_PATH=$1/lib
export LD_LIBRARY_PATH
./configure --prefix=$1

make clean
make check

make install
cd ~

LD_LIBRARY_PATH=$1/lib
export LD_LIBRARY_PATH

