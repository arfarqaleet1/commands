#!/bin/bash

echo "Please get API details from the client's Dashboard first"

read -p "Please enter client's Email: " email
read -p "Please enter client's API key: " api_key
read -p "Please enter SSL email: " ssl_email

# Authenticate
get_token=$(curl --silent -X POST \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --header 'Accept: application/json' \
  -d "email=$email&api_key=$api_key" \
  'https://api.cloudways.com/api/v1/oauth/access_token')

token_value=$(echo "$get_token" | sed -n 's|.*"access_token":"\([^"]*\)".*|\1|p')

if [[ -z $token_value ]]; then
    echo "❗ Authorization failed. Please check your email and API key."
    exit 1
fi

echo "✅ Authorization successful."

declare -A server_apps

while true; do
    read -rp "Enter server_id (or type ':done' to finish): " server_id
    if [[ "$server_id" == ":done" ]]; then
        break
    fi

    apps=()
    echo "Enter app_ids for server_id=$server_id one by one. Type 'done' when finished."

    while true; do
        read -rp "app_id> " app_id
        if [[ "$app_id" == "done" ]]; then
            break
        fi

        if [[ -n "$app_id" ]]; then
            apps+=("$app_id")
        else
            echo "❗ Please enter a valid app_id."
        fi
    done

    if [[ ${#apps[@]} -gt 0 ]]; then
        server_apps["$server_id"]="${apps[*]}"
    else
        echo "❗ No app_ids entered for server_id=$server_id, skipping."
    fi
done

echo "🔧 Running SSL renew API calls..."

for server_id in "${!server_apps[@]}"; do
    IFS=' ' read -r -a app_ids <<< "${server_apps[$server_id]}"
    for app_id in "${app_ids[@]}"; do
        echo "➡ Renewing SSL for server_id=$server_id, app_id=$app_id"

        response=$(curl -s -X POST \
            --header "Authorization: Bearer $token_value" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --header 'Accept: application/json' \
            -d "server_id=$server_id&app_id=$app_id&ssl_email=$ssl_email&wild_card=false&domain=bbibox.com" \
            'https://api.cloudways.com/api/v1/security/lets_encrypt_manual_renew')

        echo "Response: $response"
    done
done

echo "✅ All done!"
