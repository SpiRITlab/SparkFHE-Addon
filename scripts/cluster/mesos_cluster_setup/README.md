On the Mesos master run: 
```bash
sudo ./install_mesos_master.bash masterHostname,worker1Hostname,worker2Hostname,...
```

On Master node run:
```bash
sudo systemctl start mesos-master
sudo systemctl restart zookeeper
```

On Worker node run:
```bash
sudo systemctl start mesos-slave
```
