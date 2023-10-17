# 🏡 Feel like home on any mac

## Get started

-   Install [Homebrew](https://brew.sh/) -> `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
-   Install GCM -> `brew install --cask git-credential-manager`
-   Clone this repo -> `git clone https://github.com/dan-koller/.dotfiles.git`
-   Make the scripts executable -> `chmod +x .dotfiles/*.sh`
-   Run `./.dotfiles/install.sh <hostname> <gitname> <gitemail>`

_Please make sure to specify the hostname as cli argument. You can also provide a `--full` flag to install all apps._

Example: `./install.sh "MyMacBookPro" "John Doe" "john.doe@example.com"`
