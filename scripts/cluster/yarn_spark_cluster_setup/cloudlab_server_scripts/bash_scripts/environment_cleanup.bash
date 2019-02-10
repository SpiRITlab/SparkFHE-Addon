#!/usr/bin/env bash

base_address=`dirname "$(realpath $0)"`
variables_address=${base_address}/include_variables.bash
source $variables_address

# sudo rm -rf $root_folder_in_server/

sudo rm -rf /$root_folder_in_server/hdfs /$root_folder_in_server/hadoop /$root_folder_in_server/spark

echo "Environment Cleaned"