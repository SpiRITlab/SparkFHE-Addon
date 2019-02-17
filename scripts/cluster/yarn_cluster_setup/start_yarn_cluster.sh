#!/bin/bash

echo "STARTING HADOOP SERVICES"
/usr/local/hadoop/sbin/start-dfs.sh

/usr/local/hadoop/sbin/start-yarn.sh

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

/usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

echo "STARTING SPARK SERVICES"
/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/start-all.sh
# scala -version

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
/usr/local/hadoop/bin/hdfs dfsadmin -report