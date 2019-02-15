#!/bin/sh

# current_path=`pwd`
# library_file_address=$current_path/bash_scripts_library/include_functions.bash
# source $library_file_address

# get_nodes_info
# authorize_access_between_nodes

 if [ "$#" -eq  "0" ]; then
     echo "No Arguments Supplied. Use something like pmrane@ms1028.utah.cloudlab.us"
     exit
 else
     master_node_login=$1
 fi

# Get the current directory
base_address=`dirname "$(realpath $0)"`

# Project Folder name in root
root_folder_in_server=/yarn_cluster_setup

# Make Folder before moving files
mkdir_command='sudo mkdir -p '${root_folder_in_server}
ssh $master_node_login $mkdir_command

# Move Files on Master Node's Home
rsync -a --rsync-path="sudo rsync" ${base_address}/Test_Pi  $master_node_login:${root_folder_in_server}
rsync -a --rsync-path="sudo rsync" ${base_address}/install.sh  $master_node_login:${root_folder_in_server}
rsync -a --rsync-path="sudo rsync" ${base_address}/setup.py  $master_node_login:${root_folder_in_server}

echo 'Login to Master Node, navigate to '${root_folder_in_server}' and run sudo bash install.sh'