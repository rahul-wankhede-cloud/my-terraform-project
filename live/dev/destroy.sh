#!/bin/bash
cd data
terraform destroy -auto-approve

cd ../platform
terraform destroy -auto-approve