#!/bin/bash

# Initialize an array to store bot names
declare -a bot_names=()

while true; do
    read -p "Enter the bot name to block (or type 'done' to finish): " bot_name
    if [[ "$bot_name" == "done" ]]; then
        break
    elif [[ -z "$bot_name" ]]; then
        echo "No bot name entered. Please enter a valid bot name."
    else
        bot_names+=("$bot_name")
    fi
done

if [[ ${#bot_names[@]} -eq 0 ]]; then
    echo "No bot names entered. Exiting."
    exit 1
fi

config_file="/etc/nginx/additional_server_conf"

# Read existing bot names from the config file
existing_bots=$(grep -oP '(?<=~\* ").*(?=")' "$config_file" | tr '|' '\n')

# Combine existing bots with new bots
combined_bots=("${bot_names[@]}")
for bot in $existing_bots; do
    combined_bots+=("$bot")
done

# Remove duplicates
combined_bots=($(echo "${combined_bots[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Generate the block code
block_code="if (\$http_user_agent ~* \""
for bot in "${combined_bots[@]}"; do
    block_code+="$bot|"
done
block_code="${block_code%|}\") {\n    return 403;\n}"

# Write the updated block code to the config file
echo -e "$block_code" > "$config_file"
echo "Bots ${combined_bots[*]} have been blocked and the configuration has been updated."
echo ""
nginx -t
systemctl reload nginx
echo "NGINX HAS BEEN RESTARTED"
echo ""
