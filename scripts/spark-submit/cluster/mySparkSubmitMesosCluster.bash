#!/bin/bash

# run this script on the master node

if [ "$#" -eq 0 ]; then
    echo "bash mySparkSubmitCluster.bash [MESOS_MASTER_NODE_IP_ADDR]"
    exit
fi

# uncomment the following if verbose mode is needed
#verbose="--verbose"

ProjectRoot=../../../..
cd $ProjectRoot

SparkFHE_Addon_name="SparkFHE-Addon"
SparkFHE_distribution="/spark-3.1.0-SNAPSHOT-bin-SparkFHE"
HADOOP_HOME=$SparkFHE_distribution/hadoop


master=mesos://$1:7077
HDFS_HOST=hdfs://$1:9000
HDFS_PATH="/SparkFHE/HDFSFolder"
HDFS_URL=$HDFS_HOST$HDFS_PATH

deploy_mode=cluster
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
        --conf spark.mesos.executor.home=$SparkFHE_distribution \
        --conf spark.executorEnv.MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so \
		$jar_sparkfhe_examples $3 $4 $5 $6 $7 $8 $9
}


# increase the size of the vm
export MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"


echo "===================================================================="
echo "Starting spiritlab.sparkfhe.example.TestConnectionToSharedLibrary..."
echo "===================================================================="
# run basic operations without SparkFHE stuffs
run_spark_submit_command  TestConnectionToSharedLibrary  spiritlab.sparkfhe.example.TestConnectionToSharedLibrary



echo "================================================================"
echo "Starting spiritlab.sparkfhe.example.nonbatching.KeyGenExample..."
echo "================================================================"
# generate example key pairs
read -p "Do you want to run KeyGenExample? (y/n/q)" ynq
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_keygen  spiritlab.sparkfhe.example.nonbatching.KeyGenExample 1 $HDFS_HOST HELIB BGV
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
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac





echo "================================================================"
echo "Starting spiritlab.sparkfhe.example.nonbatching.EncDecExample..."
echo "================================================================"
# generate example ciphertexts
read -p "Do you want to run EncDecExample? (y/n/q)" ynq
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_encryption_decryption  spiritlab.sparkfhe.example.nonbatching.EncDecExample 1 $HDFS_HOST HELIB BGV \
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
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac



echo "=================================================================="
echo "Starting spiritlab.sparkfhe.example.nonbatching.BasicOPsExample..."
echo "=================================================================="
# run basic FHE arithmetic operation over encrypted data
read -p "Do you want to run BasicOPsExample? (y/n/q)" ynq
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_basic_OPs_examples  spiritlab.sparkfhe.example.nonbatching.BasicOPsExample 2 $HDFS_HOST HELIB BGV \
			"$HDFS_URL/gen/keys/my_public_key.txt" \
			"$HDFS_URL/gen/keys/my_secret_key.txt"
	;;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac



echo "===================================================================="
echo "Starting spiritlab.sparkfhe.example.nonbatching.DotProductExample..."
echo "===================================================================="
# run FHE dot product over two encrypted vectors
read -p "Do you want to run DotProductExample? (y/n/q)" ynq
case $ynq in
	[Yy]* ) 
run_spark_submit_command  sparkfhe_dot_product_examples  spiritlab.sparkfhe.example.nonbatching.DotProductExample 2 $HDFS_HOST HELIB BGV \
	"$HDFS_URL/gen/keys/my_public_key.txt" \
	"$HDFS_URL/gen/keys/my_secret_key.txt"
;;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y) or no (n).";;
esac


# run FHE total sum over vectors and matrices
read -p "Do you want to run TotalSumExample? (y/n/q)" ynq
echo "=================================================================="
echo "Starting spiritlab.sparkfhe.example.nonbatching.TotalSumExample..."
echo "=================================================================="
case $ynq in
	[Yy]* ) 
		run_spark_submit_command  sparkfhe_total_sum_examples  spiritlab.sparkfhe.example.nonbatching.TotalSumExample 2 $HDFS_HOST HELIB BGV \
			"$HDFS_URL/gen/keys/my_public_key.txt" \
			"$HDFS_URL/gen/keys/my_secret_key.txt";;
    [Nn]* ) 
		echo "Skip to the next job.";;
	[Qq]* )
		exit;;
    * ) 
		echo "Please answer yes (y), no (n), or quit (q).";;
esac






