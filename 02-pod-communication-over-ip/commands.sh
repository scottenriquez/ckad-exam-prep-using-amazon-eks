# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f deployment.yaml
# 192.168.51.32 is the initial pod IP address
# when the pod is replaced, this IP address changes
kubectl get pods -o wide
# entering busybox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# replace the IP address as needed
wget 192.168.51.32
cat index.html
# returning to default shell
exit
kubectl delete -f deployment.yaml