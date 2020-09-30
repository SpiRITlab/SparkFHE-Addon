# Instructions for submitting Spark jobs to the demo cluster


Step 1: Upload crypto parameter files to HDFS, you can do so by running the following command.
```bash
sudo bash uploadSparkFHEaddon.bash
```

Step 2: Run the following submit command with <MesosMasterFullHostname> or <MesosMasterIPaddress>, without http:// and port number.
```bash
bash mySparkSubmitMesosCluster.bash <MesosMasterFullHostname>
```