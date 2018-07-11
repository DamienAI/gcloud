#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo '\e[91mError, wrong number of arguments, usage:'
  echo $0 "ProjectName"
  exit 1
fi

TF_VAR_project_name=$1
echo "Project name will be: \e[93m$TF_VAR_project_name"

TF_CREDS=~/.config/gcloud/terraform-admin-${TF_VAR_project_name}.json

echo "\e[92m[1/7] Get billing acount"
TF_VAR_billing_account="$(gcloud beta billing accounts list --filter open=true -q --format="flattened(ACCOUNT_ID)" | grep name | sed -e 's/^.*\///')"
if [ -z "${TF_VAR_billing_account}" ]; then
  echo "\e[91mgcloud beta billing accounts list failed, did you run glcoud init ?"
  exit 1
fi

echo "Billing Account: \e[93m"$TF_VAR_billing_account

echo "\e[92m[2/7] Creating project and adding permissions for Terraform"

# Create simple project
gcloud projects create ${TF_VAR_project_name} --set-as-default

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud projects create failed"
  exit 1
fi

## TODO find project ID

#
# Associate the project to the billing account
#
echo "\e[92m[3/7] Associate the project to the billing account"
gcloud beta billing projects link ${TF_VAR_project_name} --billing-account ${TF_VAR_billing_account}

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud beta billing projects link failed"
  exit 1
fi

#
# Create a service account
# 
echo "\e[92m[4/7] Create a user account for terraform"
gcloud iam service-accounts create terraform --display-name "Terraform admin account"

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud iam service-accounts create failed"
  exit 1
fi

echo "\e[92m[5/7] Create and download the credential files for terraform"
gcloud iam service-accounts keys create ${TF_CREDS} --iam-account terraform@${TF_VAR_project_name}.iam.gserviceaccount.com

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud iam service-accounts keys create"
  exit 1
fi

#
# Grant access for the terraform admin project in IAM
#

echo "\e[92m[6/7] Grant access for the terraform admin to the project"

gcloud projects add-iam-policy-binding ${TF_VAR_project_name} \
  --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com \
  --role roles/viewer

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud error cannot grant roles/viewer to terraform service account"
  exit 1
fi

gcloud projects add-iam-policy-binding ${TF_VAR_project_name} \
  --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com \
  --role roles/storage.admin

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud error cannot grant roles/storage.admin to terraform service account"
  exit 1
fi

gcloud projects add-iam-policy-binding ${TF_VAR_project_name} \
  --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com \
  --role roles/compute.admin

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud error cannot grant roles/compute.admin to terraform service account"
  exit 1
fi

gcloud projects add-iam-policy-binding ${TF_VAR_project_name} \
  --member serviceAccount:terraform@${TF_VAR_project_name}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

if [ $? -ne 0 ]; then
  echo "\e[91mgcloud error cannot grant roles/iam.serviceAccountUser to terraform service account"
  exit 1
fi


gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com

echo "TF_VAR_project_name = \"${TF_VAR_project_name}\"" > project.tfvars
echo "TF_creds = \"${TF_CREDS}\"" >> project.tfvars
echo "TF_adminaccount = \"terraform\"" >> project.tfvars

echo "\e[92m[7/7] Done without any error"