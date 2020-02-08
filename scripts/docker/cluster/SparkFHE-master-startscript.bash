#!/bin/bash

MyIPAddress=$1


/usr/local/sbin/mesos-master --ip=$MyIPAddress --work_dir=/var/lib/mesos --zk=file://etc/mesos-master/zk --quorum=1 --cluster=sparkmesos



export MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so
/SPARK_DISTRIBUTION_PATH/bin/spark-class org.apache.spark.deploy.mesos.MesosClusterDispatcher --host $MyIPAddress --master mesos://$MyIPAddress:5050
