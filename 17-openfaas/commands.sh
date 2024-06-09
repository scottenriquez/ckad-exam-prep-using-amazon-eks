# assumes cluster created from 00-eksctl-configuration first
# install CLI on local machine
# https://docs.openfaas.com/cli/install/
brew install faas-cli
# create namespace
kubectl apply -f namespace.yaml
# add Helm charts to cluster
helm repo add openfaas https://openfaas.github.io/faas-netes
helm install my-openfaas openfaas/openfaas --version 14.2.49 --namespace openfaas

# forward the API's port in a separate tab
kubectl port-forward svc/gateway 8080 --namespace openfaas
# fetch password and log in
faas-cli login --password $(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode)

# create a function
faas-cli new --lang python openfaas-python-function
# requires Docker running locally
faas-cli build -f openfaas-python-function.yml
# push to DockerHub
faas-cli publish -f openfaas-python-function.yml
faas-cli deploy -f openfaas-python-function.yml