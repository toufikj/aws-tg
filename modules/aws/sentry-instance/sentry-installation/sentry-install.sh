#!/bin/bash

# Install Dependencies for Docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y && sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Run Docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER

# Reboot the instance to apply group changes
echo "Rebooting the system to apply changes..."
sudo reboot

# Install Sentry
# Clone the Sentry repository
git clone https://github.com/getsentry/onpremise.git

# Run installation script
cd onpremise/
./install.sh --no-user-prompt
docker-compose up
