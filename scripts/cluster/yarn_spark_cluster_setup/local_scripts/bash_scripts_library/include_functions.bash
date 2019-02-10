#!/usr/bin/env bash

if [ "$0" == "include_functions.bash" ] ; then
    echo "This file contains internal functions. It should not be run directly."
    exit 2
fi


# # debug code only
# Current_Dir=`pwd`
# echo "Path from include_functions.bash: $Current_Dir"
# Scripts_Dir=$1
# echo "Scripts path provided: $Scripts_Dir"
# debug code end


Current_Dir=`pwd`
# echo $Current_Dir

Manifest_Filename="$Current_Dir"/"bash_scripts_library/Manifest.xml";
MyUserName=`cat "$Current_Dir"/"bash_scripts_library/myUserName.txt" | tr -d '\n'`
root_folder_in_server=/yarn-spark-cluster
user_group=iotx-PG0

function get_nodes_info() {
    cluster_nodes=( `awk 'match($0, /<host name=\"*\"/) && sub(/name=/, "") && gsub(/\"/,"") {print $2}' $Manifest_Filename` )
    cluster_nodes_ip=( `awk 'match($0, /<host name=\"*\"/) && sub(/ipv4=/, "") && gsub(/\"/,"") && sub(/\/\>/,"") {print $3}' $Manifest_Filename` )
}

function get_cluster_names(){
    for i in "${cluster_nodes[@]}"
    do
        echo $i | cut -d. -f1
    done
}

function get_server_location_and_name() {
    server_location_and_name=( `awk 'match($0, /'$MyUserName'/) && gsub(/hostname=/,"") && gsub(/\"/,"") {print $3}' $Manifest_Filename` )
}

function add_username_to_server(){
	for ((idx=0; idx<${#server_location_and_name[@]}; ++idx)); do
        server_location_and_name[idx]=$MyUserName@${server_location_and_name[idx]}
	done
}

function run_query_on_server(){
    if [ -z "$1" ]
    then
     echo "-Parameter #1 is zero length.-"
    else
     # echo "-Parameter #1 is \"$1\".-"

     for i in "${server_location_and_name[@]}"
     do  
        # echo $i 'bash '${root_folder_in_server}'/cloudlab_server_scripts/bash_scripts/'$1
        ssh $i 'bash '${root_folder_in_server}'/cloudlab_server_scripts/bash_scripts/'$1
     done

    fi   
}

function authorize_access_between_nodes() {
    echo "Authorizing access between nodes..."
    for ((idx=0; idx<${#cluster_nodes[@]}; ++idx)); do
        # Create the user SSH directory, just in case.
        # Retrieve the server-generated RSA private key.
        # Derive the corresponding public key portion.
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MyUserName@${cluster_nodes[idx]} 'mkdir -p $HOME/.ssh && \
         chmod 700 $HOME/.ssh && \
         geni-get key > $HOME/.ssh/id_rsa && \
         chmod 600 $HOME/.ssh/id_rsa && \
         ssh-keygen -y -f $HOME/.ssh/id_rsa > $HOME/.ssh/id_rsa.pub'

        # If you want to permit login authenticated by the auto-generated key,
        # then append the public half to the authorized_keys file:
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $MyUserName@${cluster_nodes[idx]} 'grep -q -f $HOME/.ssh/id_rsa.pub $HOME/.ssh/authorized_keys || cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys'
    done
}