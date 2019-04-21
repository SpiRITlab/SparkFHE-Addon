
Setup an experiment on Cloudlab using the SparkFHE-YARN-Client-Ub18-HDFS image. Use the Wisconsin server.

The installation scripts are designed to run from master. The cluster start/stop scripts and example scripts are designed to work from client.

# SSH into Master Node
SSH into the master node and navigate to the address specified below:
```
cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/yarn_cluster_setup
```

# Install Hadoop and Configure Spark on all nodes through Master Node
The hostnames of nodes in cluster will be picked up from etc/hosts. Read Appendix for further details about Hostnames.
```
sudo bash install_yarn_cluster.sh
```

# SSH into Client Node
SSH into the Client node and navigate to the address specified below:
```
cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/yarn_cluster_setup
```

# Start Yarn Spark Cluster and HDFS from Client Node
Cluster can only be started on master node after installation is complete on all nodes and configuration files for Yarn and Spark are placed in correct folders. Check Appendix for HDFS Commands.
```
sudo bash start_yarn_cluster.sh
```

# Run Test Spark Job on Master Through Client
```
cd test_scripts
sudo bash run_spark_test_job_pi_remotely.sh
```
If the job is successfulll completed, final status is 'SUCCEEDED'. The links generated can be used by following the guide specified below.

# Web Interfaces:

Different Web Interfaces can be accessed by changing the port number. The list is specified directly below.

To view the web Interface, some additional steps will have to be performed. Check Appendix for SSH Tunneling Instructions.

The public IP addresses of some nodes have been closed to bolster security. Check Appendix for Security for individual aspects of cluster.

## YARN Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:8088/

The output of test job is available in the link above.  

Select the latest spplications, open the logs for that application, and select stdout. This should show the value for Pi calculated on the cluster.

## Spark Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:8080/

## Namenode Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:50070/

## JobMaster Interface:

http://<MASTER_NODE_IP_ADDRESS_INTERNAL>:19888/

## Datanode Interface:

http://<WORKER_NODE_IP_ADDRESS_INTERNAL>:50075/

# Stop the Cluster Through the client Node
```
cd ..
sudo bash stop_yarn_job.sh
```
After running this command, the web interfaces will not work.

# Appendix

## Hostnames
The current process is designed to read worker names from etc/hosts. This might not be the case for 3rd party products Amazon EC2. Changes will have to be made to the step. The user would have to manually enter public IP addresses of master and worker nodes.

## HDFS Commands
An important condition to for HDFS to work is the public IP address. Please make sure that every node in the cluster has a publicly accessible IP address. 

HDFS is turned on when start_yarn_cluster.sh is executed. The individual command to turn on HDFS is <HADOOP_HOME>/sbin/start-dfs.sh. To close use <HADOOP_HOME>/sbin/stop-dfs.sh. 

### HDFS Commands on cluster nodes
Once on, following commands can be run from any of nodes in the cluster. 
```
# List Folders in HDFS
hdfs dfs -ls /
# Make Folder
hadoop fs -mkdir -p /<DIRECTORY_TO_BE_CREATED>
# Confirm Folder Creation
hdfs dfs -ls /
# Move Local file into HDFS
hadoop fs -put <LOCAL_FILE_ADDRESS>/<FILE_NAME> /<DIRECTORY_TO_BE_CREATED>/
# View content of file created in HDFS
hdfs dfs -cat /<DIRECTORY_TO_BE_CREATED>/<FILE_NAME>
```
Additional Information can be found [here](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/FileSystemShell.html)

### HDFS Commands from remote machines using webHDFS i.e. port 9000
For the most part the HDFS commands here stay similar HDFS commands on cluster nodes. The address to access the HDFS needs to be changed in the following manner. The standard address for hdfs/hadoop can be /usr/local/hadoop/etc/hadoop
```
# List Folders in HDFS
hdfs dfs -ls hdfs://<MASTER_NODE_IP_ADDRESS_PUBLIC>:9000/
# Make Folder
hadoop fs -mkdir -p hdfs://<MASTER_NODE_IP_ADDRESS_PUBLIC>:9000/<DIRECTORY_TO_BE_CREATED>
# Confirm Folder Creation
hdfs dfs -ls hdfs://<MASTER_NODE_IP_ADDRESS_PUBLIC>:9000/
# Move Local file into HDFS
hadoop fs -put <FILE_ADDRESS>/<FILE_NAME> hdfs://<MASTER_NODE_IP_ADDRESS_PUBLIC>:9000/<DIRECTORY_TO_BE_CREATED>/
# View content of file created in HDFS
hdfs dfs -cat hdfs://<MASTER_NODE_IP_ADDRESS_PUBLIC>:9000/<DIRECTORY_TO_BE_CREATED>/<FILE_NAME>
```
Additional Information can be found [here](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/FileSystemShell.html)

### HDFS Commands from remote machines using webHDFS i.e. port 50070
To run commands from machines outside the cluster, REST API can be used. Here are a few examples.
```
# Make folder
curl -X put "http://<MASTER_NODE_IP_ADDRESS_PUBLIC>:50070/webhdfs/v1/user/<DIRECTORY_TO_BE_CREATED>?user.name=root&op=MKDIRS"
# Create an empty file
curl -i -X put "http://<MASTER_NODE_IP_ADDRESS_PUBLIC>:50070/webhdfs/v1/user/<DIRECTORY_TO_BE_CREATED>/<FILE_TO_BE_UPLOADED>?user.name=root&op=CREATE"
# The command above generates a link(specified in quotes) that can be used to upload the file. Use it to append <FILE_TO_BE_UPLOADED> onto HDFS.
curl -i -T <FILE_TO_BE_UPLOADED> "http://<MASTER_NODE_IP_ADDRESS_PUBLIC>:50075/webhdfs/v1/user/<DIRECTORY_TO_BE_CREATED>/<FILE_TO_BE_UPLOADED>?op=CREATE&user.name=root&namenoderpcaddress=master:9000&createflag=&createparent=true&overwrite=false"

```
Additional Information can be found [here](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/WebHDFS.html)

## SSH Tunneling Instructions

### Find Internal IP of Master/Worker Node

On the client node run the following to get the internal IP of Master Node:
```
sudo ssh master "hostname -I | awk '{print \$1}'"
sudo ssh worker1 "hostname -I | awk '{print \$1}'"
```

### Setup SSH Tunneling for nodes

Open a Terminal window on local machine and type the following:

```
ssh -4 -ND <PORT_NUMBER> <USERNAME@MASTER_NODE_ID.SERVER_AREA.cloudlab.us>
```
This step will bind the local machine's port to the IP address of Master Node.

### Configure Browser to open link

* Open Mozilla Firefox browser in the local machine. 

* Click on three horizontal bars available on the top right hand side.

* Select Preferences and look for 'Network Settings' on the page.

* Once inside Network Settings, Select Manual Proxy Configuration.

* Select Socks_v5 and type in the Port Number chosen in the previous step for SOCKS Host. The IP of SOCKS Host does not need to be changed. Select OK.

### Open Weblinks (address-format and port number specified above)

### Stop SSH Tunneling

* To use the Mozilla Firefox browser as usual, Select 'No Proxy' in Network Settings and Select OK.

* Stop the SSH tunneling by Closing the Terminal Window or Hit Ctrl + C in the terminal window.


## Security for individual aspects of cluster
* YARN - Accessible only on internal IP
* Remote HDFS(Port 9000) - Publicly accessible
* webHDFS(Port 50070) - Publicly Accesible
* Spark - Publicly accessible
