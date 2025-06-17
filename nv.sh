#!/bin/bash

# -------- Functions ---------

_note()    { echo -e "\e[34m[NOTE]\e[0m $1"; }
_success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
_error()   { echo -e "\e[31m[ERROR]\e[0m $1"; }

# -------- Prompt for Version --------

read -rp "Enter the Node.js version you want to install (e.g., 22.16.0): " NODE_VER

if [[ -z "$NODE_VER" ]]; then
    _error "No version entered. Exiting."
    exit 1
fi

NODE_URL="https://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
NODE_DIR="/var/cw/systeam/node-v$NODE_VER-linux-x64"
NODE_BIN="$NODE_DIR/bin/node"
NPM_BIN="$NODE_DIR/lib/node_modules/npm/bin/npm-cli.js"
NPX_BIN="$NODE_DIR/lib/node_modules/npm/bin/npx-cli.js"

# -------- Check if URL exists --------

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$NODE_URL")
if [ "$STATUS_CODE" != "200" ]; then
    _error "Node.js version $NODE_VER not found at $NODE_URL"
    exit 1
fi

# -------- Install Node --------

_note "Installing Node v$NODE_VER"
mkdir -p /var/cw/systeam
cd /var/cw/systeam || exit 1

curl -sL "$NODE_URL" | tar -xzf -

# Backup old node binary if it exists
[[ -x /usr/bin/node ]] && mv /usr/bin/node /usr/bin/node.bak

cp "$NODE_BIN" /usr/bin/
chmod +x /usr/bin/node
_success "Node v$NODE_VER installed"

# -------- Link npm and npx --------

_note "Updating npm"
rm -f /usr/bin/npm
ln -s "$NPM_BIN" /usr/bin/npm
_success "npm updated successfully"

_note "Updating npx"
rm -f /usr/bin/npx
ln -s "$NPX_BIN" /usr/bin/npx
_success "npx updated successfully"

# -------- Show versions --------

echo
echo "✅ Versions:"
node -v
npm -v
npx --version
