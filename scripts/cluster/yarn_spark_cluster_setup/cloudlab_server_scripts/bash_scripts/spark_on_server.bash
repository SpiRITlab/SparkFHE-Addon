#!/usr/bin/env bash

base_address=`dirname "$(realpath $0)"`
variables_address=${base_address}/include_variables.bash
source $variables_address

server_name=`hostname`
if [[ $server_name == *"master"* ]]; then
  	echo "Script Running on Master"
	bash $HADOOP_HOME/stop_spark_hadoop_cluster.sh
	bash $HADOOP_HOME/start_spark_hadoop_cluster.sh
	bash $HADOOP_HOME/run_spark_job.sh
	bash $HADOOP_HOME/stop_spark_hadoop_cluster.sh
else
	echo "Worker Nodes cannot run this script"
fi


