#!/usr/bin/env bash

apt-get install -y software-properties-common
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EA8CACC073C3DB2A
add-apt-repository ppa:linuxuprising/java
add-apt-repository ppa:jonathonf/gcc-9.0 -y
apt-get update
apt-get install -y pkg-config openjdk-11-jdk unzip libz-dev git build-essential m4 libpcre3-dev gcc-9 g++-9 cmake python-dev python-pip maven
apt-get autoremove -y
apt-get clean
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ~/bash.bashrc

pip install --upgrade pip
