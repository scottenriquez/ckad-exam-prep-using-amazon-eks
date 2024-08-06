# assumes cluster created from 00-eksctl-configuration first
# create an OIDC provider
eksctl utils associate-iam-oidc-provider --cluster learning-kubernetes --approve
# install aws-ebs-csi-driver
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster learning-kubernetes \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve
eksctl create addon --name aws-ebs-csi-driver --cluster learning-kubernetes --service-account-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/AmazonEKS_EBS_CSI_DriverRole --force
# wait until add-on is installed
# create gp3 storage class
kubectl apply -f storage-class.yaml
# dynamic volume provisioning
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f pod.yaml
# entering Pod shell
kubectl exec -it app -- /bin/sh
cd data/
cat out.txt
# returning to default shell
exit
# clean up
# deletes the EBS volume
kubectl delete -f ./ 