

**Note, run this script within your laptop (outside the cloudlab environment).**

# Step 1: Gathering experiment info
To run scripts within the cloudlab folder, you need to create two files *within* this folder.
## Step 1.1 Provide your Cloudlab.us username 
- Create a file called "myUserName.txt"
- Enter your Cloudlab.us username in one single line

## Step 1.2 Provide node information from Cloudlab.us experiment
- Login cloudlab.us and goto the Manifest tab of your experiment
- Create a new file "Manifest.xml"
- Copy&Past all contents from the Manifest tab into "Manifest.xml"

The content should look like the following:
```xml
<rspec xmlns="http://www.geni.net/resources/rspec/3" xmlns:emulab="http://www.protogeni.net/resources/rspec/ext/emulab/1" xmlns:tour="http://www.protogeni.net/resources/rspec/ext/apt-tour/1" xmlns:jacks="http://www.protogeni.net/resources/rspec/ext/jacks/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.geni.net/resources/rspec/3    http://www.geni.net/resources/rspec/3/request.xsd" type="request">
... contents removed for privacy reason ...
</rspec>

```

#  Step 2. Cluster setup 

## Option 1: For a new experiment 


### Initilize the cluster
Run the following script to set up the cluster for the first time (authorize access between nodes and set up Mesos and HDFS):
```
bash init_cluster_nodes.bash
```
The cluster is correctly initialized. Mesos, HDFS, and Spark should be running. Please check the following Web UI. 

#### Mesos
```
http://[MasterNodeIP]:5050
```

#### HDFS 
```
http://[MasterNodeIP]:9870
```


#### Spark historty server for workers
```
http://[Worker1NodeIP]:18080
http://[Worker2NodeIP]:18080
```


## Option 2: For an existing experiment

### Cluster reset
Run the following script if you need to reset Mesos and HDFS. 
Note: this will remove all the logs and all the stored files from previous Spark jobs. 
```
bash reset_cluster_nodes.bash
```

### Cluster setup after reboot
If the cluster were rebooted, you may have to restart the services. 
```
bash restart_cluster_nodes.bash
```




# Troubleshooting

Post an [issue](https://github.com/SpiRITlab/SparkFHE-Addon/issues) if you have any issues with starting an experiment on CloudLab.us
