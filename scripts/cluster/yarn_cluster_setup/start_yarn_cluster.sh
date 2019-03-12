#!/bin/bash

MASTER_HOSTNAME=master
CLIENT_HOSTNAME=client

if [[ `hostname` == *${CLIENT_HOSTNAME}* ]]; then
	echo "Commands running from correct node"
	ssh $MASTER_HOSTNAME '
		source /etc/profile

		echo "STARTING HADOOP SERVICES"

		$HADOOP_HOME/sbin/start-dfs.sh

		$HADOOP_HOME/sbin/start-yarn.sh

		$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

		$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

		echo "STARTING SPARK SERVICES"
		$SPARK_HOME/sbin/start-all.sh

		echo "RUN jps - Java Virtual Machine Process Status Tool"
		jps

		echo "Get basic filesystem information and statistics."
		$HADOOP_HOME/bin/hdfs dfsadmin -report

		echo "Yarn Cluster is Active"

		echo "Follow the instructions for Web Interfaces specified in the Readme page"

		master_node_ip_address_internal=`hostname -I | sed "'"s/\s.*$//"'"`

		echo "YARN Interface Available At: "$master_node_ip_address_internal":8088/"
		echo "Spark Interface Available At: "$master_node_ip_address_internal":8080/"
		echo "NameNode Interface Available At: "$master_node_ip_address_internal":50070/"
		echo "Job Master Interface Available At: "$master_node_ip_address_internal":19888/"
	'
else
	echo "This code can run ONLY on Client Node"
fi
