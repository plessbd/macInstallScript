# How to run a local Selenium Grid on OSX

This is to run a selenium grid supporting firefox, chrome, phantomjs, and iOS Simulators, this is a subset of https://github.com/plessbd/macInstallScript so if you have used that skip to the config files

## prerequisites

* Homebrew (http://brew.sh/)
```bash
which -s brew
if [[ $? != 0 ]] ; then
	# Install Homebrew
	# http://brew.sh/
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	brew update
fi
brew doctor
```
* caskroom (http://caskroom.io/)
```bash
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew tap caskroom/versions
brew install caskroom/cask/brew-cask
```
* node.js (https://nodejs.org/)
```bash
brew install nodejs
npm install -g npm@latest
```
* appium (http://appium.io) `npm -g appium`
* selenium-standalone (for now my version https://github.com/plessbd/selenium-standalone)
`npm -g install plessbd/selenium-standalone`
* Browsers
	* FireFox `cask install firefox`
	* Chrome `cask install google-chrome`
	* phantomjs `brew install -g phantomjs`
	* MobileSafari (requires xcode from Apple App Store and Simulators from xcode downloads)

## Config Files
