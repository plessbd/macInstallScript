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
npm install -g appium selenium-standalone phantomjs plessbd/selenium-standalone


# https://github.com/Homebrew/homebrew-nginx

echo "Installing nginx"

brew tap homebrew/nginx
brew install nginx-full --with-fancyindex-module  --with-geoip --with-gzip-static --with-gunzip --with-upload-module  --with-upload-progress-module --with-spdy --with-realip

# Used to set where the location is to be, this is specific to OS X
# TODO: remove all these exports, they really dont need to be in the environment
# TODO: make this into two scripts, one for generating the CA one for generating self-signed
# Lots of reading, but very helpful
# https://jamielinux.com/articles/2013/08/act-as-your-own-certificate-authority/
# https://gist.github.com/mtigas/952344
# http://blog.nategood.com/client-side-certificate-authentication-in-ngi
# https://gist.github.com/jed/6147872
# http://blog.frd.mn/install-nginx-php-fpm-mysql-and-phpmyadmin-on-os-x-mavericks-using-homebrew/
# https://gist.github.com/igalic/4943106
# http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

export USERS_NAME="$(finger $(whoami) | egrep -o 'Name: [a-zA-Z0-9 ]{1,}' | cut -d ':' -f 2 | xargs echo)"
export CA_FILELOCATION="/Users/$(whoami)/Library/Application Support/Certificate Authority/${USERS_NAME}'s CA"
export CA_BASENAME="${CA_FILELOCATION}/${USERS_NAME}'s CA"

# PEM Formated Key and Cert
export CA_KEY="${CA_BASENAME}.key.pem"
export CA_CERT="${CA_BASENAME}.crt.pem"

export CA_PASSWORD="superSecretPassword"
# Could set a random password, not as useful when using the CA to create self-signed certs
# "$(env LC_CTYPE=C tr -dc 'a-zA-Z0-9-_\$\?' < /dev/urandom | head -c 32)"

# DER Formatted Certificate for importing into keychain
export CA_CERT_DER="${CA_BASENAME}.crt.der"

mkdir -p "${CA_FILELOCATION}"

if [ ! -e  ${CA_CERT} ]; then

	export C="US"
	echo "Country: ${C}"
	export ST="NY"
	echo "State/Province: ${ST}"
	export L="Clarence"
	echo "Locality (City): ${L}"
	export O="Development"
	echo "Organization: ${O}"
	export CN="${USERS_NAME}'s CA"
	echo "Common Name: ${CN}"

	echo "Creating Certificate Authority for Self Signed Certificates"

	openssl genrsa -aes256 -passout env:CA_PASSWORD -out "${CA_KEY}" 4096
	openssl req -new -x509 -sha256 \
		-days 3650 \
		-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN}" \
		-key "${CA_KEY}" \
		-out "${CA_CERT}" \
		-passin env:CA_PASSWORD

	echo "Converting certificate to DER encoding for importing into keychain"
	openssl x509 -inform PEM -in ${CA_CERT} -outform DER -out ${CA_CERT_DER}
	
	echo "Adding root CA to Keychain"
	# http://sdqali.in/blog/2012/06/05/managing-security-certificates-from-the-console-windows-mac-linux/
	security add-certificate "${CA_CERT_DER}"
	echo "trusting root CA, this will require user authentication."
	security add-trusted-cert "${CA_CERT_DER}"

fi

export CERT_DESTINATION="$(brew --prefix)/etc/nginx/ssl/"
export TEST_DOMAIN="ben.dev"
export TEST_DOMAIN_KEY="${CERT_DESTINATION}star.${TEST_DOMAIN}.key.pem"
export TEST_DOMAIN_CSR="${CERT_DESTINATION}star.${TEST_DOMAIN}.csr.pem"
export TEST_DOMAIN_CERT="${CERT_DESTINATION}star.${TEST_DOMAIN}.crt.pem"

mkdir -p "${CERT_DESTINATION}"

echo "Since our aim is to enable SSL on a web server, bear in mind that if the key is encrypted then you'll have to enter the encryption password every time you restart your web server. Use the -aes256 argument if you wish to encrypt your private key."
echo "Generate *.${TEST_DOMAIN} key"
openssl genrsa -out "${TEST_DOMAIN_KEY}" 4096

echo "Generate Certificate Signing Request *.${TEST_DOMAIN}"
openssl req -sha256 -new \
	-key "${TEST_DOMAIN_KEY}" \
	-out "${TEST_DOMAIN_CSR}" \
	-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=*.${TEST_DOMAIN}"

echo "Generate certificate *.${TEST_DOMAIN} signed by ${USERS_NAME}'s Certificate Authority'"
openssl x509 -req -sha256 -set_serial 01 \
	-days 3650 \
	-CA "${CA_CERT}" \
	-CAkey "${CA_KEY}" \
	-in "${TEST_DOMAIN_CSR}" \
	-out "${TEST_DOMAIN_CERT}" \
	-passin env:CA_PASSWORD


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

brew cask install google-chrome-dev firefoxdeveloperedition firefox 

# https://github.com/jimbojsb/launchrocket
# This will allow easy management of services from a prefpane
brew cask install launchrocket

# This will allow easy management of services from the commandline
# https://github.com/Homebrew/homebrew-services
brew tap homebrew/services

# instead of day-o (the developer does not like yosemite http://shauninman.com/archive/2011/10/20/day_o_mac_menu_bar_clock) use itsycal (http://www.mowglii.com/itsycal/)
brew cask install adium asepsis atom bettertouchtool iterm2 itsycal spotify the-unarchiver virtualbox vagrant

brew cask install java intellij-idea-ce

echo "installing QuickLook Plugins"
#https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json quicklook-csv betterzipql

echo "Installing APM modules"
# look into http://blog.atom.io/2014/06/09/stars.html
apm install atom-beautify linter linter-jshint linter-javac linter-shellcheck linter-htmlhint file-icons

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
