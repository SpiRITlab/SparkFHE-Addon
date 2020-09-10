# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Standalone.dockerfile -t sparkfhe/sparkfhe-standalone .


FROM ubuntu:18.04
MAINTAINER The SparkFHE Project, https://github.com/SpiRITlab


# install SparkFHE distribution
RUN apt-get update; \
	apt-get install software-properties-common -y; \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EA8CACC073C3DB2A; \
	add-apt-repository ppa:linuxuprising/java; \
	add-apt-repository ppa:jonathonf/gcc-9.0 -y; \
	apt-get update; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y scala gcc-9 g++-9 openjdk-11-jdk \
    	build-essential libcurl4-nss-dev libsasl2-dev libsasl2-modules libpcre3-dev m4 \
		wget git vim \
		maven libapr1-dev libsvn-dev unzip libz-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get remove -y openjdk-11-jre-headless; \
	cd /; \
	wget https://sparkfhe.s3.amazonaws.com/TestDrive.bash; \
	bash TestDrive.bash all; \
	cd /spark-3.1.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon; \
	git pull; \
	cd /spark-3.1.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/setup; \
	bash install_shared_libraries.bash; \
	rm -rf /spark-3.1.0-SNAPSHOT-bin-SparkFHE/deps/src; \
	ln -s /spark-3.1.0-SNAPSHOT-bin-SparkFHE/hadoop /usr/local/hadoop;


WORKDIR /spark-3.1.0-SNAPSHOT-bin-SparkFHE
