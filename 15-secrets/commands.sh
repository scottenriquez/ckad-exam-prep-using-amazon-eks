# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./
kubectl get pods
kubectl get secrets
# the output is 1f2d1e2e67df
kubectl logs busybox-56d48bfdb8-78cjg
# clean up
kubectl delete -f ./