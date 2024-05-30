kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
# 10.100.120.203 is the service IP address
kubectl describe service nginx-service
# entering busybox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# can also run wget nginx-service without typing the IP address
wget 10.100.120.203
cat index.html
# returning to default shell
exit
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml