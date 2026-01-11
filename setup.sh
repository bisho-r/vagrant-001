#!/bin/bash
echo "Updating system packages..."
sudo apt-get update -y 

echo "Installing Nginx..."
sudo apt-get install -y nginx

echo "Installing MySQL..."
sudo apt-get install -y mysql-server

sudo apt-get install -y python3-pip



echo "Setup completed! Visit http://localhost:8080"
