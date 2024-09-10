https://registry.terraform.io/providers/hashicorp/google/latest/docs


1. go on GCP -> Cloud Storage
2. Create a bucket (same name of providers>bucket) -> enable version controll
3. to run locally on yout pc, you need to configure default application credential

```
gcloud auth application-default login
```
then use:

```
terraform init
terraform plan
terraform validate
terraform apply -auto-approve
```