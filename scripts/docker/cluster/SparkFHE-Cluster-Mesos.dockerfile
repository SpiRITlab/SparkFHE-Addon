# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Cluster-Mesos.dockerfile -t sparkfhe/sparkfhe-cluster-mesos .
# You may need to assign more memory for docker build.
# see https://stackoverflow.com/questions/44533319/how-to-assign-more-memory-to-docker-container/44533437#44533437


FROM sparkfhe/sparkfhe-standalone
MAINTAINER Peizhao Hu, http://cs.rit.edu/~ph


# install mesos
# "make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:;"" is needed to bypass "automake-1.13: command not found" error
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y autogen autoconf automake libtool zookeeperd; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    cd /; \
	wget http://archive.apache.org/dist/mesos/1.9.0/mesos-1.9.0.tar.gz; \
	tar zxf mesos-1.9.0.tar.gz; \
	rm -rf mesos-1.9.0.tar.gz; \
	wget https://raw.githubusercontent.com/SpiRITlab/SparkFHE-Addon/master/scripts/cluster/mesos_cluster_setup/pip.patch; \
	cd mesos-1.9.0; \
	patch -p1 < ../pip.patch; \
	export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64; \
	./configure; \
	make; \
	make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:; \
	make install AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:; \
	ldconfig; \
	rm -rf mesos-1.9.0 pip.patch
