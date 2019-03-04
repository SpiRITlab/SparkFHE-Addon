#!/bin/sh

# Checking for no arguments passed
if [[ $# -eq 0 ]] ; then
    echo "Missing arguments."
    echo "Usage: bash install_yarn_cluster.bash masterHostname1,workerHostname1,workerHostname2,..."
    exit 0
fi

# Split based on de-limiter as comma
cluster=$1
eval $(echo $cluster | awk '{split($0, array, ",");for(i in array)print "host_array["i"]="array[i]}')

function checkSSH() {
    echo "Checking SSH connections"
    for(( i=1;i<=${#host_array[@]};i++)) ; do
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

current_directory=`pwd`

# Make Master and Slaves File
# Clear Content from Files

rm -rf $current_directory/configs/master || true
touch $current_directory/configs/master
rm -rf $current_directory/configs/slaves || true
touch $current_directory/configs/slaves

# Save 1st argument in master file
master_limit=1
echo ${host_array[$master_limit]} >> $current_directory/configs/master

# Save Remaining arguments in slaves file
for(( i=2;i<=${#host_array[@]};i++)) ; do
    echo ${host_array[i]} >> $current_directory/configs/slaves
done

# Move Master and Slaves File on all Nodes
# Install Cluster on all Nodes
for(( i=1;i<=${#host_array[@]};i++)) ; do
    scp $current_directory/configs/master ${host_array[i]}:$current_directory/configs
    scp $current_directory/configs/slaves ${host_array[i]}:$current_directory/configs
    echo "Installing on "${host_array[i]}
    ssh root@${host_array[i]} -n "cd ${current_directory} && sudo bash install_yarn_master_slave.sh"
    echo "Finished configuration on "${host_array[i]}
done

# Trigger Scripts on Master Node
ssh root@${host_array[$master_limit]} -n "cd ${current_directory} && sudo bash start_yarn_cluster.sh"
ssh root@${host_array[$master_limit]} -n "cd ${current_directory}/test_scripts && sudo bash run_spark_test_job_pi.sh"
ssh root@${host_array[$master_limit]} -n "cd ${current_directory} && sudo bash stop_yarn_cluster.sh"