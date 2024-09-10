# Terraform-aws-custom-cluster

## How to start cluster on EKS:
1. Navigate to the CustomTerraformCluster folder for a complex Terraform cluster setup.
2. Navigate to the CustomTerraformClusterEasy folder for a simpler Terraform cluster setup.

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


## Download AWS-CLI
Go on terminal and digit (download aws cli form MACOS)

https://awscli.amazonaws.com/AWSCLIV2.pkg -> download 

check on terminal if ended: 
aws --version

## Download Kubectl 
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

## Run on Local the cluster:
```
aws eks update-kubeconfig --name (cluster name)
kubectl config get-contexts
kubectl config use-context (cluster name)
```
I suggest to use lens to control your cluster: https://k8slens.dev

#### Addon if want to install manually efs-csi driver and metric-server:
```
helm repo update
helm repo list 
``` -> verify that the aws-efs-csi-driver repo is added, if not, add it

```
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm search repo aws-efs-csi-driver
helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
```

https://github.com/kubernetes-sigs/metrics-server

``
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
```


## How to choose disk dimension:
https://aws.amazon.com/it/ec2/instance-types/