###########################
# My basic install script #
###########################

###########################
# Update brew
###########################

brew update && brew upgrade
brew tap homebrew/cask-versions

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
brew install node
brew install neofetch
brew install ncdu
brew install tmux
brew install smartmontools

###########################
# Brew casks
###########################

brew install --cask google-chrome
brew install --cask brave-browser
brew install --cask google-drive
brew install --cask spotify
brew install --cask coconutbattery

brew install --cask temurin17
brew install --cask dotnet-sdk
brew install --cask pycharm-ce
brew install --cask visual-studio-code
brew install --cask git-credential-manager

###########################
# Brew cleanup
###########################

brew cleanup
