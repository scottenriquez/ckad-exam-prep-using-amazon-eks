# assumes cluster created from 00-eksctl-configuration first
# build and test container locally
docker build -t scottenriquez/fastapi-example ./api-cdk/container/
docker run -p 8080:8000 scottenriquez/fastapi-example
curl http://localhost:8080/api/config
# deploy container to Elastic Container Registry
npm install
cd api-cdk 
cdk deploy
cd ../
# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./ 
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=busybox sh
wget config-api-service:80/api/config
cat config
# returning to default shell
exit
# clean up
kubectl delete -f ./