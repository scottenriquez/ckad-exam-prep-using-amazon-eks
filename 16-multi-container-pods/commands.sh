# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f database.configmap.yaml
kubectl apply -f backend.deployment.yaml
# check that the primary container is not yet running because the init container has not completed
# STATUS shows as Init:0/1
kubectl get pods
# deploy database and service
kubectl apply -f database.deployment.yaml
kubectl apply -f database.service.yaml
# verify that init container has completed
# get database pod
kubectl get pods
# forward ports
kubectl port-forward pod/postgres-database-697695b774-xcp9p 9000:8080
# open Adminer in browser
# see screenshot for logging in
wget http://localhost:9000
# clean up
kubectl delete -f ./ 