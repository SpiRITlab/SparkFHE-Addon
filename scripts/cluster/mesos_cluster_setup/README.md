## Prerequisites
* Ensure that the master node can SSH as root to all other nodes in the cluster.
* On all the nodes follow [instructions](https://github.com/SpiRITlab/SparkFHE-Examples/wiki) to setup SparkFHE-Examples.

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
