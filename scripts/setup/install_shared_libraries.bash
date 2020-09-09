#!/bin/bash

#
# Copyright SpiRITlab - The SparkFHE project.
# https://github.com/SpiRITlab
#

# version of dependencies
CMAKE_Version=cmake-3.15.0
GMP_Version=gmp-6.2.0
NTL_Version=ntl-11.4.3
SWIG_Version=swig-4.0.1
HADOOP_Version=hadoop-2.9.2
SEAL_Version=3.5.1
HElib_Version=v1.0.1

set_compilers() {
  GCCCompilers=$1
  if [ -z "$GCCCompilers" ] ; then
    echo "Please install GCC-9 or above."
    exit 1
  else
    LatestGCCVersionNum=$(printf "%d\n" "${GCCCompilers[@]}" | sort -rn | head -1)
    # Set compiler version
    CCcompiler=gcc-$LatestGCCVersionNum
    CPPcompiler=g++-$LatestGCCVersionNum
    echo "Set GCC and G++ compiler to $CCcompiler and $CPPcompiler."
  fi
}

OS=$(uname -s)
if [[ "$OS" == "Darwin" ]] ; then
  GCCCompilers=($(ls /usr/local/bin/g++-* | cut -d'-' -f2))
elif [[ "$OS" == "Linux" ]] ; then
  GCCCompilers=($(ls /usr/bin/g++-* | cut -d'-' -f2))
else
  echo 'Unsupported OS'
  exit 1
fi
set_compilers $GCCCompilers

### Optional packages
Enable_AWSS3=false      # add AWSS3 or not
Enable_HDFS=false       # add HDFS or not
######################

# Directories and files
Marker=.install_ok              # marker to indicate whether a dependecy has installed properly
PROJECT_ROOT=`pwd`/"../../../"
DEPS_ROOT="$PROJECT_ROOT/deps"   # directory for installing dependencies
CMAKE_EXE=cmake

mkdir -p $DEPS_ROOT/{include,lib,bin,share,src,tmp}
DEPS_include=$DEPS_ROOT/include
DEPS_lib=$DEPS_ROOT/lib
DEPS_bin=$DEPS_ROOT/bin
DEPS_share=$DEPS_ROOT/share
DEPS_src=$DEPS_ROOT/src
DEPS_tmp=$DEPS_ROOT/tmp

set_trap() {
# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT
}

parse_args() {
    IFS=',' read -ra OPT_PKGS <<< "$1"
    for i in "${OPT_PKGS[@]}"; do
        if [ "$i" == "AWSS3" ] ; then
            Enable_AWSS3=true
        elif [ "$i" == "help" ] ; then
            usage
            trap EXIT
            exit 0
        fi
    done
}

usage(){
    echo "$0 [AWSS3]"
}

set_trap
parse_args $1


# =============================================================================
# functions to minimize code redundancy
# =============================================================================
install_cmake() {
    echo "Installing $CMAKE..."
    wget https://github.com/Kitware/CMake/releases/download/v$(echo $CMAKE_Version | cut -d'-' -f2)/$CMAKE_Version.tar.gz
    tar -zxvf $CMAKE_Version.tar.gz
    rm $CMAKE_Version.tar.gz
    mv $CMAKE_Version $CMAKE
    cd $CMAKE
    ./bootstrap --prefix=$DEPS_ROOT
    make; make install
    echo "Installing $CMAKE... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_googletest() {
    echo "Installing $GoogleTEST..."
    git clone https://github.com/google/googletest.git $GoogleTEST
    cd $GoogleTEST
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$DEPS_ROOT .
    make CXX=$CPPcompiler LD=$CPPcompiler; make install
    echo "Installing $GoogleTEST... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_swig() {
    echo "Installing $SWIG..."
    wget http://prdownloads.sourceforge.net/swig/$SWIG_Version.tar.gz
    tar xzf $SWIG_Version.tar.gz
    rm $SWIG_Version.tar.gz
    mv $SWIG_Version $SWIG
    cd $SWIG
    ./configure --prefix=$DEPS_ROOT --exec-prefix=$DEPS_ROOT
    make; make install
    echo "Installing $SWIG... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_rapidjson() {
    echo "Installing $RapidJSON..."
    git clone https://github.com/Tencent/rapidjson.git $RapidJSON
    cd $RapidJSON
    $CMAKE_EXE -DCMAKE_INSTALL_PREFIX=$DEPS_ROOT -DRAPIDJSON_HAS_STDSTRING=ON .
    make install
    echo "Installing $RapidJSON... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_gmp() {
    echo "Installing $GMP..."
    wget https://ftp.gnu.org/gnu/gmp/$GMP_Version.tar.bz2
    tar jxf $GMP_Version.tar.bz2
    rm $GMP_Version.tar.bz2
    mv $GMP_Version $GMP
    cd $GMP
    ./configure --prefix=$DEPS_ROOT --exec-prefix=$DEPS_ROOT
    make; make install
    echo "Installing $GMP... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_ntl() {
    echo "Installing $NTL..."
    wget http://www.shoup.net/ntl/$NTL_Version.tar.gz
    tar xzf $NTL_Version.tar.gz
    rm $NTL_Version.tar.gz
    mv $NTL_Version $NTL
    cd $NTL/src
    ./configure TUNE=x86 DEF_PREFIX=$DEPS_ROOT PREFIX=$DEPS_ROOT NTL_GMP_LIP=on GMP_PREFIX=$DEPS_ROOT NTL_THREADS=on NTL_THREAD_BOOST=on NATIVE=off CXX=$CPPcompiler
    make CXX=$CPPcompiler CXXFLAGS="-fPIC -O3"
    make install
    echo "Installing $NTL... (DONE)"
    cd ..
    touch $Marker # add the marker
    cd ..
}

install_helib() {
    echo "Installing $HElib..."
    git clone https://github.com/SpiRITlab/HElib.git $HElib
    cd $HElib
    git checkout $HElib_Version
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$DEPS_ROOT .
    make CXX=$CPPcompiler LD=$CPPcompiler LDLIBS+=-L$DEPS_lib CFLAGS+=-I$DEPS_include CFLAGS+=-fPIC
    cp -R include/helib $DEPS_include/
    cp lib/*.a $DEPS_lib/
    echo "Installing $HElib... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_base64() {
    echo "Installing $BASE64..."
    git clone https://github.com/SpiRITlab/libb64.git $BASE64
    cd $BASE64
    make
    cp -r include/b64/ $DEPS_include/b64
    cp src/libb64.a $DEPS_lib
    cp base64/base64 $DEPS_bin
    echo "Installing $BASE64... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_seal() {
    echo "Installing $SEAL..."
    git clone https://github.com/microsoft/SEAL.git $SEAL
    cd $SEAL
    git checkout $SEAL_Version
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$DEPS_ROOT .
    make CXX=$CPPcompiler LD=$CPPcompiler LDLIBS+=-L$DEPS_lib CFLAGS+=-I$DEPS_include CFLAGS+=-fPIC
    make install
    echo "Installing $SEAL... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_awssdk() {
    echo "Installing $AWSSDK..."
    git clone https://github.com/aws/aws-sdk-cpp.git $AWSSDK
    cd $AWSSDK;
    $CMAKE_EXE -DCMAKE_BUILD_TYPE=Debug -DBUILD_ONLY="s3" -DCMAKE_INSTALL_PREFIX=$DEPS_ROOT .
    make CXX=$CPPcompiler LD=$CPPcompiler LDLIBS+=-L$DEPS_lib CFLAGS+=-I$DEPS_include CFLAGS+=-fPIC
    make install
    cp AWSSDK/* cmake/
    echo "Installing $AWSSDK... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_latest_hdfs(){
    HDFS_GIT_VERSION="3.3.0-SNAPSHOT"
    echo "Installing $HDFS SDK..."
    git clone https://github.com/SpiRITlab/hadoop.git $HDFS

    echo "In another terminal, execute the following commands: "
    echo "  cd $DEPS_ROOT/$HDFS/"
    echo "  sudo bash start-build-env.sh"
    echo "This will prepare a Hadoop development environment in a docker container. In this container, use maven to compile Hadoop packages."
    echo "  mvn package -Pdist,native -DskipTests"
    while true; do
        read -p "Have the Maven compiliation finished? Yes(y) to continue, or quit (q)" ynq
        case $ynq in
            [Yy]* ) break;;
            [Nn]* ) echo "Can't proceed, please wait...";;
        [Qq]* ) exit;;
            * ) echo "Please answer yes (y), no (n), or quit (q).";;
        esac
    done

    cd $HDFS/hadoop-hdfs-project
    set +e
    ## declare an array variable
    declare -a hadoop_hdfs_pkgs=( hadoop-hdfs hadoop-hdfs-client hadoop-hdfs-httpfs hadoop-hdfs-native-client hadoop-hdfs-nfs hadoop-hdfs-rbf )
    for hdfs_pkg in "${hadoop_hdfs_pkgs[@]}"; do
        echo "Copying compiled files from ${hdfs_pkg}..."
        cp -Rn ${hdfs_pkg}/target/${hdfs_pkg}-${HDFS_GIT_VERSION}/* $DEPS_ROOT/
    done
    set_trap

    # compile hadoop-common source code
    cd ../hadoop-common-project
    set +e
    ## declare an array variable
    declare -a hadoop_common_pkgs=( hadoop-common )
    for common_pkg in "${hadoop_common_pkgs[@]}"; do
        echo "Copying compiled files from ${common_pkg}..."
        cp -Rn ${common_pkg}/target/${common_pkg}-${HDFS_GIT_VERSION}/* $DEPS_ROOT/
    done
    set_trap

    echo "Installing $HDFS SDK... (DONE)"
    cd ../
    touch $Marker # add the marker
    cd ..
}



install_stable_hdfs(){
    echo "Installing $HDFS SDK..."
    wget http://mirror.cc.columbia.edu/pub/software/apache/hadoop/common/$HADOOP_Version/"$HADOOP_Version"-src.tar.gz
    tar zxvf "$HADOOP_Version"-src.tar.gz
    mv "$HADOOP_Version"-src $HDFS
    rm -rf "$HADOOP_Version"-src.tar.gz
    cd $HDFS/hadoop-hdfs-project
    patch -p2 < ../../../patch/libhdfs.patch

    # installing protobuf-2.5.0 as it is required by hadoop
    mkdir -p protobufCompiled
    CURRENT_PATH=$(pwd)
    wget https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
    tar zxvf protobuf-2.5.0.tar.gz
    rm -rf protobuf-2.5.0.tar.gz
    cd protobuf-2.5.0
    ./configure --prefix=${CURRENT_PATH}/protobufCompiled
    make
    make check
    make install
    cd ..

    OLD_PATH=$PATH
    NEW_PATH=${CURRENT_PATH}/protobufCompiled/bin:$PATH

    # compile HDFS source code
    export PATH=$NEW_PATH && mvn package -Pdist,native -DskipTests

    set +e
    ## declare an array variable
    declare -a hadoop_hdfs_pkgs=( hadoop-hdfs hadoop-hdfs-client hadoop-hdfs-httpfs hadoop-hdfs-native-client hadoop-hdfs-nfs hadoop-hdfs-rbf )
    for hdfs_pkg in "${hadoop_hdfs_pkgs[@]}"; do
        echo "Copying compiled files from ${hdfs_pkg}..."
        cp -Rn ${hdfs_pkg}/target/${hdfs_pkg}-${HADOOP_Version:7}/* $DEPS_ROOT/
    done
    set_trap


    # compile hadoop-common source code
    cd ../hadoop-common-project
    export PATH=$NEW_PATH && mvn package -Pdist,native -DskipTests

    set +e
    ## declare an array variable
    declare -a hadoop_common_pkgs=( hadoop-common )
    for common_pkg in "${hadoop_common_pkgs[@]}"; do
        echo "Copying compiled files from ${common_pkg}..."
        cp -Rn ${common_pkg}/target/${common_pkg}-3.1.2/* $DEPS_ROOT/
    done
    set_trap

    export PATH=$OLD_PATH


    echo "Installing $HDFS SDK... (DONE)"
    cd ../
    touch $Marker # add the marker
    cd ..
}



# =============================================================================
# installing dependencies
# =============================================================================
cd $DEPS_src

export LD_LIBRARY_PATH=$DEPS_lib


installMinRequiredCmake() {
  CMAKE="CMAKE"
  CMAKE_EXE=$DEPS_bin/cmake
  if [ -d $CMAKE ]; then
    if [ ! -f $CMAKE/$Marker ]; then
      rm -rf $CMAKE # remove the folder
      install_cmake
    else
      echo "$CMAKE library already installed"
    fi
  else
    install_cmake
  fi
}

echo "Checking CMake version...(Minimum required version: $(echo $CMAKE_Version | cut -d'-' -f2))"
if [ ! -z "$(cmake --version | grep 'version')" ]; then
  installedCmakeVersion=$(cmake --version | grep 'version' | cut -d' ' -f3)
  installedCmakeMajorVersion=$(echo $installedCmakeVersion | cut -d'.' -f1)
  installedCmakeMinorVersion=$(echo $installedCmakeVersion | cut -d'.' -f2)
  requiredMinCmakeMajorVersion=$(echo $CMAKE_Version | cut -d'-' -f2 | cut -d'.' -f1)
  requiredMinCmakeMinorVersion=$(echo $CMAKE_Version | cut -d'-' -f2 | cut -d'.' -f2)
  if [ "$installedCmakeMajorVersion" -lt "$requiredMinCmakeMajorVersion" ] \
    || [ "$installedCmakeMinorVersion" -lt "$requiredMinCmakeMinorVersion" ]; then
        echo "The installed version of CMake (current version: $installedCmakeVersion) is older than required. Perform install newer version."
        installMinRequiredCmake
  else
        echo "Minimum requirement for CMake is satisfied! (Current Version: $installedCmakeVersion)"
  fi
else
  installMinRequiredCmake
fi



# Google Test is a unit testing library for the C++ programming language,
# based on the xUnit architecture.
GoogleTEST="GoogleTEST"
if [ -d $GoogleTEST ]; then
    if [ ! -f $GoogleTEST/$Marker  ]; then
        rm -rf $GoogleTEST # remove the folder
        install_googletest
    else
        echo "$GoogleTEST already installed"
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
        rm -rf $SWIG # remove the folder
        install_swig
    else
        echo "$SWIG already installed"
    fi
else
    install_swig
fi


# RapidJSON is a JSON parser and generator for C++. It was inspired by RapidXml.
RapidJSON="RapidJSON"
if [ -d $RapidJSON ]; then
    if [ ! -f $RapidJSON/$Marker ]; then
        rm -rf $RapidJSON # remove the folder
        install_rapidjson
    else
        echo "$RapidJSON already installed"
    fi
else
    install_rapidjson
fi


# The GMP package contains math libraries. These have useful functions
# for arbitrary precision arithmetic.
GMP="GMP"
if [ -d $GMP ]; then
    if [ ! -f $GMP/$Marker ]; then
        rm -rf $GMP # remove the folder
        install_gmp
    else
        echo "$GMP already installed"
    fi
else
    install_gmp
fi


# NTL is a C++ library for doing number theory. NTL supports arbitrary
# length integer and arbitrary precision floating point arithmetic, finite
# fields, vectors, matrices, polynomials, lattice basis reduction and basic
# linear algebra.
NTL="NTL"
if [ -d $NTL ]; then
    if [ ! -f $NTL/$Marker ]; then
        rm -rf $NTL # remove the folder
        install_ntl
    else
        echo "$NTL already installed"
    fi
else
    install_ntl
fi


# HElib is a software library that implements homomorphic encryption (HE).
HElib="HElib"
if [ -d $HElib ]; then
     if [ ! -f $HElib/$Marker ]; then
        rm -rf $HElib # remove the folder
        install_helib
    else
        echo "$HElib already installed"
    fi
else
    install_helib
fi

# https://sourceforge.net/p/libb64/git
BASE64="BASE64"
if [ -d $BASE64 ]; then
    if [ ! -f $BASE64/$Marker ]; then
        rm -rf $BASE64 # remove the folder
        install_base64
    else
        echo "$BASE64 already installed"
    fi
else
   install_base64
fi

# https://www.microsoft.com/en-us/research/project/simple-encrypted-arithmetic-library/
# Recent version of SEAL will download and install gsl and zlib into its src folder.
SEAL="SEAL"
if [ -d $SEAL ]; then
    if [ ! -f $SEAL/$Marker ]; then
        rm -rf $SEAL # remove the folder
        install_seal
    else
        echo "$SEAL already installed"
    fi
else
   install_seal
fi


# https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html
if [ "$Enable_AWSS3" = true ] ; then
    AWSSDK="AWSSDK"
    if [ -d $AWSSDK ]; then
        if [ ! -f $AWSSDK/$Marker ]; then
            rm -rf $AWSSDK # remove the folder
            install_awssdk
        else
            echo "$AWSSDK already installed"
        fi
    else
        install_awssdk
    fi
fi

if [ "$Enable_HDFS" = true ] ; then
    HDFS="HDFS"
    if [ -d $HDFS ]; then
        if [ ! -f $HDFS/$Marker ]; then
            #rm -rf $HDFS # remove the folder
            install_latest_hdfs
        else
            echo "$HDFS already installed"
        fi
    else
        install_latest_hdfs
    fi
fi




trap EXIT
