###########################
# Additional packages
###########################

# Taps
brew tap isen-ng/dotnet-sdk-versions

# Packages
brew install mysql
brew install gradle
brew install neovim
brew install htop

# Casks
brew install --cask firefox
brew install --cask temurin11
brew install --cask temurin8
brew install --cask dotnet-sdk6-0-400 # LTS
brew install --cask intellij-idea-ce
brew install --cask postman
brew install --cask docker

# Cleanup
brew cleanup

###########################
# Postinstall
###########################

# Neovim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo "${GREEN}...done!${ENDCOLOR}"