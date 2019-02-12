#!/usr/bin/env bash

current_path=`pwd`
library_file_address=$current_path/bash_scripts_library/include_functions.bash
source $library_file_address

get_server_location_and_name
add_username_to_server

for i in "${server_location_and_name[@]}"
do	

	# mkdir_command='sudo mkdir -p '${root_folder_in_server}
	# ssh $i $mkdir_command
	# chown_command='sudo chown -R '${MyUserName}':${user_group} '${root_folder_in_server}
	# ssh $i $chown_command

    # Move Keys
    scp ~/.ssh/id_rsa $i:~/.ssh/id_rsa
    scp ~/.ssh/id_rsa.pub $i:~/.ssh/id_rsa.pub
    scp ${current_path}/../config/ssh_config $i:~/.ssh/config

    # Change Permissions
    ssh $i 'chmod 700 ${HOME}/.ssh'
    ssh $i 'chmod 600 ${HOME}/.ssh/id_rsa'
    ssh $i 'chmod 644 ${HOME}/.ssh/id_rsa.pub'

	# # Move Config and Scripts folder
	# scp -r ${current_path}/../config  $i:$root_folder_in_server
	# scp -r ${current_path}/../cloudlab_server_scripts  $i:$root_folder_in_server
done

# # Make a list of slaves, install Hadoop and Spark
# run_query_on_server 'environment_setup.bash'

# # Format Namenode, reset all data from node
# spark_command='bash '${root_folder_in_server}'/cloudlab_server_scripts/bash_scripts/namenode_format.bash'
# ssh ${server_location_and_name[0]} $spark_command

# # Run Spark on Master Node
# spark_command='bash '${root_folder_in_server}'/cloudlab_server_scripts/bash_scripts/spark_on_server.bash'
# ssh ${server_location_and_name[0]} $spark_command

# # Remove all the installed folders and retain the bare essential scripts, config files
# run_query_on_server 'environment_cleanup.bash'