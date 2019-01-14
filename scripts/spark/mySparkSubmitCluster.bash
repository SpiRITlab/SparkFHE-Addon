#!/bin/bash

# run this script on the master node

if [ "$#" -eq 0 ]; then
    echo "bash mySparkSubmitCluster.bash [mesos://MASTER_NODE_IP_ADDR:7077 | yarn]"
    exit
fi

# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../..
cd $ProjectRoot

SparkFHE_Addon_name="SparkFHE-Addon"

master=$1

deploy_mode=cluster
executor_memory=1G
total_executor_cores=30

ivysettings_file=$SparkFHE_Addon_name/resources/config/ivysettings.xml
jar_sparkfhe_examples=examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=libSparkFHE/lib
java_class_path=.:jars


# run the actual spark submit job
# inputs: (spark_job_name, main_class_to_run, [opt.arg] [pk], [sk], [ctxt1], [ctxt2])
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
		--conf spark.jars.ivySettings="$ivysettings_file" \
		--conf spark.driver.userClassPathFirst=true \
		--conf spark.driver.extraClassPath="$java_class_path" \
		--conf spark.driver.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.driver.extraJavaOptions="-Djava.library.path=$libSparkFHE_path"  \
		--conf spark.executor.extraClassPath="$java_class_path" \
		--conf spark.executor.extraLibraryPath="$libSparkFHE_path" \
		$jar_sparkfhe_examples $3 $4 $5 $6 $7
}

# avoid using hadoop for storage
HADOOP_CONF_DIR=`echo $HADOOP_CONF_DIR`
if [ "$HADOOP_CONF_DIR" != "" ] ; then
    unset HADOOP_CONF_DIR
fi

# increase the size of the vm
export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"

# run basic operations without SparkFHE stuffs
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicExample

# generate example key pairs
run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.basic.KeyGenExample

# generate example ciphertexts
run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.basic.EncDecExample

# run basic FHE arithmetic operation over encrypted data
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicOPsExample 4 "gen/keys/my_public_key.txt" "gen/keys/my_secret_key.txt"   "gen/records/$(ls gen/records | grep ptxt_long_0)" "gen/records/$(ls gen/records | grep ptxt_long_1)"

# run FHE dot product over two encrypted vectors
run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.basic.DotProductExample 4 "gen/keys/my_public_key.txt" "gen/keys/my_secret_key.txt"   "gen/records/$(ls gen/records | grep vec_a)" "gen/records/$(ls gen/records | grep vec_b)"




# put back the environment variable
if [ "$HADOOP_CONF_DIR" != "" ] ; then
    export HADOOP_CONF_DIR="$HADOOP_CONF_DIR"
fi





