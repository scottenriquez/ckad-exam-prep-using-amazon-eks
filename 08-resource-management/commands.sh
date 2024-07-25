# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./ 
# returns three pods (e.g., nginx-deployment-5449cb55b-jfgnc)
kubectl get pods -o wide
# clean up
kubectl delete -f ./ 