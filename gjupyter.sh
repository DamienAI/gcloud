#!/bin/sh

instance_id=$(terraform output instance_id)
gcloud compute ssh ${instance_id} -- -L 8080:localhost:8080
