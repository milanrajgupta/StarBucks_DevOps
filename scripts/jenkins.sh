#!/bin/bash

set -e

echo "======================================="
echo " Installing Jenkins on Ubuntu"
echo "======================================="

# Update packages
sudo apt update -y

# Install dependencies
sudo apt install -y curl wget gnupg fontconfig openjdk-21-jdk

echo "Java Version:"
java -version

# Remove old Jenkins repo & key
sudo rm -f /usr/share/keyrings/jenkins-keyring.asc
sudo rm -f /etc/apt/sources.list.d/jenkins.list

# Download latest Jenkins key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

# Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

# Update package index
sudo apt update -y

# Install Jenkins
sudo apt install -y jenkins

# Enable & Start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo
echo "======================================="
echo " Jenkins Service Status"
echo "======================================="
sudo systemctl --no-pager status jenkins

echo
echo "======================================="
echo " Initial Admin Password"
echo "======================================="

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo
echo "======================================="
echo " Access Jenkins"
echo "======================================="
echo "http://<EC2-PUBLIC-IP>:8080"
