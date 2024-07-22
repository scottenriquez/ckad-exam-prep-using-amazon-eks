# Certified Kubernetes Application Developer (CKAD) Exam Prep Using Amazon EKS 

## Status
Work in progress. Full `README` coming soon.

## 00: `eksctl` Configuration
`eksctl` is a powerful CLI tool that quickly spins and tears down Kubernetes clusters via Amazon EKS. Nearly all of the exercises below start by leveraging the tool to create a cluster:

```shell title='00-eksctl-configuration/create-cluster.sh'
# before running these commands, first authenticate with AWS (e.g., aws configure sso)
eksctl create cluster -f cluster.yaml
# if connecting to an existing cluster
eksctl utils write-kubeconfig --cluster=learning-kubernetes
```

The default cluster configuration uses a two-node cluster of `t3.medium` instances to keep hourly costs as low as possible. At the time of writing this blog post, the exam tests on Kubernetes version 1.30.

```yaml title='00-eksctl-configuration/culster.yaml'
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: learning-kubernetes
  region: us-west-2 
  version: "1.30"

nodeGroups:
  - name: node-group-1 
    instanceType: t3.medium 
    desiredCapacity: 2 
    minSize: 2
    maxSize: 2
```

This cluster can be transient for learning purposes. To keep costs low, be sure to run the `destroy-cluster.sh` script to delete the cluster when not in use. I also recommend configuring an [AWS Budget](https://aws.amazon.com/aws-cost-management/aws-budgets/) as an extra measure of cost governance.

```shell title='00-eksctl-configuration/destroy-cluster.sh'
eksctl delete cluster --config-file=cluster.yaml --disable-nodegroup-eviction
```

## 01: First Deployment with `nginx`
With the cluster created, we can now make our first [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We'll start by creating a web server with three replicas using the latest `nginx` image:

```yaml title='01-first-deployment-with-nginx/deployment.yaml'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
```

The following commands leverage the manifest to create three [pods](https://kubernetes.io/docs/concepts/workloads/pods/) and inspect them:
```shell title = '01-first-deployment-with-nginx/commands.sh'
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./ 
# returns three pods (e.g., nginx-deployment-5449cb55b-jfgnc)
kubectl get pods -o wide
# clean up
kubectl delete -f ./ 
```

## Pod Communication over IP
The deployment in this example is identical to the previous: a web server with three replicas. Use the following commands to explore how IP addressing works for pods:

```shell title = '02-pod-communication-over-ip/commands.sh'
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./
# 192.168.51.32 is one of my pod's IP address, but yours will be different
# when the pod is replaced, this IP address changes
kubectl get pods -o wide
# creates a pod with the BusyBox image
# entering BusyBox container shell to communicate with pods in the cluster
kubectl run -it --rm --restart=Never busybox --image=busybox sh
# replace the IP address as needed
wget 192.168.51.32
# displys the nginx homepage code
cat index.html
# returning to default shell and deletes the BusyBox pod
exit
# clean up
kubectl delete -f ./ 
```