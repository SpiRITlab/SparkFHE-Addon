#!/usr/bin/env bash

Current_Dir=`pwd`
Scripts_Dir=$(dirname $Current_Dir)
source "$Scripts_Dir/cloudlab/include_functions.bash" "$Scripts_Dir"

default_master_node_ip=128.105.145.139
default_sparkfhe_path=/spark-3.0.0-SNAPSHOT-bin-SparkFHE


function init_master() {
	# update ip address on mesos master and restart services
	$SSH $MyUserName@${cluster_nodes[0]} "
		sudo sed \"s/$default_master_node_ip/${cluster_nodes_ip[0]}/g\" /etc/systemd/system/mesos-master.service > /tmp/mesos-master.service && \
		sudo mv /tmp/mesos-master.service /etc/systemd/system/mesos-master.service && \
		sudo sed \"s/$default_master_node_ip/${cluster_nodes_ip[0]}/g\" /etc/systemd/system/spark.service > /tmp/spark.service && \
		sudo mv /tmp/spark.service /etc/systemd/system/spark.service && \
		sudo sed \"s/NAME=zookeeper/NAME=root/g\" /etc/rc0.d/K01zookeeper > /tmp/K01zookeeper && \
		sudo mv /tmp/K01zookeeper /etc/rc0.d/K01zookeeper && \
		sudo systemctl daemon-reload && \
		sudo systemctl enable zookeeper && \
		sudo systemctl enable mesos-master && \
		sudo systemctl restart mesos-master.service && \
		sudo systemctl restart zookeeper.service && \
		sudo systemctl restart spark && \
		sudo /spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop/sbin/stop-dfs.sh && \
		sudo rm -rf /hdfs/* && \
		sudo $default_sparkfhe_path/hadoop/bin/hdfs namenode -format && \
		sudo $default_sparkfhe_path/hadoop/sbin/start-dfs.sh && \
		cd $default_sparkfhe_path/SparkFHE-Addon && git pull" 
}



function init_worker() {
	for ((idx=1; idx<${#cluster_nodes[@]}; ++idx)); do
		# remove mesos master stuffs
		$SSH $MyUserName@${cluster_nodes[idx]} "
			sudo apt -y remove zookeeper && \
			sudo systemctl stop mesos-master.service && sudo systemctl diable mesos-master && \
			sudo rm -rf /etc/systemd/system/mesos-master.service /etc/systemd/system/spark.service /etc/mesos-master"

		# upload mesos slave files
		scp -r config/* $MyUserName@${cluster_nodes[idx]}:/tmp/

		# configure mesos master stuffs and restart services
		$SSH $MyUserName@${cluster_nodes[idx]} "
			sudo mv /tmp/mesos-slave.service /etc/systemd/system/mesos-slave.service && \
			sudo mkdir -p /etc/mesos-slave && sudo mv /tmp/master /etc/mesos-slave/ && \
			sudo systemctl daemon-reload && \
			sudo systemctl enable mesos-slave && \
			sudo systemctl restart mesos-slave.service && \
			sudo rm -rf /hdfs/* && \
			cd $default_sparkfhe_path/SparkFHE-Addon && git pull && \
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


