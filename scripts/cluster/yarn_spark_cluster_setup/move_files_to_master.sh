#!/bin/sh

# Get the current directory
base_address=`dirname "$(realpath $0)"`
# THIS NEEDS TO CHANGE AS PER EXPERIMENT
master_node_login=pmrane@ms1117.utah.cloudlab.us
# Project Folder name in root
root_folder_in_server=/yarn_spark_cluster_setup

# Make Folder before moving files
mkdir_command='sudo mkdir -p '${root_folder_in_server}
ssh $master_node_login $mkdir_command

# Move Folder on Master Node's Home
# Files Cannot to moved directly in Root due to permission issues
scp -r ${base_address}/Test_Pi  $master_node_login:~/Test_Pi
scp -r ${base_address}/install.sh  $master_node_login:~/install.sh
scp -r ${base_address}/setup.py $master_node_login:~/setup.py

# Move Files in correct location
move_command='sudo mv ~/Test_Pi '${root_folder_in_server}'/Test_Pi'
ssh $master_node_login $move_command

move_command='sudo mv ~/install.sh '${root_folder_in_server}'/install.sh'
ssh $master_node_login $move_command

move_command='sudo mv ~/setup.py '${root_folder_in_server}'/setup.py'
ssh $master_node_login $move_command

echo 'Login to Master Node, navigate to '${root_folder_in_server}' and run install.sh'