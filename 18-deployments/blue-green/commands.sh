# assumes cluster created from 00-eksctl-configuration first
# build and deploy to Docker Hub
docker login
docker build -t scottenriquez/blue-nginx-app ./blue
docker push scottenriquez/blue-nginx-app
docker build -t scottenriquez/green-nginx-app ./green
docker push scottenriquez/green-nginx-app

# deploy initial resources
kubectl apply -f ./

# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# verify blue in HTML
wget blue-test-service:9000
cat index.html
rm index.html
# verify green in HTML
wget green-test-service:9001
cat index.html
rm index.html
# verify blue in HTML
wget production-service:9000
cat index.html
rm index.html
# returning to default shell
exit

# perform cutover
# can also be done via manifest
kubectl set selector service production-service 'role=green'
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
# verify green in HTML
wget production-service:9000
cat index.html
rm index.html
# returning to default shell
exit

# clean up
kubectl delete -f ./