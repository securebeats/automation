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
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Download httpx
echo "Downloading httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Download Cloud_enum
echo "Downloading Cloud_enum..."
git clone https://github.com/initstring/cloud_enum.git tools/cloud_enum
