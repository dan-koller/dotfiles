# 🏡 Feel like home on any mac

## Get started

-   Install Xcode commandline tools -> `xcode-select --install`
-   Install [Homebrew](https://brew.sh/) -> `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
-   Clone this repo -> `git clone https://github.com/dan-koller/.dotfiles.git`
-   Make the scripts executable -> `chmod +x .dotfiles/*.sh`
-   Run `./.dotfiles/install.sh <hostname> <gitname> <gitemail>`

_The `hostname` is required, the `gitname` and `gitemail` are optional._

Example: `./install.sh "MyMacBookPro" "John Doe" "john.doe@example.com"`

## One-click-setup

```bash
xcode-select --install \
  && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && git clone https://github.com/dan-koller/.dotfiles.git \
  && chmod +x .dotfiles/*.sh \
  && ./.dotfiles/install.sh "My-MBP"
```
