#!/bin/bash
# I have an SSD and an HDD so set some stuff up
# http://blog.macsales.com/13349-quick-tip-save-battery-by-spinning-down-hard-drive-sooner
sudo pmset -a disksleep 5
mkdir /Volumes/750GBHD/opt
mkdir /Volumes/750GBHD/tmp
mkdir -p /Volumes/750GBHD/Library/Caches/Homebrew
sudo ln -s /Volumes/750GBHD/Library/Caches/Homebrew /Library/Caches/Homebrew
ln -s /Volumes/750GBHD/opt/homebrew-cask /opt/homebrew-cask


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

brew install node
npm install -g npm@latest
npm install -g bower gulp json
#for automated testing
npm install -g appium selenium-standalone


# https://github.com/Homebrew/homebrew-nginx

echo "Installing nginx"

brew tap homebrew/nginx
brew install nginx-full --with-fancyindex-module  --with-geoip --with-gzip-static --with-gzip-static --with-gunzip --with-upload-module  --with-upload-progress-module --with-spdy --with-realip

#https://jamielinux.com/articles/2013/08/act-as-your-own-certificate-authority/
#https://gist.github.com/mtigas/952344
#http://blog.nategood.com/client-side-certificate-authentication-in-ngi
#https://gist.github.com/jed/6147872
#http://blog.frd.mn/install-nginx-php-fpm-mysql-and-phpmyadmin-on-os-x-mavericks-using-homebrew/
#https://gist.github.com/igalic/4943106
#http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

export USERS_NAME="`finger $(whoami) | egrep -o 'Name: [a-zA-Z0-9 ]{1,}' | cut -d ':' -f 2 | xargs echo`"
export ROOTCA_LOC="/Users/`whoami`/Library/Application Support/Certificate Authority/${USERS_NAME}'s CA"
export ROOTCA_NAMES="${ROOTCA_LOC}/${USERS_NAME}'s CA"
export KEYPASS="superSecurePassword"
export NGINX_SSL="`brew --prefix`/etc/nginx/ssl/"
mkdir -p "${ROOTCA_LOC}"


echo "Generate Root CA"
openssl genrsa -aes256 -passout env:KEYPASS -out "${ROOTCA_NAMES}.key.pem" 4096
openssl req -new -x509 -days 3650 -subj "/C=US/ST=NY/L=Buffalo/O=Development/CN=${USERS_NAME}'s CA" -key "${ROOTCA_NAMES}.key.pem" -sha256 -out "${ROOTCA_NAMES}.crt.pem" -passin env:KEYPASS

echo "Add ${ROOTCA_NAMES}.crt.pem to keychain (manual)"
#http://sdqali.in/blog/2012/06/05/managing-security-certificates-from-the-console-windows-mac-linux/
#not working Yet...
#security add-certificate "${ROOTCA_NAMES}.crt.pem"
#security add-trusted-cert "${ROOTCA_NAMES}.crt.pem"

# Since our aim is to enable SSL on a web server, bear in mind that if the key is encrypted then you'll have to enter the encryption password every time you restart your web server. Use the -aes256 argument if you wish to encrypt your private key.

mkdir -p ${NGINX_SSL}

echo "Generate SSL cert for loclahost"
openssl genrsa -out "${NGINX_SSL}localhost.key.pem" 4096
openssl req -sha256 -new -key "${NGINX_SSL}localhost.key.pem" -out "${NGINX_SSL}localhost.csr.pem" -subj "/C=US/ST=NY/L=Clarence/O=Development/CN=localhost"
openssl x509 -req -days 3650 -sha256 -CA "${ROOTCA_NAMES}.crt.pem" -CAkey "${ROOTCA_NAMES}.key.pem" -in "${NGINX_SSL}localhost.csr.pem" -set_serial 01  -out "${NGINX_SSL}localhost.crt.pem" -passin env:KEYPASS


#
# Look into dnsmasq for future
# https://mallinson.ca/osx-web-development/

#
# Need to use the following to setup node and nginx
#
# http://nginx.com/blog/nginx-nodejs-websockets-socketio/
# http://www.throrinstudio.com/dev/create-node-js-development-environment-on-osx/
# http://stackoverflow.com/questions/29795469/node-js-socket-io-server-on-os-x-cannot-connect-more-than-120-clients
#

brew tap caskroom/versions
brew install caskroom/cask/brew-cask

brew cask install google-chrome-dev firefoxdeveloperedition

# instead of day-o (the developer does not like yosemite http://shauninman.com/archive/2011/10/20/day_o_mac_menu_bar_clock) use itsycal (http://www.mowglii.com/itsycal/)
brew cask install adium atom bettertouchtool iterm2 itsycal spotify the-unarchiver virtualbox vagrant  asepsis 

brew cask install java intellij-idea-ce

echo "installing QuickLook Plugins"
#https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json quicklook-csv betterzipql

echo "Installing APM modules"
# look into http://blog.atom.io/2014/06/09/stars.html
apm install atom-beautifier linter linter-jshint linter-javac linter-shellcheck linter-htmlhint file-icons

echo "cleaning up"
brew cask cleanup
brew cleanup

echo "setting some defaults"

echo "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Remove duplicates in the “Open With” menu (also see `lscleanup` alias)"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo" Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Trackpad: enable tap to click for this user and for the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "Finder: allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

echo "# Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo "restart required for Asepsis"
sudo shutdown -r now
