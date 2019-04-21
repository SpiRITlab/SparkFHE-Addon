#!/bin/bash

# Master, Client Name depends on cluster config
# If cluster config changes, the variable values should change
client_name=client
master_name=master
MASTER_HOSTNAME=`ssh root@$master_name "hostname -i"`
current_hostname=`hostname`

if [[ $current_hostname == *$client_name* ]]; then
	echo "Commands running from correct node"
	ssh root@$MASTER_HOSTNAME '
		source /etc/profile

		echo -e "STOPPING SPARK SERVICES"
		$SPARK_HOME/sbin/stop-history-server.sh
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
