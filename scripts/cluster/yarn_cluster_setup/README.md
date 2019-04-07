
Setup an experiment on Cloudlab using the SparkFHE-YARN-Client-Ubun18.04 image. Use the Wisconsin server.

Please note that all scripts are designed to run on Client node.

# SSH into Master Node
SSH into the master node and navigate to the address specified below:
```
cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/yarn_cluster_setup
```

# Install Hadoop and Configure Spark on all nodes through Master Node
The hostnames of nodes in cluster will be picked up from etc/hosts
```
sudo bash install_yarn_cluster.sh
```

# SSH into Client Node
SSH into the Client node and navigate to the address specified below:
```
cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/yarn_cluster_setup
```

# Start Yarn Spark Cluster and HDFS from Client Node
Cluster can only be started on master node after installation is complete on all nodes and configuration files for Yarn and Spark are placed in correct folders.
```
sudo bash start_yarn_cluster.sh
```

# Run Test Spark Job on Master Through Client
```
cd test_scripts
sudo bash run_spark_test_job_pi_remotely.sh
```
If the job is successfulll completed, final status is 'SUCCEEDED'. The links generated can be used by following the guide specified below.

## Web Interfaces:

The public IP addresses of all nodes have been closed to bolster security. To view the web Interface, some additional steps will have to be performed.

### Find Internal IP of Master Node

On the client node run the following to get the internal IP of Master Node:
```
sudo ssh master "hostname -I | awk '{print \$1}'"
```
This same step can be done on any of the worker nodes.

### Setup SSH Tunneling for nodes

Open a Terminal window on local machine and type the following:

```
ssh -4 -ND <PORT_NUMBER> <USERNAME@MASTER_NODE_ID.SERVER_AREA.cloudlab.us>
```
This step will bind the local machine's port to the IP address of Master Node.

### Configure Browser to open link

Open Mozilla Firefox browser in the local machine. 

Click on three horizontal bars available on the top right hand side.

Select Preferences and look for 'Network Settings' on the page.

Once inside Network Settings, Select Manual Proxy Configuration.

Select Socks_v5 and type in the Port Number chosen in the previous step for SOCKS Host. The IP of SOCKS Host does not need to be changed. Save the Settings.

### List of Web Interfaces

Different Web Interfaces can be accessed by changing the port number.

#### YARN Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:8088/

The output of test job is available in the link above.  

Select the latest application, open the logs for that application, and select stdout. This should show the value for Pi calculated on the cluster.

#### Spark Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:8080/

#### Namenode Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:50070/

#### JobMaster Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:19888/

#### Datanode Interface:

http://<WORKER_NODE_IP_ADDRESS_INTERNAL>:50075/

### Remove Browser Configuration

To use the Mozilla Firefox browser regularly, Select 'No Proxy' in Network Settings and Save.

Stop the SSH tunneling by Closing the Terminal Window or Hit Ctrl + C in the terminal window.

# Stop the Cluster Through the client Node
```
cd ..
sudo bash stop_yarn_job.sh
```
After running this command, the web interfaces will not work.
