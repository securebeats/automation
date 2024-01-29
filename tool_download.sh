#!/bin/bash

# Create tools directory if it doesn't exist
if [ ! -d "tools" ]; then
    mkdir tools
    cd tools
fi

# Download CredMaster
echo "Downloading CredMaster..."
git clone https://github.com/knavesec/CredMaster.git

# Download Nuclei
echo "Downloading Nuclei..."
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Download httpx
echo "Downloading httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Download Cloud_enum
echo "Downloading Cloud_enum..."
git clone https://github.com/initstring/cloud_enum.git

# Download subfinder
echo "Downloading subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Download linkedinenum
echo "Downloading linkedin enum..."
git clone https://github.com/initstring/linkedin2username.git
