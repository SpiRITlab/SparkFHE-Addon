#!/bin/sh

JAVA_HOME_INFILE=/usr/lib/jvm/default-java/
HADOOP_DATA=/data/hadoop/
HADOOP_HOME_INFILE=/usr/local/hadoop/
HADOOP_SYMLINK=/usr/local/hadoop
HADOOP_CONFIG_LOCATION=${HADOOP_HOME_INFILE}etc/hadoop/
HADOOP_VERSION=2.9.2
HADOOP_WEB_SOURCE=http://apache.claz.org/hadoop/common/
GLOBAL_VARIABLES_SOURCE=/etc/environment

# Install Pre-Reqs
apt-get update -y
apt-get install -y python default-jdk maven curl python-pip
pip install pyhdfs

# Remove Any Existing Hadoop Version and Data Directory
unlink ${HADOOP_SYMLINK} && rm -rf ${HADOOP_DATA}
rm -rf /usr/local/hadoop-*/

# Make Data Directories for Hadoop
mkdir -p ${HADOOP_DATA}name
mkdir -p ${HADOOP_DATA}data
mkdir -p ${HADOOP_DATA}node

# Download Hadoop Tar
if [ ! -f "hadoop-$HADOOP_VERSION.tar.gz" ]; then
	echo "Downloading Hadoop ${HADOOP_VERSION} ..."
    curl ${HADOOP_WEB_SOURCE}hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz > /hadoop-${HADOOP_VERSION}.tar.gz
    echo "Download of Hadoop ${HADOOP_VERSION} Successful!"
fi

# Unzip and Install Hadoop Tar
tar -xzf /hadoop-$HADOOP_VERSION.tar.gz -C /usr/local/

# Make Symbolic link
ln -s /usr/local/hadoop-$HADOOP_VERSION/ $HADOOP_SYMLINK

# Copy Config Files

current_directory=`pwd`

cp -a $current_directory/configs/hadoop/. $HADOOP_CONFIG_LOCATION
cp $current_directory/configs/master $HADOOP_CONFIG_LOCATION
cp $current_directory/configs/slaves $HADOOP_CONFIG_LOCATION

echo "Hadoop Installation Complete on this node"

SPARK_HOME_INFILE=`cd ${current_directory}/../../../.. && pwd`

SPARK_CONFIG_LOCATION=$SPARK_HOME_INFILE/conf/

cp -a $current_directory/configs/spark/. $SPARK_CONFIG_LOCATION
cp -a $current_directory/configs/hadoop/. $SPARK_CONFIG_LOCATION
cp $current_directory/configs/master $SPARK_CONFIG_LOCATION
cp $current_directory/configs/slaves $SPARK_CONFIG_LOCATION

# Format Namenode
/usr/local/hadoop/bin/hdfs namenode -format