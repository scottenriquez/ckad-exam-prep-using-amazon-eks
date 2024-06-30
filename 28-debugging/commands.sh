# TODO: expand
kubectl get pod my-pod -o yaml
kubectl describe pod my-pod
kubectl exec my-pod -it sh
kubectl logs my-pod
# streaming
kubectl logs -f my-pod
# view latest logs
kubectl logs --tail=10 my-pod
kubectl logs --since=1h my-pod
# view all logs for a label
kubectl logs -l app=nginx
# view logs from a previously terminated container
kubectl logs -p my-pod 
kubectl logs my-pod -c my-container
# create an ephemeral container with debug tooling
kubectl debug my-pod -it --copy-to=my-pod-debug --container=my-container -- sh