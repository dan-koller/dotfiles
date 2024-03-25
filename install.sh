#!/bin/zsh

###########################
# This script sets up my Mac 
# with all my favorite apps
# and tools and creates symlinks.
###########################

###########################
# Misc settings
###########################

# Color codes for output
RED="\e[31m" # Errors
YELLOW="\e[33m" # Warnings
GREEN="\e[32m" # Success
ENDCOLOR="\e[0m" # Reset

###########################
# Preinstall
###########################

# Check if commandline args are given
if [ $# -eq 0 ]; then
    echo -e "${RED}Please specifiy the Hostname './install.sh <hostname> <gitname> <gitemail>' and run the script again.${ENDCOLOR}"
    exit 1
fi

# Cli args
HOSTNAME=$1
GITNAME=$2
GITMAIL=$3

# Change hostname
echo -e "${YELLOW}Changing hostname to $1${ENDCOLOR}"
sudo scutil --set HostName $1

###########################
# Preinstall
###########################

# User home directory
HOMEDIR="$HOME"

# Directory for dotfiles
DOTFILESDIR="$HOMEDIR/.dotfiles"

# Directory for config files
CONFIGDIR="$DOTFILESDIR/configs"

###########################
# Package manager setup
###########################

# Get system architecture
CPU_ARCH=$(uname -m)

# Install rosetta for arm macs
if [ "$CPU_ARCH" = "arm64" ]; then
    echo -e "${YELLOW}Apple Silicon Mac detected. Installing Rosetta.${ENDCOLOR}"
    sudo softwareupdate --install-rosetta --agree-to-license
fi

# Create a local .zprofile for custom env variables
touch ${CONFIGDIR}/.zprofile

# Additional Homebrew settings for arm macs
if [ "$CPU_ARCH" = "arm64" ]; then
    echo "${YELLOW}Adding additional Homebrew settings...${ENDCOLOR}"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${homedir}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###########################
# Configuration
###########################

# Create necessary directories
echo "${YELLOW}🗂 Creating necessary directories...${ENDCOLOR}"
mkdir -p ~/Projekte
echo "${GREEN}...done!${ENDCOLOR}"

# Change into configuration subdir
echo "Changing into ${CONFIGDIR} subdirectory..."
cd $CONFIGDIR

# List all config files here
files=(.gitconfig .tmux.conf .vimrc .zprofile .zshrc)

# Create symlinks (will replace old links) for config files
for file in $files; do
    echo "${YELLOW}🔗 Creating symlink to $file in $homedir${ENDCOLOR}"
    ln -sf ${CONFIGDIR}/${file} ${HOMEDIR}/${file}
done

# Change into .dotfiles directory
echo "Changing into ${DOTFILESDIR} directory..."
cd $DOTFILESDIR

# Setup git if gitname and gitmail are given
if [ -n "$GITNAME" ] && [ -n "$GITMAIL" ]; then
    echo "${YELLOW}🔧 Setting up git...${ENDCOLOR}"
    git config --global user.name "$GITNAME"
    git config --global user.email "$GITMAIL"
    echo "${GREEN}...done!${ENDCOLOR}"
fi

###########################
# Package installation
###########################

# Run the Homebrew script and install packages
echo "${YELLOW}🍺 Installing packages...${ENDCOLOR}"
./brew.sh
echo "${GREEN}...done!${ENDCOLOR}"

###########################
# Post installation
###########################

# Install vim plugin manager
echo "${YELLOW}Installing vim plugin manager...${ENDCOLOR}"
# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "\n--------------------------"
echo "${YELLOW}On first start of vim run:${ENDCOLOR}\n:PlugInstall"
echo "--------------------------\n"

# Finish
echo "${GREEN}Installation finished!${ENDCOLOR}"
