#!/bin/sh
python3 /test_cluster/perform_setup.py
cat slaves | while read line
do
    if [ "$line" = "-" ]; then
        echo "Skip $line"
    else
        # ssh root@$line -n "rm -rf /test_cluster/ && mkdir /test_cluster/"
        # echo "Copy data to $line"
        # scp  -r /test_cluster root@$line:/test_cluster
        echo "Setup $line"
        ssh root@$line -n "cd /test_cluster/ && python3 perform_setup.py"
        echo "Finished config node $line"
        echo "########################################################"
    fi
done