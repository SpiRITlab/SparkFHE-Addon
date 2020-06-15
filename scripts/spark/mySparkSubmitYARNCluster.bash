#!/bin/bash

# run this script on the master node

if [ "$#" -eq 0 ]; then
    echo "bash mySparkSubmitCluster.bash [MASTER_NODE_IP_ADDR]"
    exit
fi

# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../..
cd $ProjectRoot

SparkFHE_Addon_name="SparkFHE-Addon"
SparkFHE_distribution="/spark-3.0.0-SNAPSHOT-bin-SparkFHE"
HADOOP_HOME=$SparkFHE_distribution/hadoop


master=yarn
HDFS_HOST=hdfs://$1:9000
HDFS_PATH="/SparkFHE/HDFSFolder"
HDFS_URL=$HDFS_HOST$HDFS_PATH

deploy_mode=cluster
driver_memory=4g
executor_memory=4g
num_executors=10
executor_cores=10
total_executor_cores=16

ivysettings_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/ivysettings.xml
log4j_file=$SparkFHE_distribution/$SparkFHE_Addon_name/resources/config/log4j.properties
jar_sparkfhe_examples=$SparkFHE_distribution/examples/jars/$(ls examples/jars | grep sparkfhe-examples-)
jar_sparkfhe_api=$SparkFHE_distribution/jars/$(ls jars | grep sparkfhe-api-)
jar_sparkfhe_plugin=$SparkFHE_distribution/jars/$(ls jars | grep spark-fhe)
libSparkFHE_path=$SparkFHE_distribution/deps/lib:$HADOOP_HOME/lib/native:/usr/local/lib
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
		--num-executors $num_executors \
        --executor-cores $executor_cores \
        --driver-memory $driver_memory \
        --executor-memory $executor_memory \
        --total-executor-cores $total_executor_cores \
		--driver-class-path $java_class_path \
		--class $main_class_to_run \
		--jars $jar_sparkfhe_api,$jar_sparkfhe_plugin \
		--conf spark.eventLog.enabled=true \
		--conf spark.eventLog.dir=/tmp/spark-events \
		--conf spark.master.rest.enabled=true \
		--conf spark.serializer="org.apache.spark.serializer.KryoSerializer" \
		--conf spark.jars.ivySettings="$ivysettings_file" \
		--conf spark.driver.userClassPathFirst=true \
		--conf spark.driver.extraClassPath="$java_class_path" \
		--conf spark.driver.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.driver.extraJavaOptions="-Djava.library.path=$libSparkFHE_path -Dlog4j.configuration=$log4j_file"  \
		--conf spark.executor.extraClassPath="$java_class_path" \
		--conf spark.executor.extraLibraryPath="$libSparkFHE_path" \
		--conf spark.executor.extraJavaOptions="-Djava.library.path=$libSparkFHE_path -Dlog4j.configuration=$log4j_file"  \ 
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
read -p "Do you want to run KeyGenExample? (y/n)" yn
case $yn in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.basic.KeyGenExample 1 $HDFS_HOST
		while true; do
    		read -p "Check http://$1:5050 --- Has KeyGenExample finished? (y/n/q)" ynq
    		case $ynq in
        		[Yy]* ) break;;
        		[Nn]* ) echo "Can't proceed, please wait...";;
        		[Qq]* ) exit;;
        		* ) echo "Please answer yes (y), no (n), or quit (q).";;
    		esac
		done
	;;
    [Nn]* ) 
		echo "Skip to the next job.";;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac





echo "=========================================================="
echo "Starting spiritlab.sparkfhe.example.basic.EncDecExample..."
echo "=========================================================="
# generate example ciphertexts
read -p "Do you want to run EncDecExample? (y/n)" yn
case $yn in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.basic.EncDecExample 1 $HDFS_HOST \
				"$HDFS_URL/gen/keys/my_public_key.txt" \
				"$HDFS_URL/gen/keys/my_secret_key.txt"
		while true; do
    		read -p "Check http://$1:5050 --- Has EncDecExample finished? (y/n/q)" ynq
    		case $ynq in
        		[Yy]* ) break;;
        		[Nn]* ) echo "Can't proceed, please wait...";;
				[Qq]* ) exit;;
        		* ) echo "Please answer yes (y), no (n), or quit (q).";;
    		esac
		done
	;;
    [Nn]* ) 
		echo "Skip to the next job.";;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac



echo "============================================================"
echo "Starting spiritlab.sparkfhe.example.basic.BasicOPsExample..."
echo "============================================================"
# run basic FHE arithmetic operation over encrypted data
read -p "Do you want to run BasicOPsExample? (y/n)" yn
case $yn in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_basic_OPs_examples  spiritlab.sparkfhe.example.basic.BasicOPsExample 2 $HDFS_HOST \
			"$HDFS_URL/gen/keys/my_public_key.txt" \
			"$HDFS_URL/gen/keys/my_secret_key.txt"
	;;
    [Nn]* ) 
		echo "Skip to the next job.";;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac



echo "=============================================================="
echo "Starting spiritlab.sparkfhe.example.basic.DotProductExample..."
echo "=============================================================="
# run FHE dot product over two encrypted vectors
run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.basic.DotProductExample 2 $HDFS_HOST \
	"$HDFS_URL/gen/keys/my_public_key.txt" \
	"$HDFS_URL/gen/keys/my_secret_key.txt"








