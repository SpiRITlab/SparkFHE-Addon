#!/usr/bin/env bash

root_folder_in_server=/yarn-spark-cluster

# Setting the number of nodes in the cluster
TOTAL_NODES_IN_CLUSTER=3

mirrorServer=https://www-us.apache.org/dist/
hadoopVersion=2.8.5
sparkVersion=2.3.2
hadoopForSpark=2.7

HADOOP_HOME=$root_folder_in_server/hadoop

SPARK_HOME=$root_folder_in_server/spark

user_group=iotx-PG0