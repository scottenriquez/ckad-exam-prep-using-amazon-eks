# assumes cluster created from 00-eksctl-configuration first
# install Metrics Server
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -f ./ 
# can also use kubectl top to see metrics
kubectl describe hpa php-apache
# clean up
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl delete -f ./ 