#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
	echo "Missing arguments."
	echo "Usage: bash install_mesos_cluster.bash masterHostname1,workerHostname1,workerHostname2,..."
	exit 0
fi

cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')


function checkSSH() {
    echo "Checking SSH connections"
    for(( i=2;i<=${#host_array[@]};i++)) ; do
        ssh ${host_array[i]} "hostname"
        if [ $? -eq 0 ]
        then
            echo -e "Can SSH to ${host_array[i]}"
        else
	    echo -e "Cannot SSH to ${host_array[i]}, please fix."
	    exit 255
        fi
    done
}

checkSSH

## local_ip replace localhost in config file
local_host="`hostname`"
local_ip=`curl ifconfig.me`

## current_path replace data_path in config file
current_path=`pwd`
project_root_path=`cd ${current_path}/../.. && pwd`
echo $current_path
echo $project_root_path
echo =========================================================
echo "Setup Mesos Master"
echo =========================================================
echo "Installing and starting mesos-master"
sudo ./install_mesos_master.bash $local_ip > /dev/null

cd $current_path

echo =========================================================
echo "Setting up Mesos Slaves"
echo =========================================================
for(( i=2;i<=${#host_array[@]};i++)) ; do
    echo "Copying mesos files..."
    rsync -avz $current_path/../../../../SparkFHE-Addon/ ${host_array[i]}:$current_path/../../../../SparkFHE-Addon/
    echo "Installing on ${host_array[i]}"
    echo "Installing and starting mesos-slave"
    ssh ${host_array[i]} "cd $current_path; sudo ./install_mesos_slave.bash $local_ip > /dev/null"
    echo "Cleaning up on ${host_array[i]}"
    ssh ${host_array[i]} "cd $current_path; rm -rf mesos*"
done

echo "Cleaning on on master"
cd $current_path
rm -rf mesos*

# Start Spark Cluster dispatcher service
echo "Starting Spark service"
# cp configs/master/spark.service /etc/systemd/system/spark.service
systemctl daemon-reload
systemctl start spark.service
systemctl enable spark

systemctl restart zookeeper
systemctl restart spark.service
systemctl restart mesos-master

# Run a sample Spark Job
# echo "Running test Spark job"
# /spark/bin/spark-submit --name SparkPiTestApp --class org.apache.spark.examples.SparkPi --master mesos://$local_ip:7077 --deploy-mode cluster --executor-memory 1G --total-executor-cores 30 /spark/examples/jars/spark-examples_2.11-2.2.0.jar 100

echo ========================== DONE =============================

