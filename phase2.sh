#!/bin/bash

# Update the package lists for upgrades and new packages
sudo apt-get update

# Install dnsx
sudo apt-get install dnsx -y
# Prompt the user for the keywords file
read -e -p "Extern the keywords for the cloud enum: " keywords_file
read -e -p "Extern the domain name file for the burteforce: " domainlist
read -e -p "Extern the wordlist for the dns bruteforce: " dnsbruteforce_wordlist
read -e -p "Extern the dns resolver list: " resolver_list
# Check if the file exists
if [ ! -f "$keywords_file" ]; then
    echo "File not found! Please check the path and try again."
    exit 1
fi

# Change the permissions of the tool_download.sh file to make it executable
#chmod a+x automation/tool_download.sh

# Create a new directory named 'web'
#mkdir web

# Execute the tool_download.sh script
# ./automation/tool_download.sh

# Install the required Python packages
#pip3 install -r tools/cloud_enum/requirements.txt

# Run the cloud_enum.py script with the specified options
python3 tools/cloud_enum/cloud_enum.py -kf $keywords_file -l cloudenum_$(date +"%m%d%H%M")

# Run the dnsx command with the user-provided $i input
dnsx -d $domainlist -w $dnsbruteforce_wordlist -r $resolver_list -o dns_brute_$(date +"%m%d%H%M") -stats

