#!/usr/bin/env bash

GMP_Version=gmp-6.1.2
GF2X_Version=gf2x-1.2
NTL_Version=ntl-11.3.0
SWIG_Version=swig-3.0.12
BOOST_Version=boost_1_68_0
ARMADILLO_Version=armadillo-9.200.6

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

# init
Marker=SparkFHE_succeded
PROJECT_ROOT_PATH=`pwd`/"../../../"
DEPS_PATH="$PROJECT_ROOT_PATH/deps"
libSparkFHE_root=$PROJECT_ROOT_PATH/libSparkFHE
libSparkFHE_include=$PROJECT_ROOT_PATH/libSparkFHE/include
libSparkFHE_lib=$PROJECT_ROOT_PATH/libSparkFHE/lib
libSparkFHE_share=$PROJECT_ROOT_PATH/libSparkFHE/share
mkdir -p $libSparkFHE_include $libSparkFHE_lib $libSparkFHE_share  $DEPS_PATH

#Boost Libraries (Comma Separated library names)
boost_libraries=iostreams

cd $DEPS_PATH


# =============================================================================
# functions to minimize code redundancy 
# =============================================================================

install_boost(){
    echo "Installing $BOOST..."
    wget https://dl.bintray.com/boostorg/release/1.68.0/source/$BOOST_Version.tar.bz2
    tar jxf "$BOOST_Version".tar.bz2
    rm "$BOOST_Version".tar.bz2
    mv $BOOST_Version $BOOST
    cd $BOOST
     ./bootstrap.sh --with-libraries=$boost_libraries --prefix=$libSparkFHE_root
    ./b2 install
    echo "Installing $BOOST... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

install_googletest(){
    echo "Installing $GoogleTEST..."
    git clone https://github.com/google/googletest.git $GoogleTEST
    cd $GoogleTEST
    cmake -DCMAKE_CXX_COMPILER=g++-8 -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make CXX=g++-8 LD=g++-8; make install
    echo "Installing $GoogleTEST... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

install_swig(){
    echo "Installing $SWIG..."
    wget http://prdownloads.sourceforge.net/swig/$SWIG_Version.tar.gz
    tar xzf $SWIG_Version.tar.gz
    rm $SWIG_Version.tar.gz
    mv $SWIG_Version $SWIG
    cd $SWIG
    ./configure --prefix=$libSparkFHE_root --exec-prefix=$libSparkFHE_root
    make; make install
    echo "Installing $SWIG... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

install_jansson(){
    echo "Installing $JANSSON..."
    git clone https://github.com/akheron/jansson.git $JANSSON
    cd $JANSSON
    cmake -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make; make install
    echo "Installing $JANSSON... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

install_gmp(){
    echo "Installing $GMP..."
    wget https://ftp.gnu.org/gnu/gmp/$GMP_Version.tar.bz2
    tar jxf $GMP_Version.tar.bz2
    rm $GMP_Version.tar.bz2
    mv $GMP_Version $GMP
    cd $GMP
    ./configure --prefix=$libSparkFHE_root --exec-prefix=$libSparkFHE_root
    make; make install
    echo "Installing $GMP... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

download_and_install_gf2x(){
    wget https://gforge.inria.fr/frs/download.php/file/36934/$GF2X_Version.tar.gz
    tar -xf $GF2X_Version.tar.gz
    rm $GF2X_Version.tar.gz
    mv $GF2X_Version GF2X
    cd GF2X
    ./configure ABI=64 CFLAGS="-m64 -O2 -fPIC" --prefix=$libSparkFHE_root
    make CXX=g++-8
    make CXX=g++-8 tune-lowlevel
    make CXX=g++-8 tune-toom
    make CXX=g++-8 check
    make CXX=g++-8 install
    echo "Installing $GF2X... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

download_and_install_ntl(){
    echo "Installing $NTL..."
    wget http://www.shoup.net/ntl/$NTL_Version.tar.gz
    tar xzf $NTL_Version.tar.gz
    rm $NTL_Version.tar.gz
    mv $NTL_Version $NTL
    cd $NTL/src
    ./configure TUNE=x86 NTL_GF2X_LIB=on DEF_PREFIX=$libSparkFHE_root NTL_THREADS=on NTL_THREAD_BOOST=on NTL_GMP_LIP=on NATIVE=off CXX=g++-8
    make CXX=g++-8 CXXFLAGS="-fPIC -O3"
    make install
    echo "Installing $NTL... (DONE)"
    cd ..
    touch $Marker # add the marker 
    cd ..
}

download_and_install_armadillo(){
    echo "Installing $ARMADILLO..."
    wget https://sourceforge.net/projects/arma/files/$ARMADILLO_Version.tar.xz
    tar xf $ARMADILLO_Version.tar.xz
    rm $ARMADILLO_Version.tar.xz
    mv $ARMADILLO_Version $ARMADILLO
    cd $ARMADILLO
    cmake -DCMAKE_CXX_COMPILER=g++-8 -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make; make install
    echo "Installing $ARMADILLO... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

download_and_install_helib(){
    echo "Installing $HElib..."
    git clone https://github.com/SpiRITlab/HElib.git $HElib
    cd $HElib
    git checkout master-SparkFHE
    cmake -DCMAKE_CXX_COMPILER=g++-8 -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make CC=g++-8 LD=g++-8 LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
    mkdir -p $libSparkFHE_include/HElib/
    cp src/*.h $libSparkFHE_include/HElib/
    cp lib/libfhe.a $libSparkFHE_lib/libfhe.a
    echo "Installing $HElib... (DONE)"
    touch $Marker # add the marker 
    cd ..
}

# =============================================================================
# installing dependencies 
# =============================================================================


# Boost is a set of libraries for the C++ programming language that provide 
# support for tasks and structures such as linear algebra, pseudorandom number 
# generation, multithreading, image processing, regular expressions, and unit 
# testing.
BOOST="BOOST"
if [ -d $BOOST ]; then
    if [ ! -f $BOOST/$Marker ]; then
        rm -rf $BOOST. # remove the folder 
        install_boost
    else
        echo "BOOST library already installed"
    fi  
else
    install_boost
fi

# Google Test is a unit testing library for the C++ programming language, 
# based on the xUnit architecture.
GoogleTEST="GoogleTEST"
if [ -d $GoogleTEST ]; then
    if [ ! -f $GoogleTEST/$Marker ]; then
        rm -rf $GoogleTEST. # remove the folder
        install_googletest
    else
        echo "GoogleTEST already installed"
    fi
else
    install_googletest
fi

# The Simplified Wrapper and Interface Generator is an open-source software
# tool used to connect computer programs or libraries written in C or C++ 
# with scripting languages such as Lua, Perl, PHP, Python, R, Ruby, Tcl, and 
# other languages like C#, Java, JavaScript, Go, Modula-3, OCaml, Octave, 
# Scilab and Scheme.
SWIG="SWIG"
if [ -d $SWIG ]; then
    if [ ! -f $SWIG/$Marker ]; then
        rm -rf $SWIG. # remove the folder
        install_swig
    else
        echo "SWIG already installed"
    fi
else
    install_swig
fi

# Jansson is a C library for encoding, decoding and manipulating JSON data.
JANSSON="JANSSON"
if [ -d $JANSSON ]; then
    if [ ! -f $JANSSON/$Marker ]; then
        rm -rf $JANSSON. # remove the folder
        install_jansson
    else
        echo "JANSSON already installed"
    fi
else
    install_jansson
fi

# The GMP package contains math libraries. These have useful functions 
# for arbitrary precision arithmetic.
GMP="GMP"
if [ -d $GMP ]; then
    if [ ! -f $GMP/$Marker ]; then
        rm -rf $GMP. # remove the folder
        install_gmp
    else
        echo "GMP already installed"
    fi
else
    install_gmp 
fi

# gf2x is a C/C++ software package containing routines for fast arithmetic
# in GF(2)[x] (multiplication, squaring, GCD) and searching for 
# irreducible/primitive trinomials.
GF2X="GF2X"
if [ -d $GF2X ]; then
    if [ ! -f $GF2X/$Marker ]; then
        rm -rf $GF2X. # remove the folder
        download_and_install_gf2x
    else
        echo "GF2X already installed"
    fi
else
    download_and_install_gf2x
fi

# NTL is a C++ library for doing number theory. NTL supports arbitrary 
# length integer and arbitrary precision floating point arithmetic, finite 
# fields, vectors, matrices, polynomials, lattice basis reduction and basic 
# linear algebra.
NTL="NTL"
if [ -d $NTL ]; then
    if [ ! -f $NTL/$Marker ]; then
        rm -rf $NTL. # remove the folder
        download_and_install_ntl
    else
        echo "NTL already installed"
    fi
else
    download_and_install_ntl
fi

# Armadillo is a linear algebra software library for the C++. 
ARMADILLO="ARMADILLO"
if [ -d $ARMADILLO ]; then
    if [ ! -f $ARMADILLO/$Marker ]; then
        rm -rf $ARMADILLO. # remove the folder
        download_and_install_armadillo
    else
        echo "ARMADILLO already installed"
    fi
else
    download_and_install_armadillo
fi

# HElib is a software library that implements homomorphic encryption (HE).
HElib="HElib"
if [ -d $HElib ]; then
     if [ ! -f $HElib/$Marker ]; then
        rm -rf $HElib. # remove the folder
        download_and_install_helib
    else
        echo "HElib already installed"
    fi
else
    download_and_install_helib
fi

# download and install SEAL; due to copyright reason we can automatically fetch the package.
# download from here, https://www.microsoft.com/en-us/research/project/simple-encrypted-arithmetic-library/
# place the folder into deps and rename to "SEAL"
# SEAL="SEAL"
# if [ -d $SEAL ]; then
#    echo "Installing $SEAL..."
#    cd $SEAL/$SEAL
#    cmake .
#    make
#    echo "Installing $SEAL... (DONE)"
#    cd ../..
# else
#    echo "Please download Seal from https://www.microsoft.com/en-us/research/project/simple-encrypted-arithmetic-library/ "
#    echo "and put and rename the library to deps/SEAL before continue."
#    exit
# fi


#PALISADE="PALISADE"
#if [ ! -d $PALISADE ]; then
#    echo "Installing $PALISADE..."
#    git clone https://git.njit.edu/palisade/PALISADE.git $PALISADE
#    cd $PALISADE
#    make CXX=g++-8 LD=g++-8
#    echo "Installing $PALISADE... (DONE)"
#    cd ..
#fi


# Uncomment the follow code to install AWS SDK
# download and compile AWS SDK for c++
#https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html
#AwsSDK="AwsSDK"
#if [ ! -d $AwsSDK ]; then
#    echo "Installing $AwsSDK..."
#    git clone https://github.com/aws/aws-sdk-cpp.git $AwsSDK
#    cd $AwsSDK;
#    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_ONLY="s3" .
#    make CC=g++-8 LD=g++-8 CFLAGS+=-fPIC
#    sudo make install
#    cp AWSSDK/* cmake/
#    echo "Installing $AwsSDK... (DONE)"
#    cd ..
#fi


trap EXIT

trap - EXIT

