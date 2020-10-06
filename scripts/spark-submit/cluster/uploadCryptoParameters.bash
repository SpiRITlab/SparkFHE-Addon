#!/bin/bash

SparkDist=spark-3.1.0-SNAPSHOT-bin-SparkFHE
HDFSCommand=/$SparkDist/hadoop/bin/hdfs

$HDFSCommand dfs -mkdir -p /SparkFHE/HDFSFolder/SparkFHE-Addon/resources/
$HDFSCommand dfs -put /$SparkDist/SparkFHE-Addon/resources/params /SparkFHE/HDFSFolder/SparkFHE-Addon/resources/
