#!/bin/bash

root_folder_name=/yarn-spark-cluster
HADOOP_HOME=$root_folder_name/hadoop
SPARK_HOME=$root_folder_name/spark

echo "SPARK TEST"
$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi  \
    --master yarn \
    --deploy-mode cluster \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 512m \
    --executor-cores 1 \
    $SPARK_HOME/examples/jars/spark-examples*.jar \
    10