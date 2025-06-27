#!/bin/bash

# -------- Functions ---------

_note()    { echo -e "\e[34m[NOTE]\e[0m $1"; }
_success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
_error()   { echo -e "\e[31m[ERROR]\e[0m $1"; }
_warn()    { echo -e "\e[33m[WARNING]\e[0m $1"; }

# -------- Check for curl and git --------

_note "Checking for required tools (curl, git)..."
if ! command -v curl &> /dev/null; then
    _error "curl is not installed. Please install it (e.g., sudo apt install curl or sudo yum install curl) and try again."
    exit 1
fi
if ! command -v git &> /dev/null; then
    _error "git is not installed. Please install it (e.g., sudo apt install git or sudo yum install git) and try again."
    exit 1
fi
_success "Required tools are present."

# -------- Install NVM --------

NVM_DIR="$HOME/.nvm"
NVM_INSTALL_SCRIPT="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh" # Using a specific version for stability

_note "Checking if NVM is already installed..."
if [ -d "$NVM_DIR" ]; then
    _warn "NVM already appears to be installed at $NVM_DIR. Skipping NVM installation."
    # Source NVM to make it available
    export NVM_DIR="$NVM_DIR"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
else
    _note "Installing NVM from $NVM_INSTALL_SCRIPT..."
    curl -o- "$NVM_INSTALL_SCRIPT" | bash

    # Source NVM to make it available in the current shell session
    export NVM_DIR="$NVM_DIR"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    if command -v nvm &> /dev/null; then
        _success "NVM installed successfully."
    else
        _error "NVM installation failed. Please check the output above."
        exit 1
    fi
fi

# -------- Prompt for Node.js Version --------

read -rp "Enter the Node.js version you want to install (e.g., 22.16.0): " NODE_VER

if [[ -z "$NODE_VER" ]]; then
    _error "No version entered. Exiting."
    exit 1
fi

# -------- Install Node.js using NVM --------

_note "Installing Node.js v$NODE_VER using NVM..."
if nvm install "$NODE_VER"; then
    _success "Node.js v$NODE_VER installed successfully using NVM."
else
    _error "Failed to install Node.js v$NODE_VER using NVM. Please check the version and try again."
    exit 1
fi

# Set the newly installed version as default
_note "Setting Node.js v$NODE_VER as the default version..."
if nvm alias default "$NODE_VER"; then
    _success "Node.js v$NODE_VER set as default."
else
    _warn "Could not set Node.js v$NODE_VER as default. You may need to do this manually with 'nvm alias default $NODE_VER'."
fi

# -------- Show versions --------

echo
echo "✅ Versions:"
node -v
npm -v
npx --version

_note "To use NVM in new shell sessions, you might need to restart your terminal or manually source your shell's rc file (e.g., source ~/.bashrc or source ~/.zshrc)."
