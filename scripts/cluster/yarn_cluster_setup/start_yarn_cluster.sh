#!/bin/bash

echo "STARTING HADOOP SERVICES"

/usr/local/hadoop/sbin/start-dfs.sh

/usr/local/hadoop/sbin/start-yarn.sh

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

# /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

# /usr/local/hadoop/bin/hdfs dfsadmin

echo "STARTING SPARK SERVICES"
/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/start-all.sh

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
/usr/local/hadoop/bin/hdfs dfsadmin -report

echo "Yarn Cluster is Active"

master_node_ip_address=`hostname -i`

echo "YARN Interface Available At: "$master_node_ip_address":8088/"
echo "Spark Interface Available At: "$master_node_ip_address":8080/"
echo "NameNode Interface Available At: "$master_node_ip_address":50070/"
echo "Job Master Interface Available At: "$master_node_ip_address":19888/"