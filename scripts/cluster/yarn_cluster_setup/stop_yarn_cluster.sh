#!/bin/bash

echo -e "STOPPING SPARK SERVICES"

/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/stop-all.sh

echo -e "STOPPING HADOOP SERVICES"

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver

/usr/local/hadoop/sbin/stop-dfs.sh

/usr/local/hadoop/sbin/stop-yarn.sh

echo "Hadoop Cluster is Inactive Now"