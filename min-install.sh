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
brew install python@3.9
brew install python-tk@3.9

# Databases
brew install sqlite

# Tools
brew install node
brew install neofetch
brew install ncdu
brew install tmux
brew install smartmontools

###########################
# Brew casks
###########################

brew install --cask google-chrome
brew install --cask google-drive
brew install --cask spotify
brew install --cask discord
brew install --cask teamviewer
brew install --cask coconutbattery

brew install --cask temurin17
brew install --cask visual-studio-code

###########################
# Brew cleanup
###########################

brew cleanup
