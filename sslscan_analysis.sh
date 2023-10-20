#!/bin/bash

# Check if the output file exists and delete it
output_file="weak_TLS.txt"
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Check if the weak ciphers file exists and delete it
weak_ciphers_file="weak_ciphers.txt"
if [ -f "$weak_ciphers_file" ]; then
    rm "$weak_ciphers_file"
fi

# Run sslscan on each URL and analyze the output
while IFS= read -r url; do
    echo "Analyzing $url"

    # Run sslscan and capture the output
    sslscan_output=$(sslscan "$url")

    # Check if TLS version is less than 1.2
    # Check if TLS version is less than 1.2
    if [[ "$sslscan_output" =~ (TLSv1\.0|TLSv1\.1|SSLv[23]) ]]; then
    echo "$url" >> "$output_file"
    fi

    # Check for weak ciphers
    weak_cipher_pattern="Accepted[[:space:]]+.*(NULL|EXP|DES|RC4-MD5)"
    if [[ "$sslscan_output" =~ $weak_cipher_pattern ]]; then
        echo "$url" >> "$weak_ciphers_file"
    fi

    echo "Analysis complete for $url"
    echo "------------------------"
done < "$1"

echo "Analysis complete. Results saved in $output_file and $weak_ciphers_file."
