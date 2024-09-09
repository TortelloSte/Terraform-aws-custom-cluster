# Terraform-aws-custom-cluster

### How to start cluster on EKS:
run:
```
terraform init
terraform plan
terraform validate
terraform apply -auto-approve
```

if needed, to delete cluster after creation
```
terraform destroy -auto-approve
```


# Download AWS-CLI
Go on terminal and digit (download aws cli form MACOS)

https://awscli.amazonaws.com/AWSCLIV2.pkg -> download 

check on terminal if ended: 
aws --version

# Download Kubectl 
download kubectl for macOS apple silicon:
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl

kubectl version --client
rm kubectl.sha256
```

# Run on Local the cluster:
```
aws eks update-kubeconfig --name (cluster name)
kubectl config get-contexts
kubectl config use-context (cluster name)
```
