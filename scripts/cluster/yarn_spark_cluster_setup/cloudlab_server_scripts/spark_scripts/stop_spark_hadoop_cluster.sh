#!/bin/bash

root_folder_name=/yarn-spark-cluster
HADOOP_HOME=$root_folder_name/hadoop
SPARK_HOME=$root_folder_name/spark
# HADOOP_SSH_OPTS="-i ~/.ssh/id_rsa"

echo -e "Stopping Spark Cluster"

$SPARK_HOME/sbin/stop-all.sh

echo -e "Stopping Hadoop Cluster"

$HADOOP_HOME/sbin/stop-dfs.sh

$HADOOP_HOME/sbin/stop-yarn.sh

rm -rf $root_folder_name/hdfs/datanode/*

rm -rf $root_folder_name/hdfs/namenode/*

sudo rm -R /tmp/*
sudo rm -rf /app/hadoop/tmp || true