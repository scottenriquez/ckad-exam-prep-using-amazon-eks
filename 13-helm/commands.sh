# assumes cluster created from 00-eksctl-configuration first
# install Helm on local machine
# https://helm.sh/docs/intro/install/
brew install helm

# install Helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install v60-0-1 prometheus-community/kube-prometheus-stack