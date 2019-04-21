#!/bin/bash

# Master, Client Name depends on cluster config
# If cluster config changes, the variable values should change
client_name=client
master_name=master
MASTER_HOSTNAME=`ssh root@$master_name "hostname -i"`
current_hostname=`hostname`

if [[ $current_hostname == *"client"* ]]; then
	echo "Commands running from correct node"
	ssh root@$MASTER_HOSTNAME '
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
