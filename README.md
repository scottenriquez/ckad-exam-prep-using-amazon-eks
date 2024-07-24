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
With the cluster created, we can now make our first [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We'll start by creating a web server with three replicas using the latest `nginx` image:

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

The following commands leverage the manifest to create three [Pods](https://kubernetes.io/docs/concepts/workloads/pods/) and inspect them:
```shell title = '01-first-deployment-with-nginx/commands.sh'
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./ 
# returns three pods (e.g., nginx-deployment-5449cb55b-jfgnc)
kubectl get pods -o wide
# clean up
kubectl delete -f ./ 
```

## 02: Pod Communication over IP
The Deployment in this example is identical to the previous: a web server with three replicas. Use the following commands to explore how IP addressing works for Pods:

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

## 03: First Service
Since each Pod has a separate IP address that can change, we can use a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to keep track of the Pod's IP addresses on our behalf. This abstraction allows us to group Pods via a [selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) and reference them via a single Service. In the Service manifest and leveraging the same Deployment as before, we specify how to select which Pods to target, what port to expose, and the type of Service:

```yaml title='03-first-service/service.yaml'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    name: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      # nodePort is used for external access
  # ClusterIP services are only accessible within the cluster
  # NodePort services are a way to expose ClusterIP services externally without using a cloud provider's load balancer
  # LoadBalancer is covered in the next section
  type: ClusterIP
```

Using the Service, we have a single interface to the three `nginx` replicas. We can also use the Service name instead of its IP address.

```shell title='03-first-service'
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./
# 10.100.120.203 is the service IP address
kubectl describe service nginx-service
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=busybox sh
# can also use the IP address instead
wget nginx-service
cat index.html
# returning to default shell
exit
# clean up
kubectl delete -f ./
```

## 04: Elastic Load Balancers for Kubernetes Services
A significant benefit of Kubernetes is that it can create and manage resources in AWS on our behalf. Using the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/), we can specify [annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/) to create a Service of type `LoadBalancer` that leverages an Elastic Load Balancer. Using the same Deployment from the past two sections, this manifest illustrates how to leverage a Network Load Balancer for the Service:

```yaml title='04-load-balancer/load-balancer.yaml'
apiVersion: v1
kind: Service
metadata:
  name: nginx-load-balancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    # by default, a Classic Load Balancer is created
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/introduction.html
    # this annotation creates a Network Load Balancer
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  selector:
    name: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: "192.0.2.127" 
```

The following commands deploy the `LoadBalancer` service:
```shell title='04-load-balancer/commands.sh'
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./ 
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=busybox sh
wget nginx-load-balancer
cat index.html
# returning to default shell
exit
# clean up
# this command ensures that the load balancer is deleted
# be sure to run before destroying the cluster
kubectl delete -f ./
```

## 05: Ingress
Services of type `ClusterIP` only support internal cluster networking. The `NodePort` configuration allows for external communication by exposing the same port on every node (i.e., EC2 instances). However, this introduces a different challenge because the consumer must know the nodes' IP addresses (and nodes are often transient). The `LoadBalancer` configuration has a 1:1 relationship with the service. If you have numerous services, the cost of load balancers may not be feasible. Ingress alleviates some of these challenges by providing a single external interface over HTTP or HTTPS with support for path-based routing. Leveraging the `nginx` example one last time, we can create an Ingress that exposes a Service with the `NodePort` configuration via an Application Load Balancer.

```yaml title='05-ingress/ingress.yaml'
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port: 
                  number: 80
```

The following commands install the AWS Load Balancer Controller, configure required IAM permissions, and deploy the Ingress. Be sure to set the `$AWS_ACCOUNT_ID` environment variable first.

```shell title='05-ingress/commands.sh'
# assumes cluster created from 00-eksctl-configuration first
# install AWS Load Balancer Controller
# https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.html
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
rm iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=learning-kubernetes --approve
eksctl create iamserviceaccount \
  --cluster=learning-kubernetes \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.13.5/cert-manager.yaml
curl -Lo v2_7_2_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.2/v2_7_2_full.yaml
sed -i.bak -e '596,604d' ./v2_7_2_full.yaml
sed -i.bak -e 's|your-cluster-name|learning-kubernetes|' ./v2_7_2_full.yaml
kubectl apply -f v2_7_2_full.yaml
rm v2_7_2_full.yaml* 
kubectl get deployment -n kube-system aws-load-balancer-controller
# apply maniftests
kubectl apply -f ./ 
# gets address (e.g, http://k8s-default-ingress-08daebdfec-204015293.us-west-2.elb.amazonaws.com/) that can be opened in a web browser
kubectl describe ingress
# clean up
kubectl delete -f ./
```

## 06: Jobs and CronJobs

Jobs are a powerful mechanism that reliably ensures that Pods are completed successfully. CronJobs extend this functionality by supporting a recurring schedule.

```yaml title='06-jobs-and-cronjobs/job.yaml'
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

```yaml title='06-jobs-and-cronjobs/cronjob.yaml'
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  # runs every minute
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```