# before running these commands, first authenticate with AWS (e.g., aws configure sso)
eksctl create cluster -f cluster.yaml
eksctl utils write-kubeconfig --cluster=eksctl-cluster