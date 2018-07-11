# Create a google cloud account
First you need a google account, see cloud.google.com.

# GCloud SDK
Install the sdk from https://cloud.google.com/sdk/

# Terraform
Since we use Terraform to create the VMs you must install it from https://www.terraform.io/downloads.html

# Setup gcloud
In order to use gcloud yopu must first setup it for the current user. To perform this operation
run:
``` gcloud init ```

# Create a project for your VMs - The create-project.sh script
You must create a project for your VMs, using the create-project.sh script. This script requires a single argument, the project name which must be unique for the entire cloud. e.g. aivm-2018

## Credential files
The credential file created by the create-project script must be considered as CONFIDENTIAL. Do not commit it in any git repository.

## Operations performed by the script
1 - Create the project.
2 - It finds the billing account used by the current user and link it to the project.
3 - Create a service account to be used by terraform user.
4 - Create a terraform user for the projects and grants the iam roles to it in order to be able to create the different resources.
5 - Enable the different services we will need for the VMs.
6 - Output the information needed by terraform to create the infrastructure in the project.

## Output
The script output information like the location of the credentials file, the project name... 
This project.tfvars should not be commited and it MUST be used for any terraform command.

# Terraform template
The terraform-example directory contains different files to create a micro infrastructure. This is really simple, using a micro VM and network rule (except everything in blocked except ssh).

## Init the project
In order to init terraform you need to run the following command:
```terraform init```

## Plan the project
Before creating the infrastructure you should run the following command and double check that terraform will create the expected infrastructure (don't forget the vars file):
```terraform plan -var-file="project.tfvars"```

## Create the infrastructure
You can create the infra by running the following command
```terraform apply -var-file="project.tfvars"```

The command will create tfstate files, do not remove or commit then. You will need those files if you want to be able to destroy the infra quickly using a single command. Since those files are not stored in the google cloud you must keep them in order to destroy the infra created with terraform apply.

## Destroy the infra
It is really easy to destory quickly all the resources created during the apply by running the following command, assuming you didn't destroy the terraform states:
```terraform destroy -var-file="project.tfvars"```

# Connect to your VM
If you created a single compute instance you can use the gssh.sh script to connect to it. It will ask terraform to provide the instance information so you must run it from the directory you used for terraform.



