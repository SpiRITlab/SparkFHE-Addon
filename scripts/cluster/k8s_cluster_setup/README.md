# Kubernetes cluster deployment testing
To learn more about Kubernetes, please visit [the official documentation](https://kubernetes.io/docs/tutorials/).

## Setup a single pod

#### To deploy
```bash 
kubectl apply -f sparkfhe-standalone.yaml
```

#### To view deployment
```bash
kubectl get deployments
```
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
sparkfhe-standalone   1/1     1            1           18s


#### To view pod
```bash
kubectl get pods
```
NAME                                   READY   STATUS    RESTARTS   AGE
sparkfhe-standalone-65b7889f6c-vnggf   1/1     Running   0          34s

#### To access the container
```bash 
kubectl exec -ti sparkfhe-standalone-65b7889f6c-vnggf -- bash
```


## Setup a cluster of pods
To be added