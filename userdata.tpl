#!/bin/bash
sudo apt update -y &&
sudo apt install -y nginx
echo "Terraform-demo instance is up " > /var/www/html/index.html