#!/usr/bin/env bash

cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')

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
    rsync -avz $current_path/../../../SparkFHE ${host_array[i]}:~
    echo "Installing on ${host_array[i]}"
    #ssh ${host_array[i]} "cd ~; mkdir -p mesos"
    #echo "Copying install script and configs"
    #scp install_mesos_slave.bash ${host_array[i]}:$current_path
    #scp configs/slave/master ${host_array[i]}:$current_path
    #scp configs/slave/mesos-slave.service ${host_array[i]}:$current_path
    echo "Installing and starting mesos-slave"
    ssh ${host_array[i]} "cd $current_path; sudo ./install_mesos_slave.bash $local_ip > /dev/null"
    echo "Cleaning up on ${host_array[i]}"
    ssh ${host_array[i]} "cd ~; rm -rf SparkFHE"
done

echo "Cleaning on on master"
cd $current_path
rm -rf mesos*

# Start Spark Cluster dispatcher service
echo "Starting Spark service"
cp configs/master/spark.service /etc/systemd/system/spark.service
systemctl daemon-reload
systemctl start spark.service
systemctl enable spark

# Run a sample Spark Job
echo "Running test Spark job"
/spark/bin/spark-submit --name SparkPiTestApp --class org.apache.spark.examples.SparkPi --master mesos://$local_ip:7077 --deploy-mode cluster --executor-memory 1G --total-executor-cores 30 /spark/examples/jars/spark-examples_2.11-2.2.0.jar 100

echo ========================== DONE =============================
