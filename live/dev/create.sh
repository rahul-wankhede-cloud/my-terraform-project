#!/bin/bash

set -e

echo "Deploying platform infrastructure..."

cd platform
terraform init
terraform apply -auto-approve

echo "Platform deployment completed."

cd ../data

echo "Deploying data infrastructure..."

terraform init
terraform apply -auto-approve

echo "Data deployment completed."

echo "Infrastructure deployment completed successfully."