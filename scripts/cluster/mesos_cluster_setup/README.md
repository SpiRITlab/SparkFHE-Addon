## Prerequisites
* Ensure that the master node can SSH as root to all other nodes in the cluster. On your laptop, follow these [instructions](https://github.com/SpiRITlab/SparkFHE-Addon/tree/fix_install_script/scripts/cluster/cloudlab) to setup the Username and Manifest.xml files. Then, run $> bash authorize_access_between_nodes.bash
  * you should see messages regarding the authorizing nodes as follow.
  ```
    Path from include_functions.bash: /Users/ph/myGit/project_on_vhost6/SparkFHE-Addon/scripts/cluster/cloudlab
    Scripts path provided: /Users/ph/myGit/project_on_vhost6/SparkFHE-Addon/scripts/cluster
    Configuring the following cluster nodes...
      Host: master.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.211
      Host: worker1.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.218
      Host: worker2.peiworld-QV46524.iotx-PG0.wisc.cloudlab.us 	 IP: 128.105.144.207
    Authorizing access between nodes...
  ```
* On all the nodes follow [instructions](https://github.com/SpiRITlab/SparkFHE-Examples/wiki) to setup SparkFHE-Examples. Make sure you have gone through all the steps and the mySparkSubmitLocal.bash script runs correctly.

## Setup instructions
On the Mesos master node run the following commands as root:
```
cd ~
git clone https://github.com/SpiRITlab/SparkFHE-Addon
cd SparkFHE-Addon/scripts/cluster/mesos_cluster_setup
bash install_mesos_cluster.bash masterHostname,worker1Hostname,worker2Hostname,...
```

## Relevant services to restart

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
