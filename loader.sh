#!/bin/bash

set -e

php_version=$(php -v | awk '/PHP/ {print $2}' | cut -d '.' -f1,2 | head -n1)

if [ "$php_version" = "8.0" ]; then
    echo -e "\e[31mError:\e[0m IonCube isn't compatible with PHP v8.0 yet."
    exit 1
fi

TMP_DIR="/tmp/update_ioncube"
IONCUBE_VER="13.0.2"
ARCH="x86-64"  # adjust if needed

echo "Installing ionCube Loader v$IONCUBE_VER for PHP $php_version"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Download and extract ionCube loaders
wget -q "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCH}_${IONCUBE_VER}.tar.gz"
tar -xzf "ioncube_loaders_lin_${ARCH}_${IONCUBE_VER}.tar.gz"

# Detect PHP extension dir (use cli php here)
EXT_DIR=$(php -i | grep extension_dir | head -n1 | awk '{print $3}')
echo "Detected extension_dir: $EXT_DIR"

# Copy ionCube loader .so for your PHP version
LOADER_SO="ioncube_loader_lin_${php_version}.so"
if [ ! -f "ioncube/$LOADER_SO" ]; then
    echo "ERROR: Loader $LOADER_SO not found in extracted files"
    exit 1
fi
sudo cp "ioncube/$LOADER_SO" "$EXT_DIR"

# Setup ini for mods-available (full path, load first)
MODS_AVAILABLE_DIR="/etc/php/$php_version/mods-available"
sudo mkdir -p "$MODS_AVAILABLE_DIR"
INI_FILE="$MODS_AVAILABLE_DIR/00-ioncube.ini"

echo "zend_extension=$EXT_DIR/$LOADER_SO" | sudo tee "$INI_FILE" > /dev/null

# Remove any old ioncube ini symlinks to avoid duplicates
sudo find /etc/php/$php_version/cli/conf.d -name '*ioncube*.ini' -exec rm -f {} +
sudo find /etc/php/$php_version/fpm/conf.d -name '*ioncube*.ini' -exec rm -f {} +

# Create symlinks in cli and fpm conf.d to mods-available/00-ioncube.ini
sudo ln -s "$INI_FILE" "/etc/php/$php_version/cli/conf.d/00-ioncube.ini"
sudo ln -s "$INI_FILE" "/etc/php/$php_version/fpm/conf.d/00-ioncube.ini"

# Restart PHP-FPM and reload webserver
sudo systemctl restart php"$php_version"-fpm
sudo systemctl reload nginx

# Verify ionCube is loaded in CLI
echo "Verifying ionCube loader in CLI:"
php -v | grep -A 5 ionCube

# Cleanup
rm -rf "$TMP_DIR"

echo "ionCube Loader v$IONCUBE_VER installation complete for PHP $php_version."
