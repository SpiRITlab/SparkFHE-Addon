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

# Make Master and Slaves File
# Clear Content from Files

current_directory=`pwd`

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

echo =========================================================
echo "Setup Yarn Master"
echo =========================================================
echo "Installing Yarn-master"
# Setup Environment at node
bash install_yarn_master_slave.sh

echo =========================================================
echo "Setting up Yarn Slaves"
echo =========================================================

# Read addresses in slaves file
cat $current_directory/configs/slaves | while read line

do
    if [ "$line" = "-" ]; then
        echo "Skip $line"
    else
        # Move master and slaves file to worker nodes
        scp $current_directory/configs/master root@$line:$current_directory/configs
        scp $current_directory/configs/slaves root@$line:$current_directory/configs
        echo "Installing on $line"
        echo "Installing Yarn-slave"
        ssh root@$line -n "cd ${current_directory} && sudo bash install_yarn_master_slave.sh"
        echo "Finished config node $line"
    fi
done
