#!/bin/bash

systemctl daemon-reload
systemctl restart mesos-master
systemctl restart zookeeper
systemctl restart spark
