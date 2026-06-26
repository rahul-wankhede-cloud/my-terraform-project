#!/bin/bash
cd platform
terraform apply -auto-approve

cd ../data
terraform apply -auto-approve