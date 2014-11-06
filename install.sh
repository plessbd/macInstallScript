#!/bin/bash
# https://github.com/Themitchell/OSX-Install-Scripts/
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    # https://github.com/mxcl/homebrew/wiki/installation
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
else
    brew update
fi

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew doctor
brew install caskroom/cask/brew-cask
brew install node

brew cask install atom bettertouchtool day-o iterm2 google-chrome spotify the-unarchiver virtualbox vagrant asepsis

echo "installing QuickLook Plugins"
#https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json quicklook-csv betterzipql

echo "Installing APM modules"
apm install linter linter-jshint linter-javac linter-shellcheck linter-htmlhint file-icons

echo "cleaning up"
brew cask cleanup
brew cleanup
defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder

echo "restart required for Asepsis"
sudo shutdown -r now
