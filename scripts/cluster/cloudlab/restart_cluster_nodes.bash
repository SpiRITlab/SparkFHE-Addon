#!/usr/bin/env bash

Current_Dir=`pwd`
Scripts_Dir=$(dirname $Current_Dir)
source "$Scripts_Dir/cloudlab/include_functions.bash" "$Scripts_Dir"

default_sparkfhe_path=/spark-3.0.0-SNAPSHOT-bin-SparkFHE


function init_master() {
	# update ip address on mesos master and restart services
	$SSH $MyUserName@${cluster_nodes[0]} "
		sudo $default_sparkfhe_path/hadoop/sbin/start-dfs.sh && \
		cd $default_sparkfhe_path/SparkFHE-Addon && sudo git pull" 
}



function init_worker() {
	for ((idx=1; idx<${#cluster_nodes[@]}; ++idx)); do	
		# upload mesos slave files
		scp -r config/* $MyUserName@${cluster_nodes[idx]}:/tmp/

		# configure mesos master stuffs and restart services
		$SSH $MyUserName@${cluster_nodes[idx]} "
			cd $default_sparkfhe_path/SparkFHE-Addon && sudo git pull && \
			nohup bash $default_sparkfhe_path/sbin/start-history-server.sh &"
	done 
}





get_nodes_info
echo "Configuring the following cluster nodes..."
print_list_of_nodes

setup_cluster_nodes

authorize_access_between_nodes

# init worker first for HDFS
init_worker
init_master

