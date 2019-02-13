Setup an experiment on Cloudlab using the Ubuntu Base Image. Note the master node login.

The key setup has to be done manually using scp. Move id_rsa and id_rsa.pub to ~/.ssh on all nodes. 

Note that the scripts are designed to run on Master Node.

# Edit the master node login in move_files_to_master.sh

Edit the variable master_node_login=username@id.region.cloudlab.us

This will enable the script to move the relevant files to Master Node. SSH into address for master node and navigate to the address /yarn_spark_cluster_setup

# Install Hadoop and Spark on all nodes
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

# Stop of Cluster
```
sudo bash stop_spark_job.sh
```
After running this command, the web interface will not work
