#!/bin/sh

JAVA_HOME_INFILE=/usr/lib/jvm/default-java/
HADOOP_DATA=/data/hadoop/
HADOOP_HOME_INFILE=/usr/local/hadoop/
HADOOP_SYMLINK=/usr/local/hadoop
HADOOP_CONFIG_LOCATION=${HADOOP_HOME_INFILE}etc/hadoop/
HADOOP_VERSION=2.9.2
HADOOP_WEB_SOURCE=https://www-us.apache.org/dist/hadoop/common/
ROOT_VARIABLES_ADDRESS=/etc/profile

# Install Pre-Reqs
apt-get update -y
apt-get install -y python default-jdk wget

# Remove Any Existing Hadoop Version and Data Directory
unlink ${HADOOP_SYMLINK} && rm -rf ${HADOOP_DATA}
rm -rf /usr/local/hadoop-*/

# Remove Global Variables
sed -i /JAVA_HOME/d $ROOT_VARIABLES_ADDRESS && sed -i /default-java/d $ROOT_VARIABLES_ADDRESS
sed -i /HADOOP_HOME/d $ROOT_VARIABLES_ADDRESS && sed -i /hadoop/d $ROOT_VARIABLES_ADDRESS

# Make Hadoop Global Variables for User and Root
echo "export JAVA_HOME="$JAVA_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export PATH=$PATH:"$JAVA_HOME_INFILE"bin/:"$JAVA_HOME_INFILE"sbin/" >> $ROOT_VARIABLES_ADDRESS
echo "export HADOOP_HOME="$HADOOP_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export HADOOP_MAPRED_HOME="$HADOOP_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export HADOOP_COMMON_HOME="$HADOOP_HOME_INFILE>> $ROOT_VARIABLES_ADDRESS
echo "export HADOOP_HDFS_HOME="$HADOOP_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export YARN_HOME="$HADOOP_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export HADOOP_COMMON_LIB_NATIVE_DIR="$HADOOP_HOME_INFILE"lib/native" >> $ROOT_VARIABLES_ADDRESS
echo "export PATH=$PATH:"$HADOOP_HOME_INFILE"bin/:"$HADOOP_HOME_INFILE"sbin/" >> $ROOT_VARIABLES_ADDRESS
source $ROOT_VARIABLES_ADDRESS

# Make Data Directories for Hadoop
mkdir -p ${HADOOP_DATA}name
mkdir -p ${HADOOP_DATA}data
mkdir -p ${HADOOP_DATA}node

current_directory=`pwd`

# Download Hadoop Tar
if [ ! -f "${current_directory}/hadoop-$HADOOP_VERSION.tar.gz" ]; then
	echo "Downloading Hadoop ${HADOOP_VERSION} ..."
	sudo wget ${HADOOP_WEB_SOURCE}hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
    echo "Download of Hadoop ${HADOOP_VERSION} Successful!"
fi

# Unzip and Install Hadoop Tar
tar -xzf $current_directory/hadoop-$HADOOP_VERSION.tar.gz -C /usr/local/

rm $current_directory/hadoop-$HADOOP_VERSION.tar.gz

# Make Symbolic link
ln -s /usr/local/hadoop-$HADOOP_VERSION/ $HADOOP_SYMLINK

# Copy Hadoop Config Files
cp -a $current_directory/configs/hadoop/. $HADOOP_CONFIG_LOCATION
cp $current_directory/configs/master $HADOOP_CONFIG_LOCATION
cp $current_directory/configs/slaves $HADOOP_CONFIG_LOCATION

echo "Hadoop Installation Complete on this node"

SPARK_HOME_INFILE=`cd ${current_directory}/../../../.. && pwd`

SPARK_CONFIG_LOCATION=$SPARK_HOME_INFILE/conf/

# Remove Spark Global Variables
sed -i /SPARK_HOME/d $ROOT_VARIABLES_ADDRESS && sed -i /spark/d $ROOT_VARIABLES_ADDRESS

# Make Spark Global Variables for User and Root
echo "export SPARK_HOME="$SPARK_HOME_INFILE >> $ROOT_VARIABLES_ADDRESS
echo "export PATH=$PATH:"$SPARK_HOME_INFILE"/bin/" >> $ROOT_VARIABLES_ADDRESS
source $ROOT_VARIABLES_ADDRESS

# Copy Spark Config Files
cp -a $current_directory/configs/spark/. $SPARK_CONFIG_LOCATION
cp -a $current_directory/configs/hadoop/. $SPARK_CONFIG_LOCATION
cp $current_directory/configs/master $SPARK_CONFIG_LOCATION
cp $current_directory/configs/slaves $SPARK_CONFIG_LOCATION

# Format Namenode
$HADOOP_HOME_INFILE/bin/hdfs namenode -format