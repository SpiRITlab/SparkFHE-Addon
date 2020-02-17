# Ubuntu 18.04
# Build image with:  docker build -f SparkFHE-Standalone.dockerfile -t sparkfhe/sparkfhe-standalone .


FROM ubuntu:18.04
MAINTAINER Peizhao Hu, http://cs.rit.edu/~ph


# install SparkFHE distribution
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y scala gcc-8 g++-8 openjdk-8-jdk python-dev \
    	build-essential libcurl4-nss-dev libsasl2-dev libsasl2-modules libpcre3-dev m4 \
		wget git vim \
		maven cmake libapr1-dev libsvn-dev unzip libz-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get remove -y openjdk-11-jre-headless; \
	cd /; \
	wget https://github.com/SpiRITlab/SparkFHE-Maven-Repo/raw/master/TestDrive.bash; \
	bash TestDrive.bash all; \
	cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon; \
	git pull; \
	cd /spark-3.0.0-SNAPSHOT-bin-SparkFHE/SparkFHE-Addon/scripts/setup; \
	bash install_shared_libraries.bash; \
	rm -rf /spark-3.0.0-SNAPSHOT-bin-SparkFHE/deps; 
	ln -s /spark-3.0.0-SNAPSHOT-bin-SparkFHE/hadoop /usr/local/hadoop;


WORKDIR /spark-3.0.0-SNAPSHOT-bin-SparkFHE
