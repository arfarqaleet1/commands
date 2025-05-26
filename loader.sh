#!/bin/bash

set -e

php_version=$(php -v | awk '/PHP/ {print $2}' | cut -d '.' -f1,2 | head -n1)

if [ "$php_version" = "8.0" ]; then
    echo -e "\e[31mError:\e[0m IonCube isn't compatible with PHP v8.0 and there is no release for v8.0 yet."
    echo "Exiting..."
    exit 1
fi

TMP_DIR="/tmp/update_ioncube"
IONCUBE_VER="13.0.2"

echo "Installing ionCube Loader v$IONCUBE_VER for PHP $php_version"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Download specific ionCube loader version
wget -q "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${IONCUBE_VER}.tar.gz"

tar -xzf "ioncube_loaders_lin_x86-64_${IONCUBE_VER}.tar.gz"

# Get PHP extension dir
EXT_DIR=$(php -i | grep extension_dir | head -n1 | awk '{print $3}')

# Copy loader for current PHP version
cp "ioncube/ioncube_loader_lin_${php_version}.so" "$EXT_DIR"

# Prepare ini file path
MODS_AVAILABLE_DIR="/etc/php/$php_version/mods-available"
CLI_CONF_DIR="/etc/php/$php_version/cli/conf.d"
FPM_CONF_DIR="/etc/php/$php_version/fpm/conf.d"

sudo mkdir -p "$MODS_AVAILABLE_DIR"

# Write ini file with full path, ensure ionCube loads first by naming 00-ioncube.ini
echo "zend_extension=$EXT_DIR/ioncube_loader_lin_${php_version}.so" | sudo tee "$MODS_AVAILABLE_DIR/00-ioncube.ini" > /dev/null

# Disable and enable ioncube module to recreate symlinks correctly
sudo phpdismod -v "$php_version" ioncube || true
sudo phpenmod -v "$php_version" ioncube

# Restart PHP-FPM and web server (adjust if not nginx)
sudo systemctl restart php"$php_version"-fpm
sudo systemctl reload nginx

# Verify ionCube loader is loaded
php -v | grep -B 3 -P 'ionCube PHP Loader v\d+\.\d+\.\d+'

# Cleanup
rm -rf "$TMP_DIR"

echo "ionCube Loader v$IONCUBE_VER installation completed for PHP $php_version."
