# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Worker.dockerfile -t sparkfhe/sparkfhe-worker .


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


# Configure Mesos slave
RUN cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/cluster/mesos_cluster_setup; \
	mkdir -p /etc/mesos-slave; \
	sed "s/masterIP/$masterIP/g" configs/slave/master > /etc/mesos-slave/master

COPY SparkFHE-worker-startscript.bash /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/docker/cluster/

WORKDIR /spark-3.0.0-SNAPSHOT-bin-SparkFHE
