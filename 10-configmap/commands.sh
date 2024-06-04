# build and test container locally
docker build -t scottenriquez/fastapi-example ./API/container/
docker run -p 8080:8000 scottenriquez/fastapi-example
curl http://localhost:8080/api/config

# deploy container to Elastic Container Registry
npm install
cd API
cdk deploy
cd ../

# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# entering busybox container shell
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
wget config-api-service:80/api/config
cat config
# returning to default shell
exit

# clean up
kubectl delete -f configmap.yaml
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml