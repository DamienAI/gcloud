#!/bin/sh

instance_id=$(terraform output instance_id)
# project_id=$(terraform output project_id)

gcloud compute ssh ${instance_id}
# gcloud compute ssh ${instance_id} --project ${project_id}