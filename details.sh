#!/bin/bash

echo "Please get API details from client's Dashboard first"
read -p "Please enter client's Email: " email <&1
read -p "Please enter client's API key: " api_key <&1

JQ="/usr/bin/jq"
OUTPUT_FILE="cloudways_apps_table.txt"

if [[ -x $JQ ]]; then
    get_token=$(curl --silent -X POST \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --header 'Accept: application/json' \
        -d "email=${email}&api_key=${api_key}" \
        'https://api.cloudways.com/api/v1/oauth/access_token' | jq -r '.access_token')

    temp_json="/tmp/${api_key}.json"
    curl -s -X GET -H "Authorization: Bearer ${get_token}" \
        'https://api.cloudways.com/api/v1/server' > "$temp_json"

    echo "Below is a table of servers and apps for client: $email"
    echo ""

    {
        printf "%-17s | %-15s | %-8s | %-10s | %-22s | %-45s | %-20s | %-10s\n" "Server IP" "Server Name" "App ID" "Sys User" "App Name" "App FQDN" "CNAME" "Type"
        printf -- "------------------|-----------------|----------|------------|------------------------|-----------------------------------------------|----------------------|-----------\n"
    } | tee "$OUTPUT_FILE"

    last_ip=""

    jq -c '.servers[]' "$temp_json" | while read -r server; do
        server_ip=$(echo "$server" | jq -r '.public_ip')
        server_name=$(echo "$server" | jq -r '.label')

        if [[ "$server_ip" != "$last_ip" && -n "$last_ip" ]]; then
            echo "" | tee -a "$OUTPUT_FILE"
        fi
        last_ip="$server_ip"

        echo "$server" | jq -c '.apps[]' | while read -r app; do
            app_id=$(echo "$app" | jq -r '.id')
            sys_user=$(echo "$app" | jq -r '.sys_user')
            app_label=$(echo "$app" | jq -r '.label')
            app_fqdn=$(echo "$app" | jq -r '.app_fqdn')
            cname=$(echo "$app" | jq -r '.cname')
            app_type=$(echo "$app" | jq -r '.application')

            printf "%-17s | %-15s | %-8s | %-10s | %-22s | %-45s | %-20s | %-10s\n" \
                "$server_ip" "$server_name" "$app_id" "$sys_user" "$app_label" "$app_fqdn" "$cname" "$app_type" | tee -a "$OUTPUT_FILE"
        done
    done

    echo ""
    echo "📄 Table also saved to: $OUTPUT_FILE"
    rm "$temp_json"
else
    echo -n $'\U274E '
    echo "jq seems to be missing. Please install it with $(tput bold)$(tput setaf 1)sudo apt install jq$(tput sgr0)"
    echo ""
fi
