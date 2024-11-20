#!/bin/bash

# Check if the script received the WordPress version as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <wordpress-version>"
    exit 1
fi

# Assign the argument to the target_version variable
target_version=$1

# Path to the base directory where apps are located
base_dir="/home/master/applications"

# Loop through each directory in the base directory
for app_path in "${base_dir}"/*; do
    if [ -d "${app_path}/public_html" ]; then
        echo "Checking app: ${app_path}/public_html"

        # Check if WordPress is installed by looking for wp-config.php
        if [ -f "${app_path}/public_html/wp-config.php" ]; then
            echo "WordPress detected in ${app_path}/public_html. Checking version..."

            # Get the current WordPress version
            wp_version=$(wp core version --path="${app_path}/public_html" --allow-root)
            if [ $? -ne 0 ]; then
                echo "Failed to retrieve WordPress version for ${app_path}/public_html. Skipping..."
                continue
            fi
            echo "Current WordPress version: ${wp_version}"

            # Downgrade WordPress to the specified version if not already on that version
            if [ "${wp_version}" != "${target_version}" ]; then
                echo "Downgrading WordPress to version ${target_version}..."
                wp core download --force --version=${target_version} --path="${app_path}/public_html" --allow-root
                if [ $? -eq 0 ]; then
                    echo "Downgrade complete for ${app_path}/public_html."
                else
                    echo "Failed to downgrade WordPress for ${app_path}/public_html."
                fi
            else
                echo "WordPress is already on version ${target_version} in ${app_path}/public_html."
            fi
        else
            echo "No WordPress installation detected in ${app_path}/public_html."
        fi

        echo "----------------------------------------"
    else
        echo "No public_html directory found in ${app_path}. Skipping..."
    fi
done
