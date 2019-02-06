#!/usr/bin/env bash

masterIP=$1
sourcePath=`pwd`
apt -y install build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev unzip

cd mesos-1.6.0/build

#../configure
#make -j 14 V=0
make install
ldconfig

cd $sourcePath

# Configure zookeeper master
sed -i "s/masterIP/$masterIP/g" configs/slave/master

# Configure Mesos slave
mkdir -p /etc/mesos-slave
cp configs/slave/master /etc/mesos-slave/master
cp configs/slave/mesos-slave.service /etc/systemd/system/mesos-slave.service

# Restart relevant services
systemctl daemon-reload
systemctl start mesos-slave.service
systemctl enable mesos-slave


systemctl restart mesos-slave
