#!/bin/bash

root_folder_name=/yarn-spark-cluster
HADOOP_HOME=$root_folder_name/hadoop
SPARK_HOME=$root_folder_name/spark

# HADOOP_SSH_OPTS="-i ~/.ssh/id_rsa"

# export HADOOP_CONF_DIR=/etc/hadoop/conf

sudo rm -R /tmp/* || true
sudo rm -rf /app/hadoop/tmp || true
sudo mkdir -p /app/hadoop/tmp
sudo chown $USER:iotx-PG0 /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp

echo "STARTING HADOOP SERVICES"
$HADOOP_HOME/sbin/start-dfs.sh

$HADOOP_HOME/sbin/start-yarn.sh

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

echo "STARTING SPARK SERVICES"
$SPARK_HOME/sbin/start-all.sh
# scala -version

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
hdfs dfsadmin -report