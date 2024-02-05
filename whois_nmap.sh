#!/bin/bash
# Update the package lists for upgrades and new packages
# sudo apt-get update

# Install dnsx
#sudo apt-get install dnsx -y
# Prompt the user for the keywords file
read -e -p "Extern the keywords for the cloud enum: " keywords_file
read -e -p "Extern the domain name file for the DNS burteforce: " domainlist
read -e -p "Extern the wordlist for the dns bruteforce: " dnsbruteforce_wordlist
read -e -p "Extern the dns resolver list: " resolver_list
read -e -p "Enter the target IP file path: " input_file

# Convert the CIDR notation IPs to single IPs
#cat $input_file | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' | xargs -I% sh -c 'echo % | cut -d/ -f1 | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | perl -pe "s/\n/\n/"' > single_ips.txt
#cat $input_file | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' >> single_ips.txt
#sort -u single_ips.txt -o single_ips.txt

# Perform the whois lookup for each IP
whois_output="whois.txt"
while read ip; do
   org=$(timeout 5 whois $ip | grep -i "Customer\|orgname\|netname\|CustName" | awk -F':' '{print $2}' | tr -d '[:space:]') && echo "$ip - $org" >> $whois_output
done < $input_file
mkdir nmap

# Run nmap scan and save greppable output to file
nmap -sT -Pn -T3 --open -vv -iL $input_file -oA nmap/tcp.top --max-rtt-timeout 250ms --max-retries 3 --min-hostgroup=20 ; sudo nmap -sU -Pn -T3 --open -vv -iL $input_file -oA nmap/udp.top --max-rtt-timeout 250ms --max-retries 3 --min-hostgroup=20

cd nmap
mkdir analysis

grep "^Host:" tcp.top.gnmap | while read line; do
    ip=$(echo $line | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    open_ports=$(echo $line | awk -F' ' '{for(i=4;i<=NF;i++)if($i=="Ports:"){for(j=i+1;j<=NF;j++)if($j~/^[0-9]+\/.*/){split($j,a,"/");printf("%s, ",a[1])}}}')
    for port in $(echo $open_ports | tr ',' ' '); do
        # Create file for open port and write IP value
        echo "Creating file for port $port..."
        echo "$ip" >> analysis/tcp_$port.txt
    done
done

grep "^Host:" udp.top.gnmap | while read line; do
    ip=$(echo $line | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    open_ports=$(echo $line | awk -F' ' '{for(i=4;i<=NF;i++)if($i=="Ports:"){for(j=i+1;j<=NF;j++)if($j~/^[0-9]+\/.*/){split($j,a,"/");printf("%s, ",a[1])}}}')
    for port in $(echo $open_ports | tr ',' ' '); do
        # Create file for open port and write IP value
        echo "Creating file for port $port..."
        echo "$ip" >> analysis/udp_$port.txt
    done
done

#!/bin/bash


# Check if the file exists
#if [ ! -f "$keywords_file" ]; then
#    echo "File not found! Please check the path and try again."
#    exit 1
#fi

# Change the permissions of the tool_download.sh file to make it executable
#chmod a+x automation/tool_download.sh

# Create a new directory named 'web'
#mkdir web

# Execute the tool_download.sh script
# ./automation/tool_download.sh

# Install the required Python packages
#pip3 install -r tools/cloud_enum/requirements.txt

# Run the cloud_enum.py script with the specified options
#python3 tools/cloud_enum/cloud_enum.py -kf $keywords_file -l cloudenum_$(date +"%m%d%H%M")

# Run the dnsx command with the user-provided $i input
dnsx -d $domainlist -w $dnsbruteforce_wordlist -r $resolver_list -o dns_brute.txt -stats

# Run the httpx command with the user-provided input
httpx -l dns_brute.txt -sc -td -server -title -ip -fr -random-agent -o httpx.txt -vhost -tls-probe -tls-grab -nf

# discover valid in-scope URLs
grep -Ff $input_file httpx.txt | sort -u | cut -d' ' -f1 >> urls.txt

#run nuclei vulnerability scan
nuclei -l urls.txt -stats -o nuclei_results.txt -rlm 1000

