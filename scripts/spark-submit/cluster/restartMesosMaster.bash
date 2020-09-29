#!/bin/bash

SparkDistribution=/spark-3.1.0-SNAPSHOT-bin-SparkFHE

systemctl daemon-reload
systemctl restart mesos-master
systemctl restart zookeeper
systemctl restart spark


/$SparkDistribution/hadoop/sbin/stop-dfs.sh
/$SparkDistribution/hadoop/sbin/start-dfs.sh