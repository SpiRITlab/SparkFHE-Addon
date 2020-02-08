# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Master.dockerfile -t sparkfhe/sparkfhe-master .


FROM ubuntu:18.04
MAINTAINER Peizhao Hu, http://cs.rit.edu/~ph

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y scala gcc-8 g++-8 openjdk-8-jdk python-dev \
    	build-essential autogen autoconf automake libtool \
		libcurl4-nss-dev libsasl2-dev libsasl2-modules libpcre3-dev m4 \ 
		wget git vim zookeeperd \
		maven cmake libapr1-dev libsvn-dev unzip libz-dev && \
    apt-get clean


# install SparkFHE distribution
RUN cd /; \
	wget https://github.com/SpiRITlab/SparkFHE-Maven-Repo/raw/master/TestDrive.bash; \
	bash TestDrive.bash all; 
RUN cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon; \
	git pull; \
	cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/setup; \
	bash install_shared_libraries.bash; \
	rm -rf /spark-3.0.0-SNAPSHOT-bin-SparkFHE/deps

RUN ln -s /spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop /usr/local/hadoop;


# install mesos
RUN cd /tmp; \
	wget http://archive.apache.org/dist/mesos/1.9.0/mesos-1.9.0.tar.gz; \
	tar zxf mesos-1.9.0.tar.gz; \
	wget https://raw.githubusercontent.com/SpiRITlab/SparkFHE-Addon/master/scripts/cluster/mesos_cluster_setup/pip.patch; \
	cd mesos-1.9.0; \
	patch -p1 < ../pip.patch; \
	export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64; \
	./configure; \
	make; \
	make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:; \
	make install AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:; \
	ldconfig


# Creating configuration files
RUN cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/mesos_cluster_setup; \
	mkdir -p /etc/mesos-master; \
	sed "s/masterIP/$masterIP/g" configs/master/zk > /etc/mesos-master/zk; \
	sed "s/masterIP/$masterIP/g" configs/master/zoo.cfg > /etc/mesos-master/zoo.cfg; \
	

RUN touch /etc/zookeeper/conf/myid; \
	echo 1 > /etc/zookeeper/conf/myid

COPY SparkFHE-master-startscript.bash /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/docker/cluster/

WORKDIR /spark-3.0.0-SNAPSHOT-bin-SparkFHE
