#!/bin/bash

# Create tools directory if it doesn't exist
if [ ! -d "tools" ]; then
    mkdir tools
    cd tools
fi

# Download CredMaster
echo "Downloading CredMaster..."
git clone https://github.com/knavesec/CredMaster.git tools/CredMaster

# Download Nuclei
echo "Downloading Nuclei..."
wget https://github.com/projectdiscovery/nuclei/releases/download/v2.9.2/nuclei_2.9.2_linux_amd64.zip && unzip nuclei_2.9.2_linux_amd64.zip && rm nuclei_2.9.2_linux_amd64.zip

# Download httpx
echo "Downloading httpx..."
wget https://github.com/projectdiscovery/httpx/releases/download/v1.2.9/httpx_1.2.9_linux_amd64.zip && unzip httpx_1.2.9_linux_amd64.zip && rm httpx_1.2.9_linux_amd64.zip

# Download Cloud_enum
echo "Downloading Cloud_enum..."
git clone https://github.com/initstring/cloud_enum.git tools/cloud_enum
