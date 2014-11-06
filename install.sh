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


echo "cleaning up"
brew cask cleanup
brew cleanup

echo "restart required for Asepsis"
sudo shutdown -r now
