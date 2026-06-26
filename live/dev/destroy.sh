#!/bin/bash

set -e

echo "Destroying data infrastructure..."

cd data
terraform destroy -auto-approve

echo "Data destruction completed."

cd ../platform

echo "Destroying platform infrastructure..."

terraform destroy -auto-approve

echo "Platform destruction completed."

echo "Infrastructure destroyed successfully."