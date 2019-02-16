#!/bin/bash

# root_folder_name=/yarn-spark-cluster
# HADOOP_HOME=$root_folder_name/hadoop
# SPARK_HOME=$root_folder_name/spark
# HADOOP_SSH_OPTS="-i ~/.ssh/id_rsa"

echo -e "Stopping Spark Cluster"

/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/stop-all.sh

echo -e "Stopping Hadoop Cluster"

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver

/usr/local/hadoop/sbin/stop-dfs.sh

/usr/local/hadoop/sbin/stop-yarn.sh

# rm -rf $root_folder_name/hdfs/datanode/*

# rm -rf $root_folder_name/hdfs/namenode/*

# sudo rm -R /tmp/*
# sudo rm -rf /app/hadoop/tmp || true