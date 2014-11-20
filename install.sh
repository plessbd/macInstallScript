#!/bin/bash
# https://github.com/Themitchell/OSX-Install-Scripts/
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    # http://brew.sh/
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew doctor
brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew install node

# instead of day-o (the developer does not like yosemite http://shauninman.com/archive/2011/10/20/day_o_mac_menu_bar_clock) use itsycal (http://www.mowglii.com/itsycal/)
brew cask install atom bettertouchtool iterm2 itsycal spotify the-unarchiver virtualbox vagrant  asepsis 

brew cask install google-chrome-dev firefoxdeveloperedition

echo "installing QuickLook Plugins"
#https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json quicklook-csv betterzipql

echo "Installing APM modules"
# look into http://blog.atom.io/2014/06/09/stars.html
apm install atom-beautifier linter linter-jshint linter-javac linter-shellcheck linter-htmlhint file-icons

echo "cleaning up"
brew cask cleanup
brew cleanup
defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder

echo "restart required for Asepsis"
sudo shutdown -r now
