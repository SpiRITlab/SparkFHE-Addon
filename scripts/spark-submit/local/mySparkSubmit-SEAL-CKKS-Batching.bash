#!/bin/bash

# This script will run four SparkFHE examples (Key Generation, Encryption/Decryption, Basic Arithmetics, Dot-Product).


# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../../..
cd $ProjectRoot

SparkFHE_distribution=`pwd`
SparkFHE_Addon_name="SparkFHE-Addon"
HADOOP_HOME=$SparkFHE_distribution/hadoop

master=local
deploy_mode=client

driver_memory=4g
executor_memory=4g
num_executors=4
executor_cores=4
total_executor_cores=4

ivysettings_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/ivysettings.xml
log4j_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/log4j.properties
jar_sparkfhe_examples=$SparkFHE_distribution/examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=$SparkFHE_distribution/jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=$SparkFHE_distribution/jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=$SparkFHE_distribution/deps/lib:$HADOOP_HOME/lib/native
java_class_path=.:$SparkFHE_distribution/jars

mkdir -p /tmp/spark-events

# run the actual spark submit job
# inputs: (spark_job_name, main_class_to_run, [opt.arg], [pk], [sk], [ctxt1], [ctxt2])
function run_spark_submit_command() {
	spark_job_name=$1 
	main_class_to_run=$2 
	rm -rf  ~/.ivy2
	bin/spark-submit $verbose \
		--name $spark_job_name \
		--master $master \
		--deploy-mode $deploy_mode \
		--num-executors $num_executors \
        --executor-cores $executor_cores \
        --driver-memory $driver_memory \
        --executor-memory $executor_memory \
        --total-executor-cores $total_executor_cores \
		--driver-class-path $java_class_path \
		--class $main_class_to_run \
		--jars $jar_sparkfhe_api,$jar_sparkfhe_plugin \
		--conf spark.jars.ivySettings="$ivysettings_file" \
		--conf spark.eventLog.enabled=true \
		--conf spark.eventLog.dir=/tmp/spark-events \
		--conf spark.driver.userClassPathFirst=true \
		--conf spark.serializer="org.apache.spark.serializer.KryoSerializer" \
		--conf spark.driver.extraClassPath="$java_class_path" \
		--conf spark.driver.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.driver.extraJavaOptions="-Djava.library.path=$libSparkFHE_path -Dlog4j.configuration=$log4j_file"  \
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


# Test whether we can load the libSparkFHE shared library correctly.
echo "===================================================================="
echo "Starting spiritlab.sparkfhe.example.TestConnectionToSharedLibrary..."
echo "===================================================================="
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.TestConnectionToSharedLibrary


# generate example key pairs
read -p "Do you want to run KeyGenExample? (y/n/q)" ynq
echo "============================================================="
echo "Starting spiritlab.sparkfhe.example.batching.KeyGenExample..."
echo "============================================================="
case $ynq in
	[Yy]* ) 
		mkdir -p $SparkFHE_distribution/gen/keys
		run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.batching.KeyGenExample local SEAL CKKS;;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# generate example ciphertexts
read -p "Do you want to run EncDecExample? (y/n/q)" ynq
echo "============================================================="
echo "Starting spiritlab.sparkfhe.example.batching.EncDecExample..."
echo "============================================================="
case $ynq in
	[Yy]* ) 
		mkdir -p $SparkFHE_distribution/gen/records
		run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.batching.EncDecExample local SEAL CKKS \
				"gen/keys/my_public_key.txt" \
				"gen/keys/my_secret_key.txt";;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# run basic FHE arithmetic operation over encrypted data
read -p "Do you want to run BasicOPsExample? (y/n/q)" ynq
echo "==============================================================="
echo "Starting spiritlab.sparkfhe.example.batching.BasicOPsExample..."
echo "==============================================================="
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_basic_OPs_examples  spiritlab.sparkfhe.example.batching.BasicOPsExample local SEAL CKKS \
			"gen/keys/my_public_key.txt" \
			"gen/keys/my_secret_key.txt";;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# run FHE dot product over two encrypted vectors
read -p "Do you want to run DotProductExample? (y/n/q)" ynq
echo "================================================================="
echo "Starting spiritlab.sparkfhe.example.batching.DotProductExample..."
echo "================================================================="
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.batching.DotProductExample local SEAL CKKS \
			"gen/keys/my_public_key.txt" \
			"gen/keys/my_secret_key.txt";;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# run FHE total sum over vectors and matrices
read -p "Do you want to run TotalSumExample? (y/n/q)" ynq
echo "==============================================================="
echo "Starting spiritlab.sparkfhe.example.batching.TotalSumExample..."
echo "==============================================================="
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_total_sum_examples  spiritlab.sparkfhe.example.batching.TotalSumExample local SEAL CKKS \
			"gen/keys/my_public_key.txt" \
			"gen/keys/my_secret_key.txt";;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# put back the environment variable
if [ "$HADOOP_CONF_DIR" != "" ] ; then
    export HADOOP_CONF_DIR="$HADOOP_CONF_DIR"
fi




