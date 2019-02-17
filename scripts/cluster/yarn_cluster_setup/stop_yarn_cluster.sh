#!/bin/bash

echo -e "Stopping Spark Cluster"

/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/stop-all.sh

echo -e "Stopping Hadoop Cluster"

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver

/usr/local/hadoop/sbin/stop-dfs.sh

/usr/local/hadoop/sbin/stop-yarn.sh