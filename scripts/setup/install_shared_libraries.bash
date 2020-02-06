#!/usr/bin/env bash

GMP_Version=gmp-6.1.2
GF2X_Version=gf2x-1.2
NTL_Version=ntl-11.3.0
SWIG_Version=swig-3.0.12
BOOST_Version=boost_1_68_0
ARMADILLO_Version=armadillo-9.200.6
HADOOP_Version=hadoop-2.9.2
CMAKE_Version=cmake-3.15.2
SEAL_Version=3.4.2


### Optional packages
Enable_AWSS3=false      # AWSS3
Enable_HDFS=false       # HDFS
######################

if [ "$(uname -s)" == "Darwin" ] ; then
  CCcompiler=gcc-9
  CPPcompiler=g++-9
else
  CCcompiler=gcc-8
  CPPcompiler=g++-8
fi

# init
Marker=SparkFHE_succeded
PROJECT_ROOT_PATH=`pwd`/"../../../"
DEPS_PATH="$PROJECT_ROOT_PATH/deps"

# determine whether this script is ran inside a docker container
if [ ! -f "/proc/1/cgroup" ] || [ "$(grep 'docker\|lxc' /proc/1/cgroup)" == "" ] ; then
  # if not, install dependencies into a self-contained folder
  libSparkFHE_root=$PROJECT_ROOT_PATH/libSparkFHE
else
  # if docker container, install dependencies into /usr/local
  libSparkFHE_root=/usr/local
fi
mkdir -p $libSparkFHE_root/{include,lib,bin,share} $libSparkFHE_root/bin/{keys,records} $DEPS_PATH
libSparkFHE_include=$libSparkFHE_root/include
libSparkFHE_lib=$libSparkFHE_root/lib
libSparkFHE_bin=$libSparkFHE_root/bin
libSparkFHE_share=$libSparkFHE_root/share

#Boost Libraries (Comma Separated library names)
boost_libraries=iostreams

cd $DEPS_PATH

set_trap(){
    # exit when any command fails
    set -e
    # keep track of the last executed command
    trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
    # echo an error message before exiting
    trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT
}

parse_args(){
    IFS=',' read -ra OPT_PKGS <<< "$1"
    for i in "${OPT_PKGS[@]}"; do
        if [ "$i" == "AWSS3" ] ; then
            Enable_AWSS3=true
        elif [ "$i" == "HDFS" ] ; then
            Enable_HDFS=true
        elif [ "$i" == "help" ] ; then
            usage
            trap EXIT
            exit 0
        fi
    done
}

usage(){
    echo "$0 [AWSS3,HDFS]"
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
    ./bootstrap --prefix=$libSparkFHE_root
    make
    make install
    echo "Installing $CMAKE... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_boost() {
    echo "Installing $BOOST..."
    wget https://dl.bintray.com/boostorg/release/$(echo $BOOST_Version | cut -d'_' -f2,3,4 | tr '_' '.')/source/$BOOST_Version.tar.bz2
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

install_googletest() {
    echo "Installing $GoogleTEST..."
    git clone https://github.com/google/googletest.git $GoogleTEST
    cd $GoogleTEST
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
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
    ./configure --prefix=$libSparkFHE_root --exec-prefix=$libSparkFHE_root
    make; make install
    echo "Installing $SWIG... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_rapidjson() {
    echo "Installing $RapidJSON..."
    git clone https://github.com/Tencent/rapidjson.git $RapidJSON
    cd $RapidJSON
    $CMAKE_EXE -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root -DRAPIDJSON_HAS_STDSTRING=ON .
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
    ./configure --prefix=$libSparkFHE_root --exec-prefix=$libSparkFHE_root
    make; make install
    echo "Installing $GMP... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_gf2x() {
    wget https://gforge.inria.fr/frs/download.php/file/36934/$GF2X_Version.tar.gz
    tar -xf $GF2X_Version.tar.gz
    rm $GF2X_Version.tar.gz
    mv $GF2X_Version GF2X
    cd GF2X
    ./configure ABI=64 CFLAGS="-m64 -O2 -fPIC" --prefix=$libSparkFHE_root
    make CXX=$CPPcompiler
    make CXX=$CPPcompiler tune-lowlevel
    make CXX=$CPPcompiler tune-toom
    make CXX=$CPPcompiler check
    make CXX=$CPPcompiler install
    echo "Installing $GF2X... (DONE)"
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
    ./configure TUNE=x86 NTL_GF2X_LIB=on DEF_PREFIX=$libSparkFHE_root NTL_THREADS=on NTL_THREAD_BOOST=on NTL_GMP_LIP=on NATIVE=off CXX=$CPPcompiler
    make CXX=$CPPcompiler CXXFLAGS="-fPIC -O3"
    make install
    echo "Installing $NTL... (DONE)"
    cd ..
    touch $Marker # add the marker
    cd ..
}

install_armadillo() {
    echo "Installing $ARMADILLO..."
    wget https://sourceforge.net/projects/arma/files/$ARMADILLO_Version.tar.xz
    tar xf $ARMADILLO_Version.tar.xz
    rm $ARMADILLO_Version.tar.xz
    mv $ARMADILLO_Version $ARMADILLO
    cd $ARMADILLO
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make; make install
    echo "Installing $ARMADILLO... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_helib() {
    echo "Installing $HElib..."
    git clone https://github.com/SpiRITlab/HElib.git $HElib
    cd $HElib
    git checkout master-SparkFHE
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make CC=$GCCcompiler LD=$CPPcompiler LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
    mkdir -p $libSparkFHE_include/HElib/
    cp src/*.h $libSparkFHE_include/HElib/
    cp lib/libfhe.a $libSparkFHE_lib/libfhe.a
    echo "Installing $HElib... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_gsl() {
    echo "Installing $GSL..."
    git clone https://github.com/SpiRITlab/GSL.git $GSL
    cd $GSL
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root --build .
    make CC=$GCCcompiler LD=$CPPcompiler LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
    make install
    echo "Installing $GSL... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_zlib() {
    echo "Installing $ZLIB..."
    git clone https://github.com/SpiRITlab/zlib.git $ZLIB
    cd $ZLIB
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make CC=$GCCcompiler LD=$CPPcompiler LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
    make install
    echo "Installing $ZLIB... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_base64() {
    echo "Installing $BASE64..."
    git clone https://github.com/SpiRITlab/libb64.git $BASE64
    cd $BASE64
    make
    cp -r include/b64/ $libSparkFHE_include/b64
    cp src/libb64.a $libSparkFHE_lib
    cp base64/base64 $libSparkFHE_bin
    echo "Installing $BASE64... (DONE)"
    touch $Marker # add the marker
    cd ..
}

install_seal() {
    echo "Installing $SEAL..."
    git clone https://github.com/microsoft/SEAL.git $SEAL
    cd $SEAL
    git checkout $SEAL_Version
    cd native/src
    $CMAKE_EXE -DCMAKE_CXX_COMPILER=$CPPcompiler -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root -DMSGSL_ROOT=../../../$GSL/include -DZLIB_ROOT=../../../$ZLIB .
    make CC=$GCCcompiler LD=$CPPcompiler LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
    make install
    echo "Installing $SEAL... (DONE)"
    cd ../..
    touch $Marker # add the marker
    cd ..
}

install_awssdk() {
    echo "Installing $AWSSDK..."
    git clone https://github.com/aws/aws-sdk-cpp.git $AWSSDK
    cd $AWSSDK;
    $CMAKE_EXE -DCMAKE_BUILD_TYPE=Debug -DBUILD_ONLY="s3" -DCMAKE_INSTALL_PREFIX=$libSparkFHE_root .
    make CC=$GCCcompiler LD=$CPPcompiler LDLIBS+=-L$libSparkFHE_lib CFLAGS+=-I$libSparkFHE_include CFLAGS+=-fPIC
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
    echo "	cd $DEPS_PATH/$HDFS/"
    echo "	sudo bash start-build-env.sh"
    echo "This will prepare a Hadoop development environment in a docker container. In this container, use maven to compile Hadoop packages."
    echo "	mvn package -Pdist,native -DskipTests"
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
        cp -Rn ${hdfs_pkg}/target/${hdfs_pkg}-${HDFS_GIT_VERSION}/* $libSparkFHE_root/
    done
    set_trap

    # compile hadoop-common source code
    cd ../hadoop-common-project
    set +e
    ## declare an array variable
    declare -a hadoop_common_pkgs=( hadoop-common )
    for common_pkg in "${hadoop_common_pkgs[@]}"; do
        echo "Copying compiled files from ${common_pkg}..."
        cp -Rn ${common_pkg}/target/${common_pkg}-${HDFS_GIT_VERSION}/* $libSparkFHE_root/
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
        cp -Rn ${hdfs_pkg}/target/${hdfs_pkg}-${HADOOP_Version:7}/* $libSparkFHE_root/
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
        cp -Rn ${common_pkg}/target/${common_pkg}-3.1.2/* $libSparkFHE_root/
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

CMAKE="CMAKE"
CMAKE_EXE=$libSparkFHE_bin/cmake
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

# Boost is a set of libraries for the C++ programming language that provide
# support for tasks and structures such as linear algebra, pseudorandom number
# generation, multithreading, image processing, regular expressions, and unit
# testing.
BOOST="BOOST"
if [ -d $BOOST ]; then
    if [ ! -f $BOOST/$Marker ]; then
        rm -rf $BOOST # remove the folder
        install_boost
    else
        echo "$BOOST library already installed"
    fi
else
    install_boost
fi

# Google Test is a unit testing library for the C++ programming language,
# based on the xUnit architecture.
GoogleTEST="GoogleTEST"
if [ -d $GoogleTEST ]; then
    if [ ! -f $GoogleTEST/$Marker ]; then
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

# gf2x is a C/C++ software package containing routines for fast arithmetic
# in GF(2)[x] (multiplication, squaring, GCD) and searching for
# irreducible/primitive trinomials.
GF2X="GF2X"
if [ -d $GF2X ]; then
    if [ ! -f $GF2X/$Marker ]; then
        rm -rf $GF2X # remove the folder
        install_gf2x
    else
        echo "$GF2X already installed"
    fi
else
    install_gf2x
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

# Armadillo is a linear algebra software library for the C++.
ARMADILLO="ARMADILLO"
if [ -d $ARMADILLO ]; then
    if [ ! -f $ARMADILLO/$Marker ]; then
        rm -rf $ARMADILLO # remove the folder
        install_armadillo
    else
        echo "$ARMADILLO already installed"
    fi
else
    install_armadillo
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


# https://www.microsoft.com/en-us/research/project/simple-encrypted-arithmetic-library/
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



if [ "$Enable_HDFS" = true ] ; then
    echo
    echo '------------------------------------------------------------------------'
    echo "You need to set these envrionment variables in your ~/.bashrc file."
    echo "========================================================================"
    echo 'export JAVA_HOME=<your java installation path>'
    echo 'export HADOOP_HOME=`pwd`/libSparkFHE'
    echo 'export HADOOP_YARN_HOME=$HADOOP_HOME'
    echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME'
    echo 'export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin'
    echo 'export HADOOP_CLASSPATH=$(find $HADOOP_HOME -name "*.jar" | xargs echo | tr " " ":")'
    echo 'export CLASSPATH=$CLASSPATH:$HADOOP_CLASSPATH'
    echo "========================================================================"
fi

trap EXIT
