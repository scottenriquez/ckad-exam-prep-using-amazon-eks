# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f deployment.yaml
kubectl get pods -o wide