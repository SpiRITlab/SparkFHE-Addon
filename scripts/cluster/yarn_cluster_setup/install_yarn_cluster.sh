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

# Assume that etc/hosts is correctly populated
# Read hostnames for master and worker nodes
grep $master_name $HOSTS_ADDRESS | awk -v var="$name_index_location" '{print $var}' >> $current_directory/configs/master
grep $worker_name $HOSTS_ADDRESS | awk -v var="$name_index_location" '{print $var}' >> $current_directory/configs/slaves

# Save all hostnames in an array
host_array=($(grep -E "$master_name|$worker_name" /etc/hosts | awk -v var="$name_index_location" '{print $var}'))

# Ping each node from client
function checkSSH() {
    echo "Checking SSH connections"
    for(( i=0;i<${#host_array[@]};i++)) ; do
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

# Move Master and Slaves File on all Nodes
# Install Cluster on all Nodes
for(( i=0;i<${#host_array[@]};i++)) ; do
    scp $current_directory/configs/master ${host_array[i]}:$current_directory/configs
    scp $current_directory/configs/slaves ${host_array[i]}:$current_directory/configs
    echo "Installing on "${host_array[i]}
    ssh root@${host_array[i]} -n "cd ${current_directory} && sudo bash install_yarn_master_slave.sh"
    echo "Finished configuration on "${host_array[i]}
    echo ""
done

# Save Master Node Address as Global Variable
sed -i /MASTER_HOSTNAME/d $ROOT_VARIABLES_ADDRESS
echo "export MASTER_HOSTNAME="${host_array[$master_index_in_host_array]} >> $ROOT_VARIABLES_ADDRESS