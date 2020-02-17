# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Master.dockerfile -t sparkfhe/sparkfhe-master .


FROM sparkfhe/sparkfhe-cluster-mesos
MAINTAINER Peizhao Hu, http://cs.rit.edu/~ph

# Creating configuration files
RUN cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/mesos_cluster_setup; \
	mkdir -p /etc/mesos-master; \
	sed "s/masterIP/$masterIP/g" configs/master/zk > /etc/mesos-master/zk; \
	sed "s/masterIP/$masterIP/g" configs/master/zoo.cfg > /etc/mesos-master/zoo.cfg; \
	touch /etc/zookeeper/conf/myid; \
	echo 1 > /etc/zookeeper/conf/myid

COPY SparkFHE-master-startscript.bash /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/docker/cluster/

