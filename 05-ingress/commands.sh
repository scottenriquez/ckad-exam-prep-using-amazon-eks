# assumes cluster created from 00-eksctl-configuration first
# install AWS Load Balancer Controller
# https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.html
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
rm iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=learning-kubernetes --approve
eksctl create iamserviceaccount \
  --cluster=learning-kubernetes \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.13.5/cert-manager.yaml
curl -Lo v2_7_2_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.2/v2_7_2_full.yaml
sed -i.bak -e '596,604d' ./v2_7_2_full.yaml
sed -i.bak -e 's|your-cluster-name|learning-kubernetes|' ./v2_7_2_full.yaml
kubectl apply -f v2_7_2_full.yaml
rm v2_7_2_full.yaml* 
kubectl get deployment -n kube-system aws-load-balancer-controller
# apply maniftests
kubectl apply -f ./ 
# gets address (e.g, http://k8s-default-ingress-08daebdfec-204015293.us-west-2.elb.amazonaws.com/) that can be opened in a web browser
kubectl describe ingress
# clean up
kubectl delete -f ./