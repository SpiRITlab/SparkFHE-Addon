#!/usr/bin/env bash

base_address=`dirname "$(realpath $0)"`
variables_address=${base_address}/include_variables.bash
source $variables_address

$HADOOP_HOME/bin/hdfs namenode -format