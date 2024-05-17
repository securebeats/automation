#!/bin/bash

# Check if sslscan is installed
if ! command -v sslscan &> /dev/null; then
    echo "sslscan is not installed. Please install it first."
    exit 1
fi

# Check if the input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Check if the output file exists and delete it
output_file="weak_TLS.txt"
weak_ciphers_file="weak_ciphers.txt"
if [ -f "$output_file" ]; then
    rm "$output_file"
fi
if [ -f "$weak_ciphers_file" ]; then
    rm "$weak_ciphers_file"
fi

# Run sslscan on each URL in parallel and analyze the output
while IFS= read -r url; do
    echo "Analyzing $url"

    # Run sslscan in parallel and capture the output
    sslscan_output=$(sslscan "$url" 2>/dev/null)  # Suppress error output

    # Check if TLS version is less than 1.2
    if [[ "$sslscan_output" =~ (TLSv1\.1|TLSv1\.0|SSL)[[:space:]]+.*enabled ]]; then
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
