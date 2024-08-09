# assumes cluster created from 00-eksctl-configuration first
# install Calico
# before installing the network plugin, all Pods will be able to communicate with one another
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
kubectl create -f - <<EOF
kind: Installation
apiVersion: operator.tigera.io/v1
metadata:
  name: default
spec:
  kubernetesProvider: EKS
  cni:
    type: AmazonVPC
  calicoNetwork:
    bgp: Disabled
EOF
kubectl apply -f ./
# get Pod IP addresses
kubectl get pods -o wide
# enter pod-three shell
kubectl exec -it pod-three -- sh
# ping pod-one and pod-two IP address (replace with yours)
# these commands should hang
ping 192.168.2.246
ping 192.168.21.2
# returning to default shell
exit
# enter pod-one shell
kubectl exec -it pod-one -- sh
# ping pod-two IP address (replace with yours)
# this command should be successful
ping 192.168.21.2
# ping pod-three IP address (replace with yours)
# this command should hang
ping 192.168.71.123
# returning to default shell
exit
# clean up
kubectl delete -f ./