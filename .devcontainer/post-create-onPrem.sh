#!/bin/bash
#loading functions to script
export SECONDS=0
source .devcontainer/util/source_framework.sh

setUpTerminal

transformToAppsUrl $DT_TENANT

installMkdocs

### Custom stuff

### 1. Install Dynatrace OneAgent ###
echo "Installing Dynatrace OneAgent..."

# Download OneAgent installer
wget "${DT_TENANT}/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=${DT_OPERATOR_TOKEN}" -O Dynatrace-OneAgent.sh

# Make it executable and run
chmod +x Dynatrace-OneAgent.sh
sudo ./Dynatrace-OneAgent.sh HOST_GROUP=onPrem_easytravel_prod

echo "Dynatrace OneAgent installed."

### 2. Deploy EasyTravel ###
echo "Deploying EasyTravel..."

# Clone EasyTravel repo
git clone https://github.com/Dynatrace/easyTravel-Docker.git
cd easyTravel-Docker

# Start EasyTravel using Docker Compose
docker-compose up -d

echo "EasyTravel is now running."

###

finalizePostCreation

printInfoSection "Your dev container finished creating"
