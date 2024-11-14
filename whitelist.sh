#!/bin/bash

echo "Please get API details from the client's Dashboard first"

read -p "Please enter client's Email: " email <&1
read -p "Please enter client's API key: " api_key <&1
read -p "Please enter IP to whitelist: " whitelist_ip <&1
read -p "Please enter Server ID: " server_id <&1

get_token=$(curl --silent -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' -d "email=$email&api_key=$api_key" 'https://api.cloudways.com/api/v1/oauth/access_token')

token_value=$(echo "$get_token" | sed -n 's|.*"access_token":"\([^"]*\)".*|\1|p')

if [[ -z $token_value ]]; then
    echo "Authorization failed. Please check your email and API key."
    exit 1
fi

# Whitelist IP in Adminer
response=$(curl -s -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Accept: application/json" --header "Authorization: Bearer $token_value" -d "server_id=$server_id&whitelist_ip=1" "https://api.cloudways.com/api/v1/security/adminer?ip=$whitelist_ip")

echo "Response from server: $response"

status=$(echo "$response" | grep -o '"status":[^,]*' | grep -o '[^:]*$')

if [[ $status == true ]]; then
    echo "IP $whitelist_ip has been whitelisted in Adminer for server ID: $server_id"
else
    echo "Failed to whitelist IP. Response: $response"
fi
