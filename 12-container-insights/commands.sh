# assumes cluster created from 00-eksctl-configuration first
# configure permissions
# change role to the one created by eksctl
aws iam attach-role-policy \
--role-name $EKSCTL_NODEGROUP_ROLE_NAME \
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
# wait until add-on is installed and give time for data to propagate
aws eks create-addon --cluster-name learning-kubernetes --addon-name amazon-cloudwatch-observability