# assumes cluster created from 00-eksctl-configuration first
# build and test container locally
docker build -t scottenriquez/fastapi-probes ./api-cdk/container/
docker run -p 8080:8000 scottenriquez/fastapi-probes
curl http://localhost:8080/api/healthy
curl http://localhost:8080/api/ready
# deploy container to Elastic Container Registry
npm install
cd api-cdk 
cdk deploy
cd ../
kubectl apply -f ./ 
# wait for Deployment to be ready
kubectl get deployments
# entering BusyBox container shell
kubectl run -it --rm --restart=Never busybox --image=busybox sh
wget probe-api-service:80/api/healthy
wget probe-api-service:80/api/ready
cat healthy
cat ready
# returning to default shell
exit
# clean up
kubectl delete -f ./