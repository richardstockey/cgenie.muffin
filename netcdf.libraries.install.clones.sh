#!/bin/bash
### CGENIE LIBRARIES SETUP AND GENERAL INSTALL ###
# This script installs the necessary NetCDF libraries for a specific clone of cgenie.muffin.
clone=$1
base_dir="/mainfs/scratch/rgs1e22/cgenie.muffin-$clone"

if [ ! -d "$base_dir" ]; then
    echo "Directory $base_dir does not exist."
    exit 1
fi

cd "$base_dir" || exit 1

module load gcc/6.4.0
module load gnumake

### Install netcdf-4.6.1 ###
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.1.tar.gz
tar xzf v4.6.1.tar.gz
cd netcdf-c-4.6.1
./configure --prefix=$base_dir --disable-netcdf-4 --disable-dap
make clean
make check
make install
cd ..

### Install netcdf-cxx-4.2 ###
wget https://downloads.unidata.ucar.edu/netcdf-cxx/4.2/netcdf-cxx-4.2.tar.gz
tar xzf netcdf-cxx-4.2.tar.gz
cd netcdf-cxx-4.2
export CPPFLAGS=-I$base_dir/include
export LDFLAGS=-L$base_dir/lib
./configure --prefix=$base_dir
make clean
make check
make install
cd ..

### Install netcdf-fortran-4.4.4 ###
wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.4.4.tar.gz
tar xzf v4.4.4.tar.gz
cd netcdf-fortran-4.4.4
export LD_LIBRARY_PATH=$base_dir/lib
./configure --prefix=$base_dir
make clean
make check
make install
cd ..

# Return to the original directory if needed
cd ..
