# K3S Cluster Demo

> How to create k3s cluster with CloudSigma Terraform provider.

## Quick start

1. Install Terraform.
2. Set your CloudSigma credentials in terraform.tfvars file.
3. Generate a new SSH key under your home directory and set path to private and public key for `private_key`
   and `private_key` variable in `terraform.tfvars`.
4. cd into one of the example folders.
5. Run `terraform init`.
6. Run `terraform apply`.
7. After it's done deploying, the example will output an K3S server and agent IPs you can ssh into.
8. To clean up and delete all resources after you're done, run `terraform destroy`.
