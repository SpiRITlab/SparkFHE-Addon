#!/bin/bash

echo "SPARK TEST"
/usr/local/spark/bin/spark-submit --class org.apache.spark.examples.SparkPi  \
    --master yarn \
    --deploy-mode cluster \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 512m \
    --executor-cores 1 \
    /usr/local/spark/examples/jars/spark-examples*.jar \
    10