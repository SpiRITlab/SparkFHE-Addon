#!/usr/bin/env bash

base_address=`dirname "$(realpath $0)"`
variables_address=${base_address}/include_variables.bash
source $variables_address

# # Make Slaves File
# # Just lists all slave node names in a file
# i=1
# rm $root_folder_in_server/config/slaves

# while [ $i -lt $TOTAL_NODES_IN_CLUSTER ]
# do
# 	echo "worker$i" >> $root_folder_in_server/config/slaves
# 	((i++))
# done 

# Install and Move Hadoop
# wget ${mirrorServer}hadoop/common/hadoop-${hadoopVersion}/hadoop-${hadoopVersion}.tar.gz
tar -xzf hadoop-${hadoopVersion}.tar.gz --directory $HOME
# rm hadoop-${hadoopVersion}.tar.gz
rm -rf ${HADOOP_HOME} || true
mv $HOME/hadoop-${hadoopVersion} ${HADOOP_HOME}

# wget ${mirrorServer}spark/spark-${sparkVersion}/spark-${sparkVersion}-bin-hadoop${hadoopForSpark}.tgz
tar -xzf spark-${sparkVersion}-bin-hadoop${hadoopForSpark}.tgz --directory $HOME
# rm spark-${sparkVersion}-bin-hadoop${hadoopForSpark}.tgz
rm -rf ${SPARK_HOME} || true
mv $HOME/spark-$sparkVersion-bin-hadoop$hadoopForSpark ${SPARK_HOME}

# Make Namenode and datanode folders
mkdir -p $root_folder_in_server/hdfs/namenode
mkdir -p $root_folder_in_server/hdfs/datanode
mkdir -p $root_folder_in_server/hadoop/logs

# Set Permissions for namenode and datanode folder
chmod 777 $root_folder_in_server/hdfs/namenode
chmod 777 $root_folder_in_server/hdfs/datanode

# Move Hadoop Config Files
cp $root_folder_in_server/config/hadoop/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cp $root_folder_in_server/config/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp $root_folder_in_server/config/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp $root_folder_in_server/config/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml
cp $root_folder_in_server/config/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
cp $root_folder_in_server/config/slaves $HADOOP_HOME/etc/hadoop/slaves

# move spark config files
cp $HADOOP_HOME/etc/hadoop/slaves $SPARK_HOME/conf/slaves
cp $HADOOP_HOME/etc/hadoop/core-site.xml $SPARK_HOME/conf/core-site.xml
cp $HADOOP_HOME/etc/hadoop/hdfs-site.xml $SPARK_HOME/conf/hdfs-site.xml
cp $HADOOP_HOME/etc/hadoop/yarn-site.xml $SPARK_HOME/conf/yarn-site.xml
cp $root_folder_in_server/config/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh
cp $root_folder_in_server/config/spark/log4j.properties $SPARK_HOME/conf/log4j.properties

# Copy Hadoop Start, Stop and Yarn-Spark Job Scripts
cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/start_spark_hadoop_cluster.sh $HADOOP_HOME/start_spark_hadoop_cluster.sh
cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/run_spark_job.sh $HADOOP_HOME/run_spark_job.sh
cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/stop_spark_hadoop_cluster.sh $HADOOP_HOME/stop_spark_hadoop_cluster.sh

cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/start_hadoop_cluster.sh $HADOOP_HOME/start_hadoop_cluster.sh
cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/run_hadoop_job.sh $HADOOP_HOME/run_hadoop_job.sh
cp $root_folder_in_server/cloudlab_server_scripts/spark_scripts/stop_hadoop_cluster.sh $HADOOP_HOME/stop_hadoop_cluster.sh

# Set Permissions for scripts
chmod 777 $HADOOP_HOME/start_spark_hadoop_cluster.sh
chmod 777 $HADOOP_HOME/run_spark_job.sh
chmod 777 $HADOOP_HOME/stop_spark_hadoop_cluster.sh

chmod 777 $HADOOP_HOME/start_hadoop_cluster.sh
chmod 777 $HADOOP_HOME/run_hadoop_job.sh
chmod 777 $HADOOP_HOME/stop_hadoop_cluster.sh

# Set Permissions for jar
chmod 777 $SPARK_HOME/examples/jars/spark-examples*.jar

# Change Owner for Folder
sudo chown -R $USER:${user_group} $root_folder_in_server/
# sudo chown -R hadoop:iotx-PG0 $root_folder_in_server/hadoop
# sudo chown -R hadoop:iotx-PG0 $root_folder_in_server/hdfs/namenode
# sudo chown -R hadoop:iotx-PG0 $root_folder_in_server/hdfs/namenode
# sudo chown -R pmrane:hadoop $root_folder_in_server/hdfs/namenode
# sudo chown -R pmrane:hadoop $root_folder_in_server/hdfs/datanode