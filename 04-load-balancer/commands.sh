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