#!/bin/bash

# root_folder_name=/yarn-spark-cluster
# HADOOP_HOME=$root_folder_name/hadoop
# SPARK_HOME=$root_folder_name/spark

# # HADOOP_SSH_OPTS="-i ~/.ssh/id_rsa"

# # export HADOOP_CONF_DIR=/etc/hadoop/conf

# sudo rm -R /tmp/* || true
# sudo rm -rf /app/hadoop/tmp || true
# sudo mkdir -p /app/hadoop/tmp
# sudo chown $USER:iotx-PG0 /app/hadoop/tmp
# sudo chmod 750 /app/hadoop/tmp

echo "STARTING HADOOP SERVICES"
/usr/local/hadoop/sbin/start-dfs.sh

/usr/local/hadoop/sbin/start-yarn.sh

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

/usr/local/hadoop/bin/hdfs dfsadmin -safemode leave

echo "STARTING SPARK SERVICES"
/usr/local/spark/sbin/start-all.sh
# scala -version

echo "RUN jps - Java Virtual Machine Process Status Tool"
jps

echo "Get basic filesystem information and statistics."
hdfs dfsadmin -report

echo "SPARK TEST"
/usr/local/spark/bin/spark-submit --class org.apache.spark.examples.SparkPi  \
    --master yarn \
    --deploy-mode cluster \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 512m \
    --executor-cores 1 \
    /usr/local/spark/examples/jars/spark-examples*.jar \
    10

#!/bin/bash

# root_folder_name=/yarn-spark-cluster
# HADOOP_HOME=$root_folder_name/hadoop
# SPARK_HOME=$root_folder_name/spark
# HADOOP_SSH_OPTS="-i ~/.ssh/id_rsa"

echo -e "Stopping Spark Cluster"

/usr/local/spark/sbin/stop-all.sh

echo -e "Stopping Hadoop Cluster"

/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver

/usr/local/hadoop/sbin/stop-dfs.sh

/usr/local/hadoop/sbin/stop-yarn.sh

# rm -rf $root_folder_name/hdfs/datanode/*

# rm -rf $root_folder_name/hdfs/namenode/*

# sudo rm -R /tmp/*
# sudo rm -rf /app/hadoop/tmp || true