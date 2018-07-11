# Specify the provider (GCP, AWS, Azure), here we use google cloud
provider "google" {
  credentials = "${file(var.TF_creds)}"
  project     = "${var.TF_VAR_project_name}"
  region      = "${var.TF_VAR_region}"
}

output "project_name" {
  value = "${var.TF_VAR_project_name}"
}
