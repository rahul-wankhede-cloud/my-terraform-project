#!/bin/bash

set -e

ENV=$1

# Validate environment
if [[ "$ENV" != "dev" && "$ENV" != "qa" && "$ENV" != "prod" ]]; then
    echo "Invalid environment."
    echo "Usage: ./create.sh <environment>"
    echo "Valid environments: dev | qa | prod"
    exit 1
fi

echo "Deploying $ENV platform..."

cd live/$ENV/platform
terraform init
terraform plan

read -p "Do you want to apply these changes? (yes/no): " approval

if [[ "$approval" != "yes" ]]; then
    echo "Deployment cancelled."
    exit 1
fi
terraform apply -auto-approve

echo "Platform deployment completed."

echo "Deploying $ENV data..."

cd ../data
terraform init
terraform plan

read -p "Do you want to apply these changes? (yes/no): " approval

if [[ "$approval" != "yes" ]]; then
    echo "Deployment cancelled."
    exit 1
fi
terraform apply -auto-approve

echo "Data deployment completed."

echo "$ENV infrastructure deployed successfully."