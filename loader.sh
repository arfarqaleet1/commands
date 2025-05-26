#!/bin/bash

set -e

read -p "Enter ionCube Loader version to install (default 13.0.2): " ioncube_version
ioncube_version=${ioncube_version:-13.0.2}

php_version=$(php -v | awk '/PHP/ {print $2}' | cut -d"." -f1,2 | head -n1)
echo "Detected PHP version: $php_version"
echo "Installing ionCube Loader version: $ioncube_version"

echo "Removing old ionCube ini files and symlinks..."

# Find and remove ionCube ini files
find /etc/php/ -type f -name '*ioncube*.ini' -exec rm -f {} \;

# Find and remove ionCube symlinks in conf.d directories
find /etc/php/ -type l -name '*ioncube*.ini' -exec rm -f {} \;

# Download and extract ionCube loader
mkdir -p /tmp/update_ioncube
cd /tmp/update_ioncube

echo "Downloading ionCube loader $ioncube_version..."
wget -q "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ioncube_version}.tar.gz"
tar -xzf "ioncube_loaders_lin_x86-64_${ioncube_version}.tar.gz"

ext_dir=$(php -i | grep extension_dir | head -n1 | awk '{print $3}')
loader_file="ioncube_loader_lin_${php_version}.so"

if [ ! -f "./ioncube/$loader_file" ]; then
  echo "Error: ionCube loader file $loader_file not found in extracted archive."
  exit 1
fi

echo "Copying loader $loader_file to $ext_dir"
cp "./ioncube/$loader_file" "$ext_dir"

ini_file="/etc/php/$php_version/mods-available/00-ioncube.ini"

# Ensure the directory exists, and create the ini file if missing
if [ ! -d "/etc/php/$php_version/mods-available" ]; then
  echo "Creating directory /etc/php/$php_version/mods-available"
  mkdir -p "/etc/php/$php_version/mods-available"
fi

echo "zend_extension=$ext_dir/$loader_file" > "$ini_file"

# Enable ionCube module manually if phpenmod doesn't work
if [ ! -L "/etc/php/$php_version/cli/conf.d/00-ioncube.ini" ]; then
  echo "Creating symlink for CLI"
  ln -s "$ini_file" "/etc/php/$php_version/cli/conf.d/00-ioncube.ini"
fi

if [ ! -L "/etc/php/$php_version/fpm/conf.d/00-ioncube.ini" ]; then
  echo "Creating symlink for FPM"
  ln -s "$ini_file" "/etc/php/$php_version/fpm/conf.d/00-ioncube.ini"
fi

# Reload services
echo "Reloading nginx and PHP-FPM..."
systemctl reload nginx
systemctl restart php${php_version}-fpm

echo "Cleaning up..."
rm -rf /tmp/update_ioncube

echo "ionCube Loader v$ioncube_version installed for PHP $php_version."

php -v | grep -B 3 -P 'ionCube PHP Loader v\d+\.\d+\.\d+'

exit 0
