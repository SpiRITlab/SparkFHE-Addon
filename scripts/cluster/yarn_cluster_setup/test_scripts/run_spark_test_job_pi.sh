#!/bin/bash

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

echo "Stop Cluster If not in Use"