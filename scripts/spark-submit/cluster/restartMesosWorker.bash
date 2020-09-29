#!/bin/bash

SparkDistribution=/spark-3.1.0-SNAPSHOT-bin-SparkFHE

systemctl daemon-reload
systemctl restart mesos-slave

mkdir -p /tmp/spark-events
bash $SparkDistribution/sbin/stop-history-server.sh
bash $SparkDistribution/sbin/start-history-server.sh