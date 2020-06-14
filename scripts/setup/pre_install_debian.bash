#!/usr/bin/env bash

sudo apt-get install -y software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EA8CACC073C3DB2A
sudo add-apt-repository ppa:linuxuprising/java
sudo add-apt-repository ppa:jonathonf/gcc-9.0 -y
sudo apt-get update
sudo apt-get install -y pkg-config openjdk-11-jdk unzip libz-dev git build-essential m4 libpcre3-dev gcc-9 g++-9 cmake python-dev python-pip maven
sudo apt-get autoremove -y
sudo apt-get clean
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> ~/bash.bashrc

sudo pip install --upgrade pip
