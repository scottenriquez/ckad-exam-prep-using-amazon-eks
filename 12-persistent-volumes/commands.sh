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
eksctl create addon --name aws-ebs-csi-driver --cluster learning-kubernetes --service-account-role-arn arn:aws:iam::196736724465:role/AmazonEKS_EBS_CSI_DriverRole --force
# create gp3 storage class
kubectl apply -f storage-class.yaml

# static volume provisioning
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f pod.yaml

# clean up
kubectl delete -f storage-class.yaml
kubectl delete -f persistent-volume-claim.yaml
kubectl delete -f pod.yaml
