#!bin/bash

MesosMasterHostName=$1
InactiveFrameworkID=$2

if [[ "$MesosMasterHostName" == "" || "$InactiveFrameworkID" == "" ]]; then
  	echo "bash manageMesos.bash [MesosMasterHostName] [InactiveFrameworkID]"
else
	echo "frameworkId=$2" > /tmp/$2.txt
	curl -d@/tmp/$2.txt -X POST http://$1:5050/master/teardown
fi