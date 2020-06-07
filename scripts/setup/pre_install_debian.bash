#!/usr/bin/env bash

sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:webupd8team/java -y
sudo add-apt-repository ppa:jonathonf/gcc-9.0 -y
sudo apt-get update
sudo apt-get install -y pkg-config openjdk-8-jdk unzip libz-dev git build-essential m4 libpcre3-dev gcc-9 g++-9 cmake python-dev python-pip maven
sudo apt-get autoremove -y
sudo apt-get clean
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/" >> /etc/bash.bashrc

pip install --upgrade pip
