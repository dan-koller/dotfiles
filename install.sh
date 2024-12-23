#!/bin/zsh

#####################################################################################################
# This script sets up my Mac with all my favorite apps and tools and creates symlinks.              #
#####################################################################################################

#####################################################################################################
# Miscellanous                                                                                      #
#####################################################################################################

# Color codes for output
RED="\e[31m"        # Errors
YELLOW="\e[33m"     # Warnings
GREEN="\e[32m"      # Success
ENDCOLOR="\e[0m"    # Reset

#####################################################################################################
# Parse command line arguments                                                                      #
#####################################################################################################

HOSTNAME=""
GITNAME=""
GITMAIL=""
SHOW_HELP=false

function show_help() {
    echo -e "${YELLOW}Usage: ./install.sh [OPTIONS]${ENDCOLOR}"
    echo -e "\nOptions:"
    echo -e "  -h, --hostname <hostname>   Set the hostname of the system."
    echo -e "  -gn, --gitname <gitname>    Set the Git user name."
    echo -e "  -ge, --gitemail <gitemail>  Set the Git user email."
    echo -e "  --help                      Show this help message and exit."
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--hostname)
            HOSTNAME=$2
            shift 2
            ;;
        -gn|--gitname)
            GITNAME=$2
            shift 2
            ;;
        -ge|--gitemail)
            GITMAIL=$2
            shift 2
            ;;
        --help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Invalid option: $1${ENDCOLOR}" >&2
            show_help
            exit 1
            ;;
    esac
done

if $SHOW_HELP; then
    show_help
    exit 0
fi

#####################################################################################################
# Preinstallation                                                                                   #
#####################################################################################################

if [ -n "$HOSTNAME" ]; then
    echo -e "${YELLOW}Changing hostname to $HOSTNAME${ENDCOLOR}"
    sudo scutil --set HostName "$HOSTNAME"
fi

#####################################################################################################
# Directories                                                                                       #
#####################################################################################################

HOMEDIR="$HOME"
DOTFILESDIR="$HOMEDIR/.dotfiles"
CONFIGDIR="$DOTFILESDIR/configs"

#####################################################################################################
# Package manager setup                                                                             #
#####################################################################################################

# Get system architecture
CPU_ARCH=$(uname -m)

# Install Rosetta for ARM Macs
if [ "$CPU_ARCH" = "arm64" ]; then
    echo -e "${YELLOW}Apple Silicon Mac detected. Installing Rosetta.${ENDCOLOR}"
    sudo softwareupdate --install-rosetta --agree-to-license
fi

# Create a local .zprofile for custom env variables
touch "${CONFIGDIR}/.zprofile"

# Additional Homebrew settings for ARM Macs
if [ "$CPU_ARCH" = "arm64" ]; then
    echo "${YELLOW}Adding additional Homebrew settings...${ENDCOLOR}"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOMEDIR}/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#####################################################################################################
# Configuration                                                                                     #
#####################################################################################################

# Create necessary directories
echo "${YELLOW}🗂 Creating necessary directories...${ENDCOLOR}"
mkdir -p ~/Projekte
echo "${GREEN}...done!${ENDCOLOR}"

# Change into configuration subdir to correctly create symlinks
echo "Changing into ${CONFIGDIR} subdirectory..."
cd "$CONFIGDIR" || exit

# Create symlinks (will replace old links) for config files
files=(.gitconfig .vimrc .zprofile .zshrc)
for file in "${files[@]}"; do
    echo "${YELLOW}🔗 Creating symlink to $file in $HOMEDIR${ENDCOLOR}"
    ln -sf "${CONFIGDIR}/${file}" "${HOMEDIR}/${file}"
done

# Change into .dotfiles directory
echo "Changing into ${DOTFILESDIR} directory..."
cd "$DOTFILESDIR" || exit

# Setup git if gitname and gitemail are given
if [ -n "$GITNAME" ] && [ -n "$GITMAIL" ]; then
    echo "${YELLOW}🔧 Setting up git...${ENDCOLOR}"
    git config --global user.name "$GITNAME"
    git config --global user.email "$GITMAIL"
    echo "${GREEN}...done!${ENDCOLOR}"
fi

#####################################################################################################
# Package installation                                                                              #
#####################################################################################################

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "${YELLOW}🍺 Installing Homebrew...${ENDCOLOR}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "${GREEN}...done!${ENDCOLOR}"
fi

# Run the Homebrew script and install packages
echo "${YELLOW}🍺 Installing packages...${ENDCOLOR}"
./brew.sh
echo "${GREEN}...done!${ENDCOLOR}"

#####################################################################################################
# Post installation                                                                                 #
#####################################################################################################

# Install vim plugin manager
echo "${YELLOW}Installing vim plugin manager...${ENDCOLOR}"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "${GREEN}...done!${ENDCOLOR}"

echo "\n--------------------------"
echo "${YELLOW}On first start of vim run:${ENDCOLOR}\n:PlugInstall"
echo "--------------------------\n"

# Finish
echo "${GREEN}Installation finished!${ENDCOLOR}"
