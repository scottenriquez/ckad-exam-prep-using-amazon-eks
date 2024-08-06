# assumes cluster created from 00-eksctl-configuration first
kubectl apply -f ./
# entering Pod shell
kubectl exec -it reader-pod -- sh
# install curl
apk --update add curl
# get Pods
# allowed by Role
curl -s --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://kubernetes/api/v1/namespaces/default/pods
# get Secrets
# denied by Role
curl -s --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://kubernetes/api/v1/namespaces/default/secrets
exit
# clean up
kubectl delete -f ./