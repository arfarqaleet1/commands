#!/bin/bash

php_version=$(php -v | awk '/PHP/ {print $2}' | cut -d "." -f 1,2 | head -n 1);

if [ "$php_version" = "8.0" ]; then
    echo "$(tput setaf 1)Error:$(tput setaf 7) IonCube isn't compatible with PHP v8.0 and there is no release for v8.0 yet."
    echo "Exiting..."
    exit 1
fi

mkdir -p /tmp/update_ioncube
cd /tmp/update_ioncube || exit 1

# Download ionCube Loader v13.0.2 tar.gz (specific version)
wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_13.0.2.tar.gz

# Extract
tar -xzf ioncube_loaders_lin_x86-64_13.0.2.tar.gz

ext_dir=$(php -i | grep extension_dir | head -n 1 | awk '{print $3}')

# Prepare ini filename and path
ini_dir="/etc/php/$php_version/cli/conf.d"
ini_file=$(ls "$ini_dir" | grep ioncube || echo "05-ioncube.ini")

# Copy correct ioncube loader for your PHP version
cp "ioncube/ioncube_loader_lin_${php_version}.so" "$ext_dir"

# Make sure ioncube.ini loads ionCube loader as zend_extension with full path
echo "zend_extension=$ext_dir/ioncube_loader_lin_${php_version}.so" | sudo tee "$ini_dir/$ini_file" > /dev/null

# Rename ini file to ensure it loads first
sudo mv "$ini_dir/$ini_file" "/etc/php/$php_version/mods-available/00-ioncube.ini"

# Enable ioncube module (recreate symlinks for cli and fpm)
sudo phpdismod -v "$php_version" ioncube
sudo phpenmod -v "$php_version" ioncube

# Restart PHP-FPM and nginx (adjust if using apache)
sudo systemctl reload nginx
sudo systemctl reload php"${php_version}"-fpm

# Verify installation
php -v | grep -B 3 -P 'ionCube PHP Loader v\d+\.\d+\.\d+'

# Clean up
rm -rf /tmp/update_ioncube

exit 0
