# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./

# clean up
kubectl delete -f ./