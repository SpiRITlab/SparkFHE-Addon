#!/usr/bin/env bash

masterIP=$1
sourcePath=`pwd`
apt -y install build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev unzip

wget http://www.apache.org/dist/mesos/1.6.0/mesos-1.6.0.tar.gz
tar -xzvf mesos-1.6.0.tar.gz
cd mesos-1.6.0
mkdir build
cd build

../configure
make -j 14 V=0
make install
ldconfig
cd $sourcePath
# Install mesos and zookeeper
apt-get -y install zookeeperd

# Configure zookeeper master
sed -i "s/masterIP/$masterIP/g" configs/master/*

# Configure Zookeeper and Mesos master
mkdir -p /etc/mesos-master
cp configs/master/zk /etc/mesos-master/zk
cp configs/master/zoo.cfg /etc/zookeeper/conf/zoo.cfg
touch /etc/zookeeper/conf/myid
echo 1 > /etc/zookeeper/conf/myid
cp configs/master/mesos-master.service /etc/systemd/system/mesos-master.service

# Restart relevant services
systemctl daemon-reload
systemctl start mesos-master.service
systemctl start zookeeper.service
systemctl enable zookeeper
systemctl enable mesos-master

