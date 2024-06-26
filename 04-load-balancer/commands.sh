# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f deployment.yaml
kubectl apply -f load-balancer.yaml

# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# can also use wget nginx-load-balancer instead of the IP address 
wget 10.100.0.100
cat index.html
# returning to default shell
exit

# clean up
kubectl delete -f deployment.yaml
kubectl delete -f load-balancer.yaml