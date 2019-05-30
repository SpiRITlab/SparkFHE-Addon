#!/bin/bash

# run this script on the master node

if [ "$#" -eq 0 ]; then
    echo "bash mySparkSubmitCluster.bash [MESOS_MASTER_NODE_IP_ADDR]"
    exit
fi

# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../..
cd $ProjectRoot

SparkFHE_Addon_name="SparkFHE-Addon"
SparkFHE_distribution="/spark-3.0.0-SNAPSHOT-bin-SparkFHE"
HADOOP_HOME=/usr/local/hadoop


master=mesos://$1:7077
HDFS_HOST=hdfs://$1:9000
HDFS_PATH="/SparkFHE/HDFSFolder"
HDFS_URL=$HDFS_HOST$HDFS_PATH

deploy_mode=cluster
executor_memory=16G
total_executor_cores=30

ivysettings_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/ivysettings.xml
log4j_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/log4j.properties
jar_sparkfhe_examples=$SparkFHE_distribution/examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=$SparkFHE_distribution/jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=$SparkFHE_distribution/jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=$SparkFHE_distribution/libSparkFHE/lib:$SparkFHE_distribution/libSparkFHE/lib/native:/usr/local/lib
java_class_path=.:$SparkFHE_distribution/jars

mkdir -p /tmp/spark-events

# run the actual spark submit job
# inputs: (spark_job_name, main_class_to_run, [opt.arg] [pk], [sk], [ctxt1], [ctxt2])
# more info, see https://spark.apache.org/docs/latest/running-on-mesos.html#configuration
function run_spark_submit_command() {
	spark_job_name=$1 
	main_class_to_run=$2 
	rm -rf  ~/.ivy2
	bin/spark-submit $verbose \
		--name $spark_job_name \
		--master $master \
		--deploy-mode $deploy_mode \
		--executor-memory $executor_memory \
		--total-executor-cores $total_executor_cores \
		--driver-class-path $java_class_path \
		--class $main_class_to_run \
		--jars $jar_sparkfhe_api,$jar_sparkfhe_plugin \
		--conf spark.eventLog.enabled=true \
		--conf spark.eventLog.dir=/tmp/spark-events \
		--conf spark.master.rest.enabled=true \
		--conf spark.jars.ivySettings="$ivysettings_file" \
		--conf spark.driver.userClassPathFirst=true \
		--conf spark.driver.extraClassPath="$java_class_path" \
		--conf spark.driver.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.driver.extraJavaOptions="-Djava.library.path=$libSparkFHE_path -Dlog4j.configuration=$log4j_file"  \
		--conf spark.executor.extraClassPath="$java_class_path" \
		--conf spark.executor.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.executor.extraJavaOptions="-Djava.library.path=$libSparkFHE_path -Dlog4j.configuration=$log4j_file"  \
        --conf spark.mesos.executor.home=$SparkFHE_distribution \
        --conf spark.executorEnv.MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so \
		$jar_sparkfhe_examples $3 $4 $5 $6 $7
}


# increase the size of the vm
export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"


echo "========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.BasicExample..."
echo "========================================================="
# run basic operations without SparkFHE stuffs
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicExample



echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.KeyGenExample..."
echo "=========================================================="
# generate example key pairs
run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.basic.KeyGenExample 1 $HDFS_HOST

# wait for new key to be generated; because spark process jobs in parallel
echo "waiting 20s for keys to be generated..." 
sleep 20



echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.EncDecExample..."
echo "=========================================================="
# generate example ciphertexts
run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.basic.EncDecExample 1 $HDFS_HOST \
	"$HDFS_URL/gen/keys/my_public_key.txt" \
	"$HDFS_URL/gen/keys/my_secret_key.txt"

# wait for new ciphertexts to be generated; because spark process jobs in parallel
echo "waiting 20s for ciphertexts to be generated..."
sleep 20



echo "============================================================"
echo "Starting spiritlab.sparkfhe.example.basic.BasicOPsExample..."
echo "============================================================"
# run basic FHE arithmetic operation over encrypted data
run_spark_submit_command  sparkfhe_basic_OPs_examples  spiritlab.sparkfhe.example.basic.BasicOPsExample 2 $HDFS_HOST \
	"$HDFS_URL/gen/keys/my_public_key.txt" \
	"$HDFS_URL/gen/keys/my_secret_key.txt"



echo "=============================================================="
echo "Starting spiritlab.sparkfhe.example.basic.DotProductExample..."
echo "=============================================================="
# run FHE dot product over two encrypted vectors
run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.basic.DotProductExample 2 $HDFS_HOST \
	"$HDFS_URL/gen/keys/my_public_key.txt" \
	"$HDFS_URL/gen/keys/my_secret_key.txt"








