###########################
# My basic install script #
###########################

###########################
# Update brew
###########################

brew update && brew upgrade

###########################
# Brew packages
###########################

# Languages
brew install python@3.11
brew install python-tk@3.11

# Databases
brew install sqlite

# Tools
brew install git
brew install ncdu
brew install node
brew install neofetch
brew install smartmontools

###########################
# Brew casks
###########################

brew install --cask google-chrome
brew install --cask google-drive
brew install --cask spotify
brew install --cask coconutbattery

brew install --cask dotnet-sdk
brew install --cask temurin@17
brew install --cask visual-studio-code
brew install --cask git-credential-manager

###########################
# Brew cleanup
###########################

brew cleanup
