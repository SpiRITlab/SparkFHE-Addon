import os
import sys, socket

def write_hadoop_config_file(name, xml):
	f = open("/usr/local/hadoop/etc/hadoop/" + name, "w")
	f.write(xml)
	f.close()

def write_spark_config_file(name, xml):
	f = open("/spark-3.0.0-SNAPSHOT-bin-SparkFHE/conf/" + name, "w")
	f.write(xml)
	f.close()

master_file = open("master", "r")
slaves_file = open("slaves", "r")
master_address = master_file.read().strip()
slaves_address = slaves_file.read().strip()

master_file.close()
slaves_file.close()

os.system("apt-get update -y && apt-get install python -y && apt-get install -y default-jdk && apt-get install -y curl && apt-get install -y maven && apt-get install -y python-pip && pip install pyhdfs")

# Clear previous installation
os.system("rm -rf /usr/local/hadoop-*/ && unlink /usr/local/hadoop && rm -rf /data/hadoop/")
os.system("sed -i /JAVA_HOME/d /root/.bashrc && sed -i /HADOOP_HOME/d /root/.bashrc && sed -i /hadoop/d /root/.bashrc && sed -i /StrictHostKeyChecking/d /etc/ssh/ssh_config")

# Make Global Variables
os.system("echo 'export JAVA_HOME=/usr/lib/jvm/default-java/' >> /root/.bashrc")
os.system("echo 'export HADOOP_HOME=/usr/local/hadoop' >> /root/.bashrc")
os.system("echo 'export PATH=$PATH:/usr/local/hadoop/bin/:/usr/local/hadoop/sbin/' >> /root/.bashrc")

# Configure SSH
os.system("echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config")

# Configure Data Folder for Hadoop
os.system("mkdir -p /data/hadoop/node && mkdir -p /data/hadoop/data && mkdir -p /data/hadoop/name")

if not os.path.exists("/hadoop-2.9.2.tar.gz"):
    print("Downloading Hadoop 2.9.2....")
    os.system("curl http://apache.claz.org/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz > /hadoop-2.9.2.tar.gz")
    print("Download Hadoop 2.9.2 Successful...")

print("Install Hadoop 2.9.2 .....")
os.system("tar -xzf /hadoop-2.9.2.tar.gz -C /usr/local/ && ln -s /usr/local/hadoop-2.9.2/ /usr/local/hadoop")
print("Finished Install Hadoop 2.9.2....")

print("Config Hadoop 2.9.2 ...")
os.system("sed -i '/export JAVA_HOME/s/${JAVA_HOME}/\/usr\/lib\/jvm\/default-java\//g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh")

#core-site.xml
coreSiteXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- Default HDFS ip and port -->
    <property>
         <name>fs.defaultFS</name>
         <value>hdfs://%(master_address)s:9000</value>
    </property>
    <!-- default RPC IP，and use 0.0.0.0 to represent all ips-->
    <property>
	<name>dfs.namenode.rpc-bind-host</name>
	<value>0.0.0.0</value>
    </property>
</configuration>""" % dict(master_address=master_address)

write_hadoop_config_file("core-site.xml",coreSiteXml)

hdfsSiteXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
       <name>dfs.permissions</name>
      <value>false</value>
   </property>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>0.0.0.0:50070</value>
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>0.0.0.0:50090</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/data/hadoop/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/data/hadoop/data</value>
    </property>
</configuration>"""

write_hadoop_config_file("hdfs-site.xml",hdfsSiteXml)

mapredSiteXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>"""

write_hadoop_config_file("mapred-site.xml",mapredSiteXml)


yarnSiteXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>%(master_address)s</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
         <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
         <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
  <property>
    <name>yarn.resourcemanager.address</name>
    <value>%(master_address)s:8032</value>
  </property>
  <property>
     <name>yarn.resourcemanager.scheduler.address</name>
     <value>%(master_address)s:8030</value>
  </property>
  <property>
     <name>yarn.resourcemanager.resource-tracker.address</name>
     <value>%(master_address)s:8031</value>
  </property>
  <property>
     <name>yarn.resourcemanager.admin.address</name>
     <value>0.0.0.0:8033</value>
   </property>
   <property>
      <name>yarn.resourcemanager.webapp.address</name>
      <value>0.0.0.0:8088</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.address</name>
      <value>%(master_address)s:10020</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.webapp.address</name>
      <value>0.0.0.0:19888</value>
   </property>
</configuration>""" % dict(master_address=master_address)
write_hadoop_config_file("yarn-site.xml",yarnSiteXml)
write_hadoop_config_file("yarn-site-capacity.xml",yarnSiteXml)

yarnSitefairXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>%(master_address)s</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
         <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
         <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
  <property>
    <name>yarn.resourcemanager.address</name>
    <value>%(master_address)s:8032</value>
  </property>
  <property>
     <name>yarn.resourcemanager.scheduler.address</name>
     <value>%(master_address)s:8030</value>
  </property>
  <property>
     <name>yarn.resourcemanager.resource-tracker.address</name>
     <value>%(master_address)s:8031</value>
  </property>
  <property>
     <name>yarn.resourcemanager.admin.address</name>
     <value>0.0.0.0:8033</value>
   </property>
   <property>
      <name>yarn.resourcemanager.webapp.address</name>
      <value>0.0.0.0:8088</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.address</name>
      <value>%(master_address)s:10020</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.webapp.address</name>
      <value>0.0.0.0:19888</value>
   </property>
	<property>
		<name>yarn.resourcemanager.scheduler.class</name>
		<value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
	</property>
	<property>
		<name>yarn.scheduler.fair.allocation.file</name>
		<value>/usr/local/hadoop/etc/hadoop/fair-scheduler.xml</value>
	</property>
	<property>
		<name>yarn.scheduler.fair.preemption</name>
		<value>true</value>
	</property>
	<property>
		<name>yarn.scheduler.fair.user-as-default-queue</name>
		<value>true</value>
		<description>default is True</description>
	</property>
	<property>
		<name>yarn.scheduler.fair.allow-undeclared-pools</name>
		<value>false</value>
		<description>default is True</description>
	</property>
</configuration>
""" % dict(master_address=master_address)
write_hadoop_config_file("yarn-site-fair.xml",yarnSitefairXml)

fairSchedulerXml = """<?xml version="1.0"?>
<allocations>
  <queue name="sample_queue">
    <minResources>10000 mb,0vcores</minResources>
    <maxResources>90000 mb,0vcores</maxResources>
    <maxRunningApps>50</maxRunningApps>
    <weight>2.0</weight>
    <schedulingPolicy>fair</schedulingPolicy>
    <queue name="sample_sub_queue">
      <minResources>5000 mb,0vcores</minResources>
    </queue>
  </queue>
  <user name="sample_user">
    <maxRunningApps>30</maxRunningApps>
  </user>
  <userMaxAppsDefault>5</userMaxAppsDefault>
</allocations>
"""
write_hadoop_config_file("fair-scheduler.xml",fairSchedulerXml)

master = master_address
write_hadoop_config_file("master",master)
slaves = slaves_address
write_hadoop_config_file("slaves",slaves)

# Remove Older Spark Content
# os.system("rm -rf /usr/local/spark-*/ && unlink /usr/local/spark")
os.system("sed -i /spark/d /root/.bashrc && sed -i /SPARK_HOME/d /root/.bashrc ")

# Make Global Variables
os.system("echo 'export SPARK_HOME=/spark-3.0.0-SNAPSHOT-bin-SparkFHE/conf' >> /root/.bashrc")
# os.system("echo 'export PATH=$PATH:/usr/local/spark/bin' >> /root/.bashrc")
os.system("echo 'export PATH=$PATH:/spark-3.0.0-SNAPSHOT-bin-SparkFHE/bin/:/spark-3.0.0-SNAPSHOT-bin-SparkFHE/sbin/' >> /root/.bashrc")

# # Install Spark
# if not os.path.exists("/spark-2.3.2-bin-hadoop2.7.tgz"):
#     print("Downloading Spark 2.3.2....")
#     os.system("curl https://www-us.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz > /spark-2.3.2-bin-hadoop2.7.tgz")
#     print("Download Spark 2.3.2 Successful...")

# print("Install Spark 2.3.2.....")
# os.system("tar -xzf /spark-2.3.2-bin-hadoop2.7.tgz -C /usr/local/ && ln -s /usr/local/spark-2.3.2-bin-hadoop2.7/ /usr/local/spark")
# print("Finished Spark 2.3.2.....")

# spark-env.sh
sparkenvsh = """#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

# Options read when launching programs locally with
# ./bin/run-example or ./bin/spark-submit
# - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
# - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
# - SPARK_PUBLIC_DNS, to set the public dns name of the driver program

# Options read by executors and drivers running inside the cluster
# - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
# - SPARK_PUBLIC_DNS, to set the public DNS name of the driver program
# - SPARK_LOCAL_DIRS, storage directories to use on this node for shuffle and RDD data
# - MESOS_NATIVE_JAVA_LIBRARY, to point to your libmesos.so if you use Mesos

# Options read in YARN client mode
# - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
export HADOOP_CONF_DIR=%(hadoop_conf_address)s
# - YARN_CONF_DIR, to point Spark towards YARN configuration files when you use YARN
export YARN_CONF_DIR=$HADOOP_CONF_DIR
# - SPARK_EXECUTOR_CORES, Number of cores for the executors (Default: 1).
# - SPARK_EXECUTOR_MEMORY, Memory per Executor (e.g. 1000M, 2G) (Default: 1G)
# - SPARK_DRIVER_MEMORY, Memory for Driver (e.g. 1000M, 2G) (Default: 1G)

# Options for the daemons used in the standalone deploy mode
# - SPARK_MASTER_HOST, to bind the master to a different IP address or hostname
# - SPARK_MASTER_PORT / SPARK_MASTER_WEBUI_PORT, to use non-default ports for the master
# - SPARK_MASTER_OPTS, to set config properties only for the master (e.g. "-Dx=y")
# - SPARK_WORKER_CORES, to set the number of cores to use on this machine
export SPARK_WORKER_CORES=4
# - SPARK_WORKER_MEMORY, to set how much total memory workers have to give executors (e.g. 1000m, 2g)
export SPARK_WORKER_MEMORY=1024m
# - SPARK_WORKER_PORT / SPARK_WORKER_WEBUI_PORT, to use non-default ports for the worker
# - SPARK_WORKER_DIR, to set the working directory of worker processes
# - SPARK_WORKER_OPTS, to set config properties only for the worker (e.g. "-Dx=y")
# - SPARK_DAEMON_MEMORY, to allocate to the master, worker and history server themselves (default: 1g).
# - SPARK_HISTORY_OPTS, to set config properties only for the history server (e.g. "-Dx=y")
# - SPARK_SHUFFLE_OPTS, to set config properties only for the external shuffle service (e.g. "-Dx=y")
# - SPARK_DAEMON_JAVA_OPTS, to set config properties for all daemons (e.g. "-Dx=y")
# - SPARK_DAEMON_CLASSPATH, to set the classpath for all daemons
# - SPARK_PUBLIC_DNS, to set the public dns name of the master or workers

# Generic options for the daemons used in the standalone deploy mode
# - SPARK_CONF_DIR      Alternate conf dir. (Default: ${SPARK_HOME}/conf)
# - SPARK_LOG_DIR       Where log files are stored.  (Default: ${SPARK_HOME}/logs)
# - SPARK_PID_DIR       Where the pid file is stored. (Default: /tmp)
# - SPARK_IDENT_STRING  A string representing this instance of spark. (Default: $USER)
# - SPARK_NICENESS      The scheduling priority for daemons. (Default: 0)
# - SPARK_NO_DAEMONIZE  Run the proposed command in the foreground. It will not output a PID file.
# Options for native BLAS, like Intel MKL, OpenBLAS, and so on.
# You might get better performance to enable these options if using native BLAS (see SPARK-21305).
# - MKL_NUM_THREADS=1        Disable multi-threading of Intel MKL
# - OPENBLAS_NUM_THREADS=1   Disable multi-threading of OpenBLAS
""" % dict(hadoop_conf_address="/usr/local/hadoop/etc/hadoop")

write_spark_config_file("spark-env.sh",sparkenvsh)


# log4jproperties
log4jproperties = """#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set everything to be logged to the console
log4j.rootCategory=INFO, console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.err
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n

# Set the default spark-shell log level to WARN. When running the spark-shell, the
# log level for this class is used to overwrite the root logger's log level, so that
# the user can have different defaults for the shell and regular Spark apps.
log4j.logger.org.apache.spark.repl.Main=INFO

# Settings to quiet third party logs that are too verbose
log4j.logger.org.spark_project.jetty=WARN
log4j.logger.org.spark_project.jetty.util.component.AbstractLifeCycle=ERROR
log4j.logger.org.apache.spark.repl.SparkIMain$exprTyper=WARN
log4j.logger.org.apache.spark.repl.SparkILoop$SparkILoopInterpreter=WARN
log4j.logger.org.apache.parquet=ERROR
log4j.logger.parquet=ERROR

# SPARK-9183: Settings to avoid annoying messages when looking up nonexistent UDFs in SparkSQL with Hive support
log4j.logger.org.apache.hadoop.hive.metastore.RetryingHMSHandler=FATAL
log4j.logger.org.apache.hadoop.hive.ql.exec.FunctionRegistry=ERROR
"""

write_spark_config_file("log4j.properties",log4jproperties)

write_spark_config_file("core-site.xml",coreSiteXml)

write_spark_config_file("hdfs-site.xml",hdfsSiteXml)

write_spark_config_file("mapred-site.xml",mapredSiteXml)

write_spark_config_file("yarn-site.xml",yarnSiteXml)
write_spark_config_file("yarn-site-capacity.xml",yarnSiteXml)

write_spark_config_file("yarn-site-fair.xml",yarnSitefairXml)

write_spark_config_file("fair-scheduler.xml",fairSchedulerXml)

write_spark_config_file("master",master)

write_spark_config_file("slaves",slaves)


#format hdfs
os.system("/usr/local/hadoop/bin/hdfs namenode -format")