import os
import sys, socket

def get_spark_directory(address, level_to_go_back):
  folders = address.split('/')
  del folders[0]
  retained_length = len(folders) - level_to_go_back
  reconstructed_string = ""
  for i in range(0, retained_length):
    reconstructed_string = folders[i] + '/'

  return "/" + reconstructed_string

SPARK_HOME = get_spark_directory(os.path.dirname(os.path.realpath(__file__)), 4)
SPARK_CONFIG_LOCATION = SPARK_HOME + "conf/"

installation_list=["python", "default-jdk", "maven", "curl", "python-pip"]

JAVA_HOME = "/usr/lib/jvm/default-java/"

HADOOP_DATA = "/data/hadoop/"
HADOOP_HOME = "/usr/local/hadoop/"
HADOOP_CONFIG_LOCATION = HADOOP_HOME + "etc/hadoop/"
HADOOP_VERSION = "2.9.2"
HADOOP_WEB_SOURCE = "http://apache.claz.org/hadoop/common/"

master_file_name = "master"
slaves_file_name = "slaves"

def write_hadoop_config_file(name, xml):
	f = open(HADOOP_CONFIG_LOCATION + name, "w")
	f.write(xml)
	f.close()

def write_spark_config_file(name, xml):
	f = open(SPARK_CONFIG_LOCATION + name, "w")
	f.write(xml)
	f.close()

master_file = open(master_file_name, "r")
slaves_file = open(slaves_file_name, "r")
master_address = master_file.read().strip()
slaves_address = slaves_file.read().strip()

master_file.close()
slaves_file.close()

os.system("apt-get update -y")

for program_name in installation_list:
  os.system("apt-get install -y %s"%(program_name))

os.system("pip install pyhdfs")

# Clear previous installation
os.system("rm -rf /usr/local/hadoop-*/ && unlink %s && rm -rf %s"%(HADOOP_HOME,HADOOP_DATA))
os.system("sed -i /JAVA_HOME/d /root/.bashrc && sed -i /HADOOP_HOME/d /root/.bashrc && \
 sed -i /hadoop/d /root/.bashrc && sed -i /StrictHostKeyChecking/d /etc/ssh/ssh_config")

# Make Global Variables
os.system("echo 'export JAVA_HOME=%s' >> /root/.bashrc"%(JAVA_HOME))
os.system("echo 'export HADOOP_HOME=%s' >> /root/.bashrc"%(HADOOP_HOME))
os.system("echo 'export PATH=$PATH:%sbin/:%ssbin/' >> /root/.bashrc"%(HADOOP_HOME, HADOOP_HOME))

# Configure SSH
os.system("echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config")

# Configure Data Folder for Hadoop
os.system("mkdir -p %snode/ && -p %sdata/ && -p %sname/"%(HADOOP_DATA,HADOOP_DATA,HADOOP_DATA))


if not os.path.exists(os.path.join('/hadoop-', HADOOP_VERSION, ".tar.gz")):
    print("Downloading Hadoop %s...."%(HADOOP_VERSION))
    os.system("curl %shadoop-%s/hadoop-%s.tar.gz > /hadoop-%s.tar.gz"%(HADOOP_WEB_SOURCE, HADOOP_VERSION, HADOOP_VERSION, HADOOP_VERSION))
    print("Download Hadoop %s Successful..."%(HADOOP_VERSION))

print("Install Hadoop %s ....."%(HADOOP_VERSION))
HADOOP_HOME_TEMP = HADOOP_HOME[:-1]
os.system("tar -xzf /hadoop-%s.tar.gz -C /usr/local/ && ln -s %s-%s/ %s"%(HADOOP_VERSION, HADOOP_HOME_TEMP, HADOOP_VERSION, HADOOP_HOME_TEMP))
print("Finished Install Hadoop %s...."%(HADOOP_VERSION))

# hadoop-env.sh
hadoopenvsh = """# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.
export JAVA_HOME=%(java_home)s

# The jsvc implementation to use. Jsvc is required to run secure datanodes
# that bind to privileged ports to provide authentication of data transfer
# protocol.  Jsvc is not required if SASL is configured for authentication of
# data transfer protocol using non-privileged ports.
#export JSVC_HOME=${JSVC_HOME}

export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}

# Extra Java CLASSPATH elements.  Automatically insert capacity-scheduler.
for f in $HADOOP_HOME/contrib/capacity-scheduler/*.jar; do
  if [ "$HADOOP_CLASSPATH" ]; then
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$f
  else
    export HADOOP_CLASSPATH=$f
  fi
done

# The maximum amount of heap to use, in MB. Default is 1000.
#export HADOOP_HEAPSIZE=
#export HADOOP_NAMENODE_INIT_HEAPSIZE=""

# Enable extra debugging of Hadoop's JAAS binding, used to set up
# Kerberos security.
# export HADOOP_JAAS_DEBUG=true

# Extra Java runtime options.  Empty by default.
# For Kerberos debugging, an extended option set logs more invormation
# export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"

# Command specific options appended to HADOOP_OPTS when specified
export HADOOP_NAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_NAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Dhadoop.security.logger=ERROR,RFAS $HADOOP_DATANODE_OPTS"

export HADOOP_SECONDARYNAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_SECONDARYNAMENODE_OPTS"

export HADOOP_NFS3_OPTS="$HADOOP_NFS3_OPTS"
export HADOOP_PORTMAP_OPTS="-Xmx512m $HADOOP_PORTMAP_OPTS"

# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS"
# set heap args when HADOOP_HEAPSIZE is empty
if [ "$HADOOP_HEAPSIZE" = "" ]; then
  export HADOOP_CLIENT_OPTS="-Xmx512m $HADOOP_CLIENT_OPTS"
fi
#HADOOP_JAVA_PLATFORM_OPTS="-XX:-UsePerfData $HADOOP_JAVA_PLATFORM_OPTS"

# On secure datanodes, user to run the datanode as after dropping privileges.
# This **MUST** be uncommented to enable secure HDFS if using privileged ports
# to provide authentication of data transfer protocol.  This **MUST NOT** be
# defined if SASL is configured for authentication of data transfer protocol
# using non-privileged ports.
export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER}

# Where log files are stored.  $HADOOP_HOME/logs by default.
#export HADOOP_LOG_DIR=${HADOOP_LOG_DIR}/$USER

# Where log files are stored in the secure data environment.
#export HADOOP_SECURE_DN_LOG_DIR=${HADOOP_LOG_DIR}/${HADOOP_HDFS_USER}

###
# HDFS Mover specific parameters
###
# Specify the JVM options to be used when starting the HDFS Mover.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HADOOP_MOVER_OPTS=""

###
# Router-based HDFS Federation specific parameters
# Specify the JVM options to be used when starting the RBF Routers.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HADOOP_DFSROUTER_OPTS=""
###

###
# Advanced Users Only!
###

# The directory where pid files are stored. /tmp by default.
# NOTE: this should be set to a directory that can only be written to by 
#       the user that will run the hadoop daemons.  Otherwise there is the
#       potential for a symlink attack.
export HADOOP_PID_DIR=${HADOOP_PID_DIR}
export HADOOP_SECURE_DN_PID_DIR=${HADOOP_PID_DIR}

# A string representing this instance of hadoop. $USER by default.
export HADOOP_IDENT_STRING=$USER
"""% dict(java_home=JAVA_HOME)

write_hadoop_config_file("hadoop-env.sh",hadoopenvsh)


# core-site.xml
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


# hdfs-site.xml
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

# mapred-site.xml
mapredSiteXml = """<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>"""

write_hadoop_config_file("mapred-site.xml",mapredSiteXml)

# yarn-site.xml or yarn-site-capacity.xml
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

# yarn-site-fair.xml
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

# fair-scheduler.xml
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
os.system("echo 'export SPARK_HOME=%s' >> /root/.bashrc"%(SPARK_HOME))
# os.system("echo 'export PATH=$PATH:/usr/local/spark/bin' >> /root/.bashrc")
os.system("echo 'export PATH=$PATH:%sbin/:%ssbin/' >> /root/.bashrc"%(SPARK_HOME, SPARK_HOME))

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
# - SPARK_CONF_DIR      Alternate conf dir. (Default: %(spark_home)s/conf)
# - SPARK_LOG_DIR       Where log files are stored.  (Default: %(spark_home)s/logs)
# - SPARK_PID_DIR       Where the pid file is stored. (Default: /tmp)
# - SPARK_IDENT_STRING  A string representing this instance of spark. (Default: $USER)
# - SPARK_NICENESS      The scheduling priority for daemons. (Default: 0)
# - SPARK_NO_DAEMONIZE  Run the proposed command in the foreground. It will not output a PID file.
# Options for native BLAS, like Intel MKL, OpenBLAS, and so on.
# You might get better performance to enable these options if using native BLAS (see SPARK-21305).
# - MKL_NUM_THREADS=1        Disable multi-threading of Intel MKL
# - OPENBLAS_NUM_THREADS=1   Disable multi-threading of OpenBLAS
""" % dict(hadoop_conf_address=HADOOP_CONFIG_LOCATION, spark_home=SPARK_HOME)

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

write_spark_config_file("hadoop-env.sh",hadoopenvsh)

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
os.system("%sbin/hdfs namenode -format"%(HADOOP_HOME))