Setup an experiment on Cloudlab using the SparkFHE-Base-Ubuntu18.04 image. Please make note of the master node login.

Also, note that the scripts are designed to run on Master Node.

# Move files to Master Node

First, small change needs to be made in move_files_to_master.sh. The name of the master node needs to be added to the script. To do so, edit the variable master_node_login=username@id.region.cloudlab.us

This will enable the script to move the relevant files onto the Master Node. 

Run the bash script in local.
```
bash move_files_to_master.sh
```
SSH into address for master node and navigate to the address /yarn_spark_cluster_setup

# Install Hadoop and Spark on all nodes
Specify the names of nodes as arguments.
```
cd /yarn_spark_cluster_setup
sudo bash install.sh master worker1 worker2 ...
```

# Start Yarn Spark Cluster on Master
```
cd Test_Pi
sudo bash start_yarn_spark_cluster.sh
sudo bash run_spark_job.sh
```
Use the link generated after successful completion to view the web interface for Yarn

Generally the link should look like this:
http://master.experiment-name.iotx-pg0.utah.cloudlab.us:8088/cluster

http://master.experiment-name.iotx-pg0.utah.cloudlab.us:8080/

# Stop of Cluster
```
sudo bash stop_spark_job.sh
```
After running this command, the web interface will not work
