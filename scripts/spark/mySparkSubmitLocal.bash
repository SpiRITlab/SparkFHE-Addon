#!/bin/bash

# This script will run four SparkFHE examples (Key Generation, Encryption/Decryption, Basic Arithmetics, Dot-Product).


# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../..
cd $ProjectRoot

SparkFHE_distribution=`pwd`
SparkFHE_Addon_name="SparkFHE-Addon"
HADOOP_HOME=$SparkFHE_distribution/hadoop

master=local
deploy_mode=client

ivysettings_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/ivysettings.xml
log4j_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/log4j.properties
jar_sparkfhe_examples=$SparkFHE_distribution/examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=$SparkFHE_distribution/jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=$SparkFHE_distribution/jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=$SparkFHE_distribution/libSparkFHE/lib:$HADOOP_HOME/lib/native:/usr/local/lib:/usr/local/hadoop/lib/native
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


# run basic operations without SparkFHE stuffs
echo "========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.BasicExample..."
echo "========================================================="
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicExample


# generate example key pairs
read -p "Do you want to run KeyGenExample? (y/n/q)" ynq
echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.KeyGenExample..."
echo "=========================================================="
case $ynq in
	[Yy]* ) 
		mkdir -p $SparkFHE_distribution/gen/keys
		run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.basic.KeyGenExample local;;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac


# generate example ciphertexts
read -p "Do you want to run EncDecExample? (y/n/q)" ynq
echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.EncDecExample..."
echo "=========================================================="
case $ynq in
	[Yy]* ) 
		mkdir -p $SparkFHE_distribution/gen/records
		run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.basic.EncDecExample local \
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
echo "============================================================"
echo "Starting spiritlab.sparkfhe.example.basic.BasicOPsExample..."
echo "============================================================"
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_basic_OPs_examples  spiritlab.sparkfhe.example.basic.BasicOPsExample local \
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
echo "=============================================================="
echo "Starting spiritlab.sparkfhe.example.basic.DotProductExample..."
echo "=============================================================="
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.basic.DotProductExample local \
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




