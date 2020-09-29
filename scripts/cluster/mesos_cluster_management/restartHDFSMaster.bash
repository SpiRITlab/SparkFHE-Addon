#!/bin/bash

SparkDistribution=/spark-3.1.0-SNAPSHOT-bin-SparkFHE

/$SparkDistribution/hadoop/sbin/stop-dfs.sh
/$SparkDistribution/hadoop/sbin/start-dfs.sh