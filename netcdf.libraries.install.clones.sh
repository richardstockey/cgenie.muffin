#!/bin/bash
### CGENIE LIBRARIES SETUP AND GENERAL INSTALL ###
# This script installs the necessary NetCDF libraries for a specific clone of cgenie.muffin.
clone=$1
base_dir="/mainfs/scratch/$USER/cgenie.muffin-$clone"

if [ ! -d "$base_dir" ]; then
    echo "Directory $base_dir does not exist."
    exit 1
fi

cd "$base_dir" || exit 1

module load gcc/13.2.0
export CFLAGS="-std=c11 -D_GNU_SOURCE"
export FC=gfortran
export CC=gcc


########################################
# PYTHON 2.7.18
########################################

tar xzf Python-2.7.18.tgz
cd Python-2.7.18

./configure \
    --prefix=$base_dir/python2.7

make -j4
make install

export PYTHON2_HOME=$base_dir/python2.7
export PATH="$PYTHON2_HOME/bin:$PATH"

echo "Installed:"
python2.7 --version

cd $base_dir

mkdir -p $base_dir/bin

cat > $base_dir/bin/python << 'EOF'
#!/bin/bash
exec $base_dir/python2.7/bin/python2.7 "$@"
EOF

chmod +x $base_dir/bin/python

export PATH="$base_dir/bin:$PATH"

### Install netcdf-4.6.1 ###
# wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.1.tar.gz # Already included in Rich's muffin due to node connectivity issues
tar xzf v4.6.1.tar.gz
cd netcdf-c-4.6.1
make distclean  # just in case

# Patch ocprint.c to include missing headers (order matters)
sed -i '/#include <stdio.h>/a #include <unistd.h>' ncdump/ocprint.c
sed -i '/#include <stdio.h>/a #include <string.h>' ncdump/ocprint.c
sed -i '/#include <stdio.h>/a #include <ctype.h>' ncdump/ocprint.c

./configure --prefix=$base_dir --disable-netcdf-4
make clean
make -j4
make install
cd ..

# Set paths to NetCDF-C (must already be installed)
#export NETCDF_HOME=$base_dir/netcdf-c-4.6.1
export NETCDF_HOME=$base_dir
export PATH="$NETCDF_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$NETCDF_HOME/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$NETCDF_HOME/lib:$LIBRARY_PATH"
export CPATH="$NETCDF_HOME/include:$CPATH"

export CPPFLAGS="-I$base_dir/include"
export LDFLAGS="-L$base_dir/lib"

### Install netcdf-cxx-4.2 ###
# wget https://downloads.unidata.ucar.edu/netcdf-cxx/4.2/netcdf-cxx-4.2.tar.gz # Already included in Rich's muffin due to node connectivity issues
tar xzf netcdf-cxx-4.2.tar.gz
cd netcdf-cxx-4.2
make distclean  # just in case

./configure --prefix=$base_dir
make clean
make -j4
make install
cd ..

#export NETCDF_HOME=$base_dir/netcdf-c-4.6.1
export NETCDF_HOME=$base_dir
export CPPFLAGS="-I$NETCDF_HOME/include"
export LDFLAGS="-L$NETCDF_HOME/lib"
export LD_LIBRARY_PATH="$NETCDF_HOME/lib:$LD_LIBRARY_PATH"
export FC=gfortran
export CC=gcc


### Install netcdf-fortran-4.4.4 ###
# wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.4.4.tar.gz # Already included in Rich's muffin due to node connectivity issues
tar xzf v4.4.4.tar.gz
cd netcdf-fortran-4.4.4
make distclean  # just in case
export LD_LIBRARY_PATH=$base_dir/lib
./configure --prefix=$base_dir
make -j4
make install
cd ..

# Set base paths for your NetCDF installations
export NETCDF_C_HOME=$base_dir
export NETCDF_CXX_HOME=$base_dir
export NETCDF_FORTRAN_HOME=$base_dir

# Include headers for compilation
export CPPFLAGS="-I$NETCDF_C_HOME/include -I$NETCDF_CXX_HOME/include -I$NETCDF_FORTRAN_HOME/include"

# Linker flags for libraries
export LDFLAGS="-L$NETCDF_C_HOME/lib -L$NETCDF_CXX_HOME/lib -L$NETCDF_FORTRAN_HOME/lib"

# Runtime library path for dynamic linking
export LD_LIBRARY_PATH="$NETCDF_C_HOME/lib:$NETCDF_CXX_HOME/lib:$NETCDF_FORTRAN_HOME/lib:$LD_LIBRARY_PATH"

# Optional: add binaries to PATH if you want to use netcdf tools directly
export PATH="$NETCDF_C_HOME/bin:$NETCDF_CXX_HOME/bin:$NETCDF_FORTRAN_HOME/bin:$PATH"

# Return to the original directory if needed
cd ..
