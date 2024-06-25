# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 10.100.120.203 is the service IP address
kubectl describe service nginx-service
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# can also use wget nginx-service instead of the IP address 
wget 10.100.120.203
cat index.html
# returning to default shell
exit

# clean up
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml