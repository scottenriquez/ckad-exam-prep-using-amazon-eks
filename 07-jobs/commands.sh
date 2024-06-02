# assumes cluster created from 00-eksctl-configuration first
# creating a job via CLI
kubectl create job hello --image busybox -- echo "First job"
# hello-p6bf5 is the pod name
kubectl get pods
kubectl logs hello-p6bf5

kubectl apply -f job.yaml
# pi-hndqk is the pod name
kubectl get pods
kubectl logs pi-hndqk

kubectl apply -f cronjob.yaml
# hello-28621501-7rch5 is the pod name
kubectl get pods
kubectl logs hello-28621501-7rch5

kubectl delete -f job.yaml
kubectl delete -f cronjob.yaml