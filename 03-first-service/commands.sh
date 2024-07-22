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