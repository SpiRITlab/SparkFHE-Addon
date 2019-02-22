#!/bin/bash

echo -e "STOPPING SPARK SERVICES"

$SPARK_HOME/sbin/stop-all.sh

echo -e "STOPPING HADOOP SERVICES"

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver

$HADOOP_HOME/sbin/stop-dfs.sh

$HADOOP_HOME/sbin/stop-yarn.sh

echo "Hadoop Cluster is Inactive Now"