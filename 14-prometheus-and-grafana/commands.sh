# assumes cluster created from 00-eksctl-configuration first
# install Helm on local machine
# https://helm.sh/docs/intro/install/
brew install helm

# install Helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install v60-0-1 prometheus-community/kube-prometheus-stack --version 60.0.1

# use http://localhost:9090 to access Prometheus
kubectl port-forward svc/prometheus-operated 9090
# get Grafana password for admin
kubectl get secret v60-0-1-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# use http://localhost:3000 to access Grafana
kubectl port-forward svc/v60-0-1-grafana 3000:80

# uninstall Helm charts
helm uninstall v60-0-1