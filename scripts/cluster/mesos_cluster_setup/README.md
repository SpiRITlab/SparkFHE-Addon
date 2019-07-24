# First time setup procedures
* On all the nodes follow [instructions](https://github.com/SpiRITlab/SparkFHE-Examples/wiki) to setup SparkFHE distribution. Make sure you have gone through all the steps and the mySparkSubmitLocal.bash script runs correctly. Note, if you are setting it up in a cloud environment, you may want to put it in / and change the permission as follow.

   * You may wan to change the permission of the SparkFHE distribution by the following commands.
   ```
   sudo chmod -R g+rw /spark-3.0.0-SNAPSHOT-bin-SparkFHE
   sudo chown -R nobody:iotx-PG0 /spark-3.0.0-SNAPSHOT-bin-SparkFHE
   ```

* Check access between cluster nodes
Ensure that the master node can SSH as root to all other nodes in the cluster. 
On your laptop (outside the cloudlab environment), follow these [instructions](https://github.com/SpiRITlab/SparkFHE-Addon/tree/master/scripts/cluster/cloudlab) to setup the myUsername.txt and Manifest.xml files. You can do these steps in the folder where you installed the SparkFHE distribution.
  * Then, run $> bash authorize_access_between_nodes.bash  to give ssh access between nodes
    You should see messages regarding the authorizing nodes as follow (path and IP address maybe different).
  ```
    Path from include_functions.bash: /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/cloudlab
    Scripts path provided: /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster
    Configuring the following cluster nodes...
      Host: master.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.211
      Host: worker1.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.218
      Host: worker2.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.207
    Authorizing access between nodes...
  ```

* Mesos setup instructions if you DON'T have a Mesos Cluster installed
On the Mesos master node run the following commands as root:
```
cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/mesos_cluster_setup
bash install_mesos_cluster.bash masterHostname,worker1Hostname,worker2Hostname,...
```
 

# Starting the cluster
 
## Precheck before starting
### Check permission
You may wan to change the permission of the SparkFHE distribution by the following commands.
```
sudo chmod -R g+rw /spark-3.0.0-SNAPSHOT-bin-SparkFHE
sudo chown -R nobody:iotx-PG0 /spark-3.0.0-SNAPSHOT-bin-SparkFHE
```

### Check access between cluster nodes
Ensure that the master node can SSH as root to all other nodes in the cluster. 
On your laptop (outside the cloudlab environment), follow these [instructions](https://github.com/SpiRITlab/SparkFHE-Addon/tree/master/scripts/cluster/cloudlab) to setup the myUsername.txt and Manifest.xml files. You can do these steps in the folder where you installed the SparkFHE distribution.
  * Then, run $> bash authorize_access_between_nodes.bash  to give ssh access between nodes
    You should see messages regarding the authorizing nodes as follow (path and IP address maybe different).
  ```
    Path from include_functions.bash: /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/cloudlab
    Scripts path provided: /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster
    Configuring the following cluster nodes...
      Host: master.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.211
      Host: worker1.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.218
      Host: worker2.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.207
    Authorizing access between nodes...
  ```


## Ready to go

### If Mesos cluster is installed, restart relevant services 
On Master node run:
```
sudo systemctl restart mesos-master
sudo systemctl restart zookeeper
sudo systemctl restart spark
```

On Worker nodes run:
```
sudo systemctl restart mesos-slave
```


## If HDFS is installed, you can start and stop it by these commands on the Master node (or namenode for HDFS).
To start HDFS: 
```
sudo /spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop/sbin/start-dfs.sh
```

If you see error message like
```
Starting namenodes on [master]
master: Warning: Permanently added 'master,10.10.1.1' (ECDSA) to the list of known hosts.
Starting datanodes
ERROR: Attempting to operate on hdfs datanode as root
ERROR: but there is no HDFS_DATANODE_USER defined. Aborting operation.
Starting secondary namenodes [master.peiworld-qv55172.iotx-pg0.wisc.cloudlab.us]
ERROR: Attempting to operate on hdfs secondarynamenode as root
ERROR: but there is no HDFS_SECONDARYNAMENODE_USER defined. Aborting operation.
```
You can just export 
```
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
```

To stop HDFS: 
```
sudo /spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop/sbin/stop-dfs.sh
```


# Other useful commands and information
### Check whether the datanode is online:
```
/spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop/bin/hdfs dfsadmin -report
```

### List of important web UI
Mesos Web UI
```
http://[MasterNodeIP]:5050
```

Hadoop HDFS web UI
```
http://[MasterNodeIP]:9870
```
Note, if you don't see the expected number of datanode, check [our wiki page](https://github.com/SpiRITlab/SparkFHE-Addon/wiki/Errors&Fixes). Following [this article](https://blog.usejournal.com/hadoop-3-0-installation-on-ubuntu-18-04-step-by-step-pseudo-distributed-mode-2808f6b8e71f) to setup your HDFS.

Spark job history servers
```
http://[worker1NodeIP]18080
http://[worker2NodeIP]18080
```
Note, you will need to start the server on each worker node first.
```
bash /spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/start-history-server.sh
```
