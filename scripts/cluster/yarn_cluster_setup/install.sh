#!/bin/sh

# Checking for no arguments passed
if [ $# -lt 2 ]
  then
    echo "Insufficient number of arguments"
    exit
fi

# Clear Content from Files
rm master
touch master
rm slaves
touch slaves

# Add Hyphen to the beginning of the slaves file
echo "-" >> slaves

master_limit=1

for (( c=1; c<=$#; c++ )); do
    # Save First Address to master file
    if [ "$c" -eq "$master_limit" ]; then
        echo ${!c} >> master
    # Save Remaining Addresses to slaves file
    else
        echo ${!c} >> slaves
    fi
done

# Add Hyphen to the end of the slaves file
echo "-" >> slaves

root_folder_in_server=/yarn_cluster_setup

# Setup Environment at node
python3 ${root_folder_in_server}/setup.py

# Read addresses in slaves file
cat slaves | while read line

do
    if [ "$line" = "-" ]; then
        echo "Skip $line"
    else
        ssh root@$line -n "rm -rf ${root_folder_in_server} && mkdir ${root_folder_in_server}"
        echo "Copy data to $line"
        scp ${root_folder_in_server}/setup.py root@$line:${root_folder_in_server} && \
        scp ${root_folder_in_server}/master root@$line:${root_folder_in_server} && \
        scp ${root_folder_in_server}/slaves root@$line:${root_folder_in_server}
        echo "Setup $line"
        ssh root@$line -n "cd ${root_folder_in_server}"
        ssh root@$line -n "cd ${root_folder_in_server} && python3 setup.py"
        echo "Finished config node $line"
        echo "########################################################"
    fi
done
