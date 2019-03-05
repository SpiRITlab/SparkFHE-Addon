#!/bin/bash

current_hostname=`hostname`
source /etc/profile

if [[ $current_hostname == *"client"* ]]; then
	echo "Commands running from correct node"
	ssh $MASTER_HOSTNAME '
		source /etc/profile

		echo -e "STOPPING SPARK SERVICES"

		$SPARK_HOME/sbin/stop-all.sh

		echo -e "STOPPING HADOOP SERVICES"

		$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver

		$HADOOP_HOME/sbin/stop-dfs.sh

		$HADOOP_HOME/sbin/stop-yarn.sh

		echo "Hadoop Cluster is Inactive Now"
	'
else
	echo "This code can run ONLY on Client Node"
fi
