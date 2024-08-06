# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./
# returns "uid=1000 gid=3000 groups=2000,3000"
kubectl logs pod/security-context-pod
# clean up
kubectl delete -f ./