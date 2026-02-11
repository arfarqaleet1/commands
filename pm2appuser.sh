#!/bin/bash

# -------- Styles ---------
_note()    { echo -e "\e[34m[NOTE]\e[0m $1"; }
_success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
_error()   { echo -e "\e[31m[ERROR]\e[0m $1"; }

# -------- Input --------
read -rp "Enter the app user (e.g., kmdakfewge): " app_user

if [ -z "$app_user" ]; then
    _error "App user cannot be empty. Exiting."
    exit 1
fi

# Define paths
# Using $(hostname) as per your requirement
host_name=$(hostname)
app_home="/home/$host_name/$app_user"
npm_bin_path="$app_home/bin/npm"
npm_lib_path="$npm_bin_path/lib/node_modules"

# Check if directory exists
if [ ! -d "$app_home" ]; then
    _error "Directory $app_home not found. Please run the nodeappuser script first."
    exit 1
fi

_note "Configuring environment for user: $app_user"

# -------- Writing to .bash_aliases ---------
# We use '>>' to append. If you want to prevent duplicates, we can add a check.
_note "Updating .bash_aliases..."
echo "export PATH=\"\$PATH:$npm_bin_path\"" >> "$app_home/.bash_aliases"
echo "export NODE_PATH=\"\$NODE_PATH:$npm_lib_path\"" >> "$app_home/.bash_aliases"
echo "alias pm2='$npm_lib_path/bin/pm2'" >> "$app_home/.bash_aliases"

# -------- Writing to .bashrc ---------
_note "Sourcing .bash_aliases in .bashrc..."
# Ensure the line isn't already there
if ! grep -q "source ~/.bash_aliases" "$app_home/.bashrc"; then
    echo "source ~/.bash_aliases" >> "$app_home/.bashrc"
fi

# -------- NPM Config ---------
_note "Setting NPM global prefix..."
# We must run this as the app user or ensure permissions are correct
sudo -u "$app_user" npm config set prefix "$npm_lib_path"

# -------- Installing PM2 ---------
_note "Installing PM2 globally for $app_user..."
sudo -u "$app_user" npm install pm2@latest -g

_success "Environment setup complete for $app_user."
_note "Please ask the user to run 'source ~/.bashrc' or log in again to see changes."
