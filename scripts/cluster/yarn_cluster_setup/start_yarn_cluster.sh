#!/bin/bash

echo "STARTING HADOOP SERVICES"

$HADOOP_HOME/sbin/start-dfs.sh

$HADOOP_HOME/sbin/start-yarn.sh

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

echo "STARTING SPARK SERVICES"
SPARK_HOME/sbin/start-all.sh

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
$HADOOP_HOME/bin/hdfs dfsadmin -report

echo "Yarn Cluster is Active"

master_node_ip_address=`hostname -i`

echo "YARN Interface Available At: "$master_node_ip_address":8088/"
echo "Spark Interface Available At: "$master_node_ip_address":8080/"
echo "NameNode Interface Available At: "$master_node_ip_address":50070/"
echo "Job Master Interface Available At: "$master_node_ip_address":19888/"