#!/bin/bash

# -------- Styles ---------
_note()    { echo -e "\e[34m[NOTE]\e[0m $1"; }
_success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
_error()   { echo -e "\e[31m[ERROR]\e[0m $1"; }

# -------- Root Check ---------
if [ "$EUID" -ne 0 ]; then
  _error "This script uses chown and must be run as root (use sudo)."
  exit 1
fi

# -------- Input --------
read -rp "Enter the application name: " app_name

if [ -z "$app_name" ]; then
    _error "Application name cannot be empty."
    exit 1
fi

# Define path - Using Cloudways standard structure
# Note: $(hostname) is used here as per your function, 
# but usually on Cloudways, the path is /home/master/applications/appname
app_home="/home/$(hostname)/$app_name"

if [ ! -d "$app_home" ]; then
    _error "Directory $app_home does not exist. Please check the app name/path."
    exit 1
fi

_note "Starting setup for $app_name in $app_home..."

# -------- Permissions & Directories ---------

# 1. .bashrc & .bash_aliases
_note "Configuring shell environment files..."
chown "$app_name:www-data" "$app_home/.bashrc"
chmod g+w "$app_home/.bashrc"

touch "$app_home/.bash_aliases"
chown "$app_name:www-data" "$app_home/.bash_aliases"
chmod 664 "$app_home/.bash_aliases"

# 2. Binaries & NPM
_note "Setting up bin and npm directories..."
mkdir -p "$app_home/bin" "$app_home/.npm"
touch "$app_home/.npmrc"
chown -R "$app_name:www-data" "$app_home/bin" "$app_home/.npm" "$app_home/.npmrc"

# 3. PM2 & Config (Crucial for Node apps)
_note "Setting up PM2 and .config paths..."
mkdir -p "$app_home/.pm2/logs" "$app_home/.config"
chown -R "$app_name:www-data" "$app_home/.pm2" "$app_home/.config"

# 4. NVM & Cache
_note "Setting up NVM and cache directories..."
mkdir -p "$app_home/.nvm" "$app_home/.cache"
chown -R "$app_name:www-data" "$app_home/.nvm" "$app_home/.cache"
chmod -R 755 "$app_home/.nvm"
chmod -R 775 "$app_home/.cache"

echo
_success "Setup completed for application: $app_name"
_note "App user $app_name can now manage Node/PM2 processes."
