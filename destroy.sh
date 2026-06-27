#!/bin/bash

set -e

ENV=$1

# Validate environment
if [[ "$ENV" != "dev" && "$ENV" != "qa" && "$ENV" != "prod" ]]; then
    echo "Invalid environment."
    echo "Usage: ./destroy.sh <environment>"
    echo "Valid environments: dev | qa | prod"
    exit 1
fi

echo "Destroying $ENV data..."

cd live/$ENV/data
terraform destroy -auto-approve

echo "Data infrastructure destroyed."

echo "Destroying $ENV platform..."

cd ../platform
terraform destroy -auto-approve

echo "Platform infrastructure destroyed."

echo "$ENV infrastructure destroyed successfully."