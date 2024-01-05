# 🏡 Feel like home on any mac

## Get started

-   Install Xcode commandline tools -> `xcode-select --install`
-   Install [Homebrew](https://brew.sh/) -> `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
-   Install GCM -> `brew install --cask git-credential-manager`
-   Clone this repo -> `git clone https://github.com/dan-koller/.dotfiles.git`
-   Make the scripts executable -> `chmod +x .dotfiles/*.sh`
-   Run `./.dotfiles/install.sh <hostname> <gitname> <gitemail>`

_Please make sure to specify the hostname as cli argument. The git details are optional. You can also provide a `--full` flag as 4th option to install all apps._

Example: `./install.sh "MyMacBookPro" "John Doe" "john.doe@example.com" --full`

## One-click-setup

```bash
xcode-select --install \
  && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && brew install --cask git-credential-manager \
  && git clone https://github.com/dan-koller/.dotfiles.git \
  && chmod +x .dotfiles/*.sh \
  && ./.dotfiles/install.sh <hostname> <gitname> <gitemail>
```
