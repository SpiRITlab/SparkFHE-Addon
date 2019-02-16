#!/bin/bash

echo "SPARK TEST"
/spark-3.0.0-SNAPSHOT-bin-SparkFHE/bin/spark-submit --class org.apache.spark.examples.SparkPi  \
    --master yarn \
    --deploy-mode cluster \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 512m \
    --executor-cores 1 \
    /spark-3.0.0-SNAPSHOT-bin-SparkFHE/examples/jars/spark-examples*.jar \
    10