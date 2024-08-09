# assumes cluster created from 00-eksctl-configuration first
# install CLI
brew install argocd
# install ArgoCD on the cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# get initial password
argocd admin initial-password -n argocd
# forward ports to access the ArgoCD UI locally
kubectl port-forward svc/argocd-server -n argocd 8080:443