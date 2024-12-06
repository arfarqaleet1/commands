#!/bin/bash

echo "Please get API details from the client's Dashboard first"

read -p "Please enter client's Email: " email <&1
read -p "Please enter client's API key: " api_key <&1
read -p "Please enter Server ID: " server_id <&1

get_token=$(curl --silent -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' -d "email=$email&api_key=$api_key" 'https://api.cloudways.com/api/v1/oauth/access_token')

token_value=$(echo "$get_token" | sed -n 's|.*"access_token":"\([^"]*\)".*|\1|p')

if [[ -z $token_value ]]; then
    echo "Authorization failed. Please check your email and API key."
    exit 1
fi

echo "Authorization successful. Access token obtained."

while true; do
    read -p "Please enter App ID (or type 'done' to finish): " app_id <&1
    if [[ "$app_id" == "done" ]]; then
        break
    fi
    response=$(curl -s -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header "Authorization: Bearer $token_value" -d "server_id=$server_id&app_id=$app_id&status=enable" "https://api.cloudways.com/api/v1/app/manage/cron_setting")

    echo "Response for App ID $app_id: $response"
    echo ""

    status=$(echo "$response" | grep -o '"status":[^,]*' | grep -o '[^:]*$')

    if [[ $status == true ]]; then
        echo "Cron setting enabled for App ID: $app_id"
        echo ""
    else
        echo "Failed to enable cron setting for App ID: $app_id. Response: $response"
    fi
done
