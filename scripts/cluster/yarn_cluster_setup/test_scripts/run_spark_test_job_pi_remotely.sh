#!/bin/bash

MASTER_HOSTNAME=master
CLIENT_HOSTNAME=client

if [[ `hostname` == *${CLIENT_HOSTNAME}* ]]; then
	echo "Commands running from correct node"
	ssh $MASTER_HOSTNAME '
		source /etc/profile

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
	'
else
	echo "This code can run ONLY on Client Node"
fi
