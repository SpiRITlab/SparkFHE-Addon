#!/bin/sh

# Checking for no arguments passed
if [ $# -lt 1 ]
  then
    echo "Nodes Not Specified as Arguments"
    exit
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

# Clear Content from Files
rm master || true
touch master
rm slaves || true
touch slaves

# Save 1st argument in master file
master_limit=1
echo ${host_array[$master_limit]} >> master

# Save Remaining arguments in slaves file
for(( i=2;i<=${#host_array[@]};i++)) ; do
    echo ${host_array[i]} >> slaves
done

root_folder_in_server=`pwd`

# Setup Environment at node
python3 ${root_folder_in_server}/setup.py

# Read addresses in slaves file
cat slaves | while read line

do
    if [ "$line" = "-" ]; then
        echo "Skip $line"
    else
        scp ${root_folder_in_server}/master root@$line:${root_folder_in_server}
        scp ${root_folder_in_server}/slaves root@$line:${root_folder_in_server}
        ssh root@$line -n "cd ${root_folder_in_server} && python3 setup.py"
        echo "Finished config node $line"
        echo "########################################################"
    fi
done
