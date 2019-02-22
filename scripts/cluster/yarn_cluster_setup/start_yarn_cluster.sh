#!/bin/bash

export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/spark/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native/

echo "STARTING HADOOP SERVICES"
/usr/local/hadoop/sbin/start-dfs.sh

/usr/local/hadoop/sbin/start-yarn.sh

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

/usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

echo "STARTING SPARK SERVICES"
/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/start-all.sh

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
/usr/local/hadoop/bin/hdfs dfsadmin -report

echo "Yarn Cluster is Active"