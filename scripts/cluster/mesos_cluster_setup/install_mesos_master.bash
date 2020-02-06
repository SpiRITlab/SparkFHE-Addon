#!/usr/bin/env bash

masterIP=$1
sourcePath=`pwd`
apt -y install build-essential python-dev python-pip libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev unzip

# Download mesos-1.6.0 and compile
wget http://archive.apache.org/dist/mesos/1.6.0/mesos-1.6.0.tar.gz
tar -xzvf mesos-1.6.0.tar.gz
cd mesos-1.6.0
patch -p0 < ../pip.patch
mkdir build
cd build

../configure
make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
make install
ldconfig
cd $sourcePath

# Install mesos and zookeeper
apt-get -y install zookeeperd

# Creating configuration files
mkdir -p /etc/mesos-master
sed "s/masterIP/$masterIP/g" configs/master/zk > /etc/mesos-master/zk
sed "s/masterIP/$masterIP/g" configs/master/zoo.cfg > /etc/mesos-master/zoo.cfg
sed "s/masterIP/$masterIP/g" configs/master/mesos-master.service > /etc/systemd/system/mesos-master.service
sed "s/masterIP/$masterIP/g" configs/master/spark.service > /etc/systemd/system/spark.service

sparkPath=`ls / | grep "^spark.*SparkFHE$"`
sed -i "s/SPARK_DISTRIBUTION_PATH/$sparkPath/g" /etc/systemd/system/spark.service

touch /etc/zookeeper/conf/myid
echo 1 > /etc/zookeeper/conf/myid

# Restart relevant services
systemctl daemon-reload
systemctl start mesos-master.service
systemctl start zookeeper.service
systemctl enable zookeeper
systemctl enable mesos-master

