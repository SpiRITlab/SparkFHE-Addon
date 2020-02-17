# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Worker.dockerfile -t sparkfhe/sparkfhe-worker .


FROM sparkfhe/sparkfhe-cluster-mesos
MAINTAINER Peizhao Hu, http://cs.rit.edu/~ph

# Configure Mesos slave
RUN cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/mesos_cluster_setup; \
	mkdir -p /etc/mesos-slave; \
	sed "s/masterIP/$masterIP/g" configs/slave/master > /etc/mesos-slave/master

COPY SparkFHE-worker-startscript.bash /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/docker/cluster/

