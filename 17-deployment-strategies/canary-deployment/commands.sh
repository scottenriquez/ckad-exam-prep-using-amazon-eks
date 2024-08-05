# assumes cluster created from 00-eksctl-configuration first
# build and deploy to Docker Hub
docker login
docker build -t scottenriquez/stable-nginx-app ./stable
docker push scottenriquez/stable-nginx-app
docker build -t scottenriquez/canary-nginx-app ./canary
docker push scottenriquez/canary-nginx-app
# deploy resources
kubectl apply -f ./
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=busybox sh
# repeat until a canary HTML page is shown
wget production-service:9000
cat index.html
rm index.html
# returning to default shell
exit
# clean up
kubectl delete -f ./