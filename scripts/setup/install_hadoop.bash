#!bin/bash

NUM_OF_WORKERS=2
INSTALLATION_PATH=/usr/local/
HDFS_DATA_DIR=/var/tmp/hdfs
HADOOP_FOLDER_NAME=hadoop
HADOOP_VERSION="3.3.0-SNAPSHOT"
HADOOP_GIT_REPO="https://github.com/SpiRITlab/hadoop.git"
CURRENT_PATH=`pwd`

function add_property {
    name=$1
    value=$2
    file=$3

    xmlstarlet ed -L \
    	-s '/configuration' -t elem -n property --var new-field '\$prev' \
        -s '\$new-field' -t elem -n name -v $name \
        -s '\$new-field' -t elem -n value -v $value \
        $file
}


echo "Compiling and installing $HADOOP_FOLDER_NAME-$HADOOP_VERSION..."

read -p "Where do you want to install hadoop? (default: $INSTALLATION_PATH):" Specified_Path
if [ -d $Specified_Path ] ; then
	INSTALLATION_PATH=$Specified_Path
fi

cd ../../../
HADOOP_SRC_FOLDER=`pwd`
if [ -d $HADOOP_FOLDER_NAME ] ; then
	cd $HADOOP_FOLDER_NAME
	git pull
else
	git clone $HADOOP_GIT_REPO $HADOOP_FOLDER_NAME
	cd $HADOOP_FOLDER_NAME
fi

bash start-build-env.sh sudo mvn package -Pdist,native -DskipTests -Dtar

tar -xzf hadoop-dist/target/$HADOOP_FOLDER_NAME-$HADOOP_VERSION.tar.gz -C $INSTALLATION_PATH/
ln -s $INSTALLATION_PATH/$HADOOP_FOLDER_NAME-$HADOOP_VERSION $INSTALLATION_PATH/$HADOOP_FOLDER_NAME
HADOOP_HOME=$INSTALLATION_PATH/$HADOOP_FOLDER_NAME

# Create HDFS directory
mkdir -p $HDFS_DATA_DIR
mkdir -p $HDFS_DATA_DIR/namenode
mkdir -p $HDFS_DATA_DIR/datanode
mkdir -p $HDFS_DATA_DIR/tmp


# hdfs-site.xml
PropertyXMLFile=$HADOOP_HOME/etc/hadoop/hdfs-site.xml
add_property dfs.replication \
	1 \
	$PropertyXMLFile
add_property dfs.namenode.datanode.registration.ip-hostname-check \
	false \
	$PropertyXMLFile
add_property dfs.namenode.name.dir \
	file://$HDFS_DATA_DIR/namenode \
	$PropertyXMLFile
add_property dfs.datanode.data.dir \
	file:/hdfs/datanode \
    $PropertyXMLFile

# core-site.xml
PropertyXMLFile=$HADOOP_HOME/etc/hadoop/core-site.xml
add_property fs.defaultFS \
	hdfs://master \
	$PropertyXMLFile
add_property hadoop.tmp.dir \
    $HDFS_DATA_DIR/tmp \
	$PropertyXMLFile

# yarn-site.xml
PropertyXMLFile=$HADOOP_HOME/etc/hadoop/yarn-site.xml
add_property yarn.nodemanager.aux-services \
	mapreduce_shuffle \
	$PropertyXMLFile
add_property yarn.nodemanager.aux-services.mapreduce.shuffle.class \
	org.apache.hadoop.mapred.ShuffleHandler \
	$PropertyXMLFile

# mapred-site.xml
PropertyXMLFile=$HADOOP_HOME/etc/hadoop/mapred-site.xml
add_property mapred.framework.name \
	yarn \
	$PropertyXMLFile
add_property mapreduce.jobhistory.address \
	0.0.0.0:10020 \
	$PropertyXMLFile


rm -rf $HADOOP_HOME/etc/hadoop/workers
for i in $(seq 1 $NUM_OF_WORKERS); do 
	echo "worker$i" >> $HADOOP_HOME/etc/hadoop/workers
done


echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo 'export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo 'export HADOOP_HOME_WARN_SUPPRESS="TRUE"' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo 'export HADOOP_ROOT_LOGGER="WARN,DRFA"' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo 'export HDFS_NAMENODE_USER=root' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh











