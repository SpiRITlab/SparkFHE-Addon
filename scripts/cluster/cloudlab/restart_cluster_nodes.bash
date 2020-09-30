#!/usr/bin/env bash

Current_Dir=`pwd`
Scripts_Dir=$(dirname $Current_Dir)
source "$Scripts_Dir/cloudlab/include_functions.bash" "$Scripts_Dir"

default_sparkfhe_path=/spark-3.1.0-SNAPSHOT-bin-SparkFHE


function init_master() {
	# update ip address on mesos master and restart services
	$SSH $MyUserName@${cluster_nodes_ip[0]} "
		cd $default_sparkfhe_path/SparkFHE-Addon && sudo git pull && \
		sudo bash $default_sparkfhe_path/SparkFHE-Addon/scripts/cluster/mesos_cluster_management/restartMesosMaster.bash" 
}



function init_worker() {
	for ((idx=1; idx<${#cluster_nodes_ip[@]}; ++idx)); do	
		# upload mesos slave files
		scp -r config/* $MyUserName@${cluster_nodes_ip[idx]}:/tmp/

		# configure mesos master stuffs and restart services
		$SSH $MyUserName@${cluster_nodes_ip[idx]} "
			cd $default_sparkfhe_path/SparkFHE-Addon && sudo git pull && \
			sudo bash $default_sparkfhe_path/SparkFHE-Addon/scripts/cluster/mesos_cluster_management/restartMesosWorker.bash"
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


