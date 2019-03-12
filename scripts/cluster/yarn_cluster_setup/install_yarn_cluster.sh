#!/bin/sh

# Save Master Node Hostname As Global variable
ROOT_VARIABLES_ADDRESS=/etc/profile
HOSTS_ADDRESS=/etc/hosts

# Assume that master node and worker node contain the phrase master and worker in their names respectively
master_name=master
worker_name=worker
name_index_location=4

master_index_in_host_array=0

current_directory=`pwd`

# Make Master and Slaves File, Clear Older Files
rm -rf $current_directory/configs/master || true
touch $current_directory/configs/master
rm -rf $current_directory/configs/slaves || true
touch $current_directory/configs/slaves
rm -rf $current_directory/configs/hostnames || true

# Assume that etc/hosts is correctly populated
# Read hostnames for master and worker nodes
grep $master_name $HOSTS_ADDRESS | awk -v var="$name_index_location" '{print $var}' >> $current_directory/configs/master
grep $worker_name $HOSTS_ADDRESS | awk -v var="$name_index_location" '{print $var}' >> $current_directory/configs/slaves
cat $current_directory/configs/master $current_directory/configs/slaves > $current_directory/configs/hostnames

host_array=($(cat $current_directory/configs/hostnames |tr "\n" " "))

function checkSSH() {
    echo "Checking SSH connections"
    for(( i=0;i<${#host_array[@]};i++)) ; do
        echo ${host_array[i]}
        ssh root@${host_array[i]} "hostname"
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

echo =========================================================
echo "Setup Yarn Master"
echo =========================================================
echo "Installing Yarn-master"
bash install_yarn_master_slave.sh


# Move Config Files and install_yarn_master_slave.sh
# Install Cluster on all Worker Nodes
echo =========================================================
echo "Setting up Yarn Slaves"
echo =========================================================
for(( i=1;i<${#host_array[@]};i++)) ; do
    # ssh root@${host_array[i]} -n "sudo rm -rf ${current_directory} && sudo mkdir -p ${current_directory}"
    rsync -a --rsync-path="sudo rsync" $current_directory/configs/ ${host_array[i]}:$current_directory/configs/
    scp $current_directory/install_yarn_master_slave.sh ${host_array[i]}:$current_directory/
    echo "Installing on "${host_array[i]}
    ssh root@${host_array[i]} -n "cd ${current_directory} && sudo bash install_yarn_master_slave.sh"
    echo "Finished configuration on "${host_array[i]}
    echo ""
done