#!/bin/bash

# This script will run four SparkFHE examples (Key Generation, Encryption/Decryption, Basic Arithmetics, Dot-Product).


# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../..
cd $ProjectRoot

SparkFHE_distribution=`pwd`
SparkFHE_Addon_name="SparkFHE-Addon"

master=local
deploy_mode=client

ivysettings_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/ivysettings.xml
log4j_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/log4j.properties
jar_sparkfhe_examples=$SparkFHE_distribution/examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=$SparkFHE_distribution/jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=$SparkFHE_distribution/jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=$SparkFHE_distribution/libSparkFHE/lib
java_class_path=.:$SparkFHE_distribution/jars



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
		--conf spark.driver.userClassPathFirst=true \
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



echo "========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.BasicExample..."
echo "========================================================="
# run basic operations without SparkFHE stuffs
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicExample



echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.KeyGenExample..."
echo "=========================================================="
# create a folder for the generated keys
mkdir -p $SparkFHE_distribution/gen/keys
# generate example key pairs
run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.basic.KeyGenExample  local



echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.EncDecExample..."
echo "=========================================================="
# create a folder for the generated ciphertexts
mkdir -p $SparkFHE_distribution/gen/records
# generate example ciphertexts
run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.basic.EncDecExample  local \
	"$SparkFHE_distribution/gen/keys/my_public_key.txt" \
	"$SparkFHE_distribution/gen/keys/my_secret_key.txt"



echo "============================================================"
echo "Starting spiritlab.sparkfhe.example.basic.BasicOPsExample..."
echo "============================================================"
# run basic FHE arithmetic operation over encrypted data
run_spark_submit_command  sparkfhe_basic_examples  spiritlab.sparkfhe.example.basic.BasicOPsExample  local \
	"$SparkFHE_distribution/gen/keys/my_public_key.txt" \
	"$SparkFHE_distribution/gen/keys/my_secret_key.txt" 



echo "=============================================================="
echo "Starting spiritlab.sparkfhe.example.basic.DotProductExample..."
echo "=============================================================="
# run FHE dot product over two encrypted vectors
run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.basic.DotProductExample  local \
	"$SparkFHE_distribution/gen/keys/my_public_key.txt" \
	"$SparkFHE_distribution/gen/keys/my_secret_key.txt"




# put back the environment variable
if [ "$HADOOP_CONF_DIR" != "" ] ; then
    export HADOOP_CONF_DIR="$HADOOP_CONF_DIR"
fi




