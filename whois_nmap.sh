#!/bin/bash

# Prompt the user for the input file
read -e -p "Enter the input file path: " input_file

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
